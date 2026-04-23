# core/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.utils import timezone
from django.db import models, transaction
from django.db.models import Q
from django.core.cache import cache
from datetime import date, timedelta
import logging

from .models import Cours, Information
from .scraping import ExtracteurUPGC, recuperer_rooms
from .serializers import (
    CoursSerializer,
    InformationSerializer,
)
from .data import AREAS, ROOMS_PAR_AREA, AREA_PAR_DEFAUT, AREAS_PAR_DEFAUT, CACHE_TIMEOUT

logger = logging.getLogger(__name__)


def _get_room_nom(area_id, room_id):
    """Retourne le nom de la salle à partir de son ID"""
    rooms = ROOMS_PAR_AREA.get(area_id, [])
    for room in rooms:
        if room['id'] == room_id:
            return room['nom']
    return None


class APIRootView(APIView):
    def get(self, request):
        return Response({
            'message': 'API UPGC - Université Peleforo Gbon Coulibaly',
            'version': '1.0',
            'endpoints': {
                'aujourdhui': '/api/aujourdhui/',
                'informations': '/api/informations/',
                'domaines': '/api/domaines/',
                'config': '/api/config/',
            }
        })


class EmploiDuTempsDuJourAPIView(APIView):
    def get(self, request, *args, **kwargs):
        try:
            area = self._get_area_param(request)
            room = self._get_room_param(request)
            date_cible = self._get_date_param(request)
            force_actualisation = self._get_bool_param(request, 'actualiser', False)
            semaine_complete = self._get_bool_param(request, 'semaine', False)
            
            if semaine_complete:
                resultat = self._recuperer_semaine_complete(area, room, date_cible, force_actualisation)
            else:
                resultat = self._recuperer_emploi_du_jour(area, room, date_cible, force_actualisation)
            
            return Response(resultat, status=status.HTTP_200_OK)
            
        except ValueError as e:
            return self._reponse_erreur(str(e), status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            logger.error(f"Erreur serveur: {e}", exc_info=True)
            return self._reponse_erreur(f"Erreur serveur: {str(e)}", status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def _get_area_param(self, request):
        area_str = request.GET.get('area')
        if area_str is None or area_str == '':
            return None
        try:
            return int(area_str)
        except (ValueError, TypeError):
            return AREA_PAR_DEFAUT
    
    def _get_room_param(self, request):
        try:
            room_str = request.GET.get('room', '0')
            if room_str:
                return int(room_str)
            return 0
        except (ValueError, TypeError):
            return 0
    
    def _get_date_param(self, request):
        if 'jour' in self.kwargs and 'mois' in self.kwargs and 'annee' in self.kwargs:
            try:
                return date(self.kwargs['annee'], self.kwargs['mois'], self.kwargs['jour'])
            except ValueError:
                raise ValueError("Date invalide dans l'URL")

        date_str = request.GET.get('date')
        if not date_str:
            return date.today()
        
        for fmt in ('%Y-%m-%d', '%d/%m/%Y', '%d-%m-%Y'):
            try:
                from datetime import datetime
                return datetime.strptime(date_str, fmt).date()
            except (ValueError, TypeError):
                continue
                 
        raise ValueError("Le format de date doit être YYYY-MM-DD ou DD/MM/YYYY")
    
    def _get_bool_param(self, request, param, default):
        val = request.GET.get(param, str(default))
        return val.lower() in ['true', '1', 'yes', 'vrai']
    
    def _get_cache_key(self, area, room, date_cible, semaine=False):
        suffix = "semaine" if semaine else "jour"
        room_str = f"_room{room}" if room else ""
        return f"edt_{suffix}_area{area}{room_str}_{date_cible.isoformat()}"
    
    def _recuperer_emploi_du_jour(self, area, room, date_cible, force):
        if area is None:
            return self._recuperer_areas_multiples(AREAS_PAR_DEFAUT, room, date_cible, force)
        
        cache_key = self._get_cache_key(area, room, date_cible, False)
        
        if not force:
            cached = cache.get(cache_key)
            if cached:
                return cached
        
        extracteur = ExtracteurUPGC()
        
        # Use date_specifique=True for better scraping results (p=jour shows resources as columns)
        nouvelles_donnees = extracteur.recuperer_emploi_du_temps(
            area=area, 
            room=room if room > 0 else None,
            date_cible=date_cible, 
            date_specifique=True  # Always use single day view for filtering
        )
        self._sauvegarder_evenements(nouvelles_donnees, area)
        
        if room and room > 0:
            room_nom = _get_room_nom(area, room)
            # For room filtering, check if the resource starts with the room name
            # (because scraping returns headers like "Amphi BAmphi B(530...")
            cours_du_jour = [
                e for e in nouvelles_donnees 
                if e.get('jour') == date_cible and room_nom and e.get('ressource', '').startswith(room_nom)
            ]
            result = self._construire_reponse_jour(cours_du_jour, date_cible, area, room, 'scraping')
        else:
            # No room specified - return all courses for this area
            cours_du_jour = [e for e in nouvelles_donnees if e.get('jour') == date_cible]
            result = self._construire_reponse_jour(cours_du_jour, date_cible, area, room, 'scraping')
        
        cache.set(cache_key, result, CACHE_TIMEOUT)
        return result
    
    def _recuperer_areas_multiples(self, areas, room, date_cible, force):
        cache_key = f"edt_jour_areas{'_'.join(map(str, areas))}_room{room}_{date_cible.isoformat()}"
        
        if not force:
            cached = cache.get(cache_key)
            if cached:
                return cached
        
        extracteur = ExtracteurUPGC()
        toutes_donnees = []
        
        # Always use date_specifique=True for better results (like _recuperer_emploi_du_jour)
        use_date_specifique = True
        
        for a in areas:
            donnees = extracteur.recuperer_emploi_du_temps(
                area=a,
                room=room if room > 0 else None,
                date_cible=date_cible,
                date_specifique=use_date_specifique
            )
            toutes_donnees.extend(donnees)
        
        self._sauvegarder_evenements(toutes_donnees)
        
        cours_du_jour = [e for e in toutes_donnees if e['jour'] == date_cible]
        result = self._construire_reponse_jour(cours_du_jour, date_cible, areas, room, 'scraping')
        
        cache.set(cache_key, result, CACHE_TIMEOUT)
        return result
    
    def _recuperer_semaine_complete(self, area, room, date_ref, force):
        cache_key = self._get_cache_key(area, room, date_ref, True)
        
        if not force:
            cached = cache.get(cache_key)
            if cached:
                return cached
        
        start = date_ref - timedelta(days=date_ref.weekday())
        end = start + timedelta(days=6)
        
        extracteur = ExtracteurUPGC()
        semaine_complete = extracteur.recuperer_emploi_du_temps(
            area=area,
            room=room if room > 0 else None,
            date_cible=date_ref, 
            date_specifique=False
        )
        self._sauvegarder_evenements(semaine_complete, area)
        
        tous_cours = list(Cours.objects.filter(jour__gte=start, jour__lte=end).order_by('jour', 'horaire'))
        
        if area:
            if room and room > 0:
                room_nom = _get_room_nom(area, room)
                if room_nom:
                    tous_cours = [c for c in tous_cours if c.ressource == room_nom]
            elif room == 0 and area not in AREAS_PAR_DEFAUT:
                rooms_noms = [r['nom'] for r in ROOMS_PAR_AREA.get(area, [])]
                tous_cours = [c for c in tous_cours if c.ressource in rooms_noms]
        
        cours_par_jour = {}
        for cours in tous_cours:
            if cours.jour not in cours_par_jour:
                cours_par_jour[cours.jour] = []
            cours_par_jour[cours.jour].append(cours)
        
        semaine_data = []
        for i in range(7):
            d = start + timedelta(days=i)
            donnees = cours_par_jour.get(d, [])
            semaine_data.append({
                'date': d.isoformat(),
                'jour_semaine': self._get_jour_semaine_fr(d),
                'nombre_evenements': len(donnees),
                'source': 'cache',
                'evenements': CoursSerializer(donnees, many=True).data
            })
        
        result = {
            'semaine': {
                'debut': start.isoformat(),
                'fin': end.isoformat(),
                'numero': start.isocalendar()[1],
                'annee': start.year
            },
            'area': area,
            'room': room if room > 0 else None,
            'nombre_total_evenements': sum(j['nombre_evenements'] for j in semaine_data),
            'jours': semaine_data,
            'timestamp': timezone.now().isoformat()
        }
        
        cache.set(cache_key, result, CACHE_TIMEOUT)
        return result
    
    def _sauvegarder_evenements(self, data_list, zone=2):
        if not data_list:
            return []
        
        with transaction.atomic():
            existants = {
                (c.jour, c.horaire, c.ressource): c 
                for c in Cours.objects.filter(
                    jour__in=[d['jour'] for d in data_list],
                    horaire__in=[d['horaire'] for d in data_list],
                    ressource__in=[d['ressource'] for d in data_list]
                )
            }
            
            a_creer = []
            a_modifier = []
            
            for item in data_list:
                item_copy = {k: v for k, v in item.items() if k != 'zone'}
                key = (item_copy['jour'], item_copy['horaire'], item_copy['ressource'])
                if key in existants:
                    cours = existants[key]
                    cours.type_cours = item_copy['type_cours']
                    cours.enseignant = item_copy['enseignant']
                    cours.intitule = item_copy['intitule']
                    cours.niveau = item_copy.get('niveau', '')
                    cours.salle = item_copy['salle']
                    a_modifier.append(cours)
                else:
                    a_creer.append(Cours(**item_copy))
            
            if a_modifier:
                Cours.objects.bulk_update(a_modifier, ['type_cours', 'enseignant', 'intitule', 'niveau', 'salle'], batch_size=100)
            
            if a_creer:
                Cours.objects.bulk_create(a_creer, ignore_conflicts=True, batch_size=100)
            
            return list(a_modifier) + a_creer
    
    def _construire_reponse_jour(self, evenements, date_cible, area, room, source):
        area_value = area if isinstance(area, list) else (area if area else AREA_PAR_DEFAUT)
        return {
            'date': date_cible.isoformat(),
            'jour_semaine': self._get_jour_semaine_fr(date_cible),
            'area': area_value,
            'room': room if room > 0 else None,
            'source': source,
            'timestamp': timezone.now().isoformat(),
            'nombre_evenements': len(evenements),
            'donnees': CoursSerializer(evenements, many=True).data
        }
    
    def _get_jour_semaine_fr(self, d):
        return ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'][d.weekday()]
    
    def _reponse_erreur(self, msg, code, details=None):
        return Response({
            'erreur': msg, 
            'code': code, 
            'details': details or {}, 
            'timestamp': timezone.now().isoformat()
        }, status=code)


class ListeAreasAPIView(APIView):
    def get(self, request):
        area_id = request.GET.get('area')
        rooms = []
        
        if area_id:
            try:
                area = int(area_id)
                rooms = ROOMS_PAR_AREA.get(area, [])
            except Exception as e:
                logger.error(f"Erreur récupération rooms: {e}")
        
        return Response({
            'areas': AREAS,
            'rooms': rooms,
            'timestamp': timezone.now().isoformat()
        }, status=status.HTTP_200_OK)


class ListeRoomsAPIView(APIView):
    def get(self, request):
        area_id = request.GET.get('area')
        
        if not area_id:
            return self._get_combined_rooms(request)
        
        try:
            area = int(area_id)
        except (ValueError, TypeError):
            return Response({
                'erreur': 'Area invalide',
                'code': status.HTTP_400_BAD_REQUEST,
                'rooms': []
            }, status=status.HTTP_400_BAD_REQUEST)
        
        force_refresh = request.GET.get('refresh', 'false').lower() in ['true', '1', 'yes']
        cache_key = f"rooms_area_{area}"
        
        if not force_refresh:
            cached_rooms = cache.get(cache_key)
            if cached_rooms:
                return Response({
                    'area': area,
                    'rooms': cached_rooms,
                    'source': 'cache',
                    'timestamp': timezone.now().isoformat()
                }, status=status.HTTP_200_OK)
        
        extracteur = ExtracteurUPGC()
        rooms = extracteur.recuperer_rooms(area=area)
        
        if rooms:
            cache.set(cache_key, rooms, 3600)
        
        return Response({
            'area': area,
            'rooms': rooms,
            'source': 'scraping',
            'timestamp': timezone.now().isoformat()
        }, status=status.HTTP_200_OK)
    
    def _get_combined_rooms(self, request):
        cache_key = "rooms_combined_2_16"
        
        force_refresh = request.GET.get('refresh', 'false').lower() in ['true', '1', 'yes']
        
        if not force_refresh:
            cached_rooms = cache.get(cache_key)
            if cached_rooms:
                return Response({
                    'rooms': cached_rooms,
                    'source': 'cache',
                    'timestamp': timezone.now().isoformat()
                }, status=status.HTTP_200_OK)
        
        rooms_2 = [{**r, 'area': 2} for r in ROOMS_PAR_AREA.get(2, [])]
        rooms_16 = [{**r, 'area': 16} for r in ROOMS_PAR_AREA.get(16, [])]
        
        combined_rooms = rooms_2 + rooms_16
        
        cache.set(cache_key, combined_rooms, 3600)
        
        return Response({
            'rooms': combined_rooms,
            'source': 'static',
            'timestamp': timezone.now().isoformat()
        }, status=status.HTTP_200_OK)


class InformationsListAPIView(APIView):
    def get(self, request):
        try:
            inclure_expirees = self._get_bool_param(request, 'inclure_expirees', False)
            limite = self._get_int_param(request, 'limite', 50)
            
            queryset = Information.objects.all()
            
            if not inclure_expirees:
                from django.utils import timezone as tz
                now = tz.now()
                queryset = queryset.filter(
                    models.Q(date_expiration__isnull=True) | 
                    models.Q(date_expiration__gte=now)
                )
            
            informations = queryset[:limite]
            
            return Response({
                'nombre': len(informations),
                'informations': InformationSerializer(informations, many=True).data,
                'timestamp': timezone.now().isoformat()
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            logger.error(f"Erreur serveur: {e}", exc_info=True)
            return Response({
                'erreur': str(e),
                'code': status.HTTP_500_INTERNAL_SERVER_ERROR,
                'timestamp': timezone.now().isoformat()
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def _get_bool_param(self, request, param, default):
        val = request.GET.get(param, str(default))
        return val.lower() in ['true', '1', 'yes', 'vrai']
    
    def _get_int_param(self, request, param, default):
        try:
            return int(request.GET.get(param, default))
        except (ValueError, TypeError):
            return default


class InformationDetailAPIView(APIView):
    def get(self, request, pk):
        try:
            information = Information.objects.get(pk=pk)
            return Response({
                'information': InformationSerializer(information).data,
                'timestamp': timezone.now().isoformat()
            }, status=status.HTTP_200_OK)
            
        except Information.DoesNotExist:
            return Response({
                'erreur': 'Information non trouvée',
                'code': status.HTTP_404_NOT_FOUND,
                'timestamp': timezone.now().isoformat()
            }, status=status.HTTP_404_NOT_FOUND)
            
        except Exception as e:
            logger.error(f"Erreur serveur: {e}", exc_info=True)
            return Response({
                'erreur': str(e),
                'code': status.HTTP_500_INTERNAL_SERVER_ERROR,
                'timestamp': timezone.now().isoformat()
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ListeDomainesAPIView(APIView):
    def get(self, request):
        domaines = [{'id': a['id'], 'nom': a['nom']} for a in AREAS]
        return Response({
            'domaines': domaines,
            'total': len(domaines),
            'timestamp': timezone.now().isoformat()
        }, status=status.HTTP_200_OK)


class DetailDomaineAPIView(APIView):
    def get(self, request, area_id):
        domaine = next((a for a in AREAS if a['id'] == area_id), None)
        if not domaine:
            return Response({
                'erreur': 'Domaine non trouvé',
                'code': status.HTTP_404_NOT_FOUND,
                'timestamp': timezone.now().isoformat()
            }, status=status.HTTP_404_NOT_FOUND)
        
        force_refresh = request.GET.get('refresh', 'false').lower() in ['true', '1', 'yes']
        rooms = self._get_rooms_for_area(area_id, force_refresh)
        
        return Response({
            'id': domaine['id'],
            'nom': domaine['nom'],
            'ressources': rooms,
            'source': 'cache' if not force_refresh else 'scraping',
            'timestamp': timezone.now().isoformat()
        }, status=status.HTTP_200_OK)
    
    def _get_rooms_for_area(self, area_id, force_refresh):
        cache_key = f"rooms_area_{area_id}"
        
        if not force_refresh:
            cached_rooms = cache.get(cache_key)
            if cached_rooms:
                return cached_rooms
        
        rooms = ROOMS_PAR_AREA.get(area_id, [])
        
        if rooms:
            cache.set(cache_key, rooms, 3600)
        
        return rooms


class ListeRessourcesAPIView(APIView):
    def get(self, request, area_id):
        domaine = next((a for a in AREAS if a['id'] == area_id), None)
        if not domaine:
            return Response({
                'erreur': 'Domaine non trouvé',
                'code': status.HTTP_404_NOT_FOUND,
                'timestamp': timezone.now().isoformat()
            }, status=status.HTTP_404_NOT_FOUND)
        
        force_refresh = request.GET.get('refresh', 'false').lower() in ['true', '1', 'yes']
        
        cache_key = f"rooms_area_{area_id}"
        
        if not force_refresh:
            cached_rooms = cache.get(cache_key)
            if cached_rooms:
                return Response({
                    'area_id': area_id,
                    'ressources': cached_rooms,
                    'source': 'cache',
                    'timestamp': timezone.now().isoformat()
                }, status=status.HTTP_200_OK)
        
        rooms = ROOMS_PAR_AREA.get(area_id, [])
        
        if rooms:
            cache.set(cache_key, rooms, 3600)
        
        return Response({
            'area_id': area_id,
            'ressources': rooms,
            'source': 'static',
            'timestamp': timezone.now().isoformat()
        }, status=status.HTTP_200_OK)


class EmploiRessourceAPIView(APIView):
    def get(self, request, area_id, room_id):
        domaine = next((a for a in AREAS if a['id'] == area_id), None)
        if not domaine:
            return Response({
                'erreur': 'Domaine non trouvé',
                'code': status.HTTP_404_NOT_FOUND,
                'timestamp': timezone.now().isoformat()
            }, status=status.HTTP_404_NOT_FOUND)
        
        rooms = ROOMS_PAR_AREA.get(area_id, [])
        room_exists = any(r['id'] == room_id for r in rooms)
        if not room_exists:
            return Response({
                'erreur': 'Ressource non trouvée pour ce domaine',
                'code': status.HTTP_404_NOT_FOUND,
                'timestamp': timezone.now().isoformat()
            }, status=status.HTTP_404_NOT_FOUND)
        
        date_cible = self._get_date_param(request)
        semaine = self._get_bool_param(request, 'semaine', False)
        actualiser = self._get_bool_param(request, 'actualiser', False)
        
        if semaine:
            result = self._get_emploi_semaine(area_id, room_id, date_cible, actualiser)
        else:
            result = self._get_emploi_jour(area_id, room_id, date_cible, actualiser)
        
        return Response(result, status=status.HTTP_200_OK)
    
    def _get_date_param(self, request):
        date_str = request.GET.get('date')
        if not date_str:
            return date.today()
        
        for fmt in ('%Y-%m-%d', '%d/%m/%Y', '%d-%m-%Y'):
            try:
                from datetime import datetime
                return datetime.strptime(date_str, fmt).date()
            except (ValueError, TypeError):
                continue
        
        return date.today()
    
    def _get_bool_param(self, request, param, default):
        val = request.GET.get(param, str(default))
        return val.lower() in ['true', '1', 'yes', 'vrai']
    
    def _get_cache_key(self, area_id, room_id, date_cible, semaine=False):
        suffix = "semaine" if semaine else "jour"
        return f"edt_{suffix}_area{area_id}_room{room_id}_{date_cible.isoformat()}"
    
    def _get_emploi_jour(self, area_id, room_id, date_cible, force):
        cache_key = self._get_cache_key(area_id, room_id, date_cible, False)
        
        if not force:
            cached = cache.get(cache_key)
            if cached:
                return cached
        
        extracteur = ExtracteurUPGC()
        nouvelles_donnees = extracteur.recuperer_emploi_du_temps(
            area=area_id,
            room=room_id,
            date_cible=date_cible,
            date_specifique=True
        )
        
        cours_du_jour = [e for e in nouvelles_donnees if e['jour'] == date_cible]
        
        result = {
            'date': date_cible.isoformat(),
            'jour_semaine': ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'][date_cible.weekday()],
            'area': area_id,
            'room': room_id,
            'source': 'scraping',
            'nombre_evenements': len(cours_du_jour),
            'donnees': CoursSerializer(cours_du_jour, many=True).data,
            'timestamp': timezone.now().isoformat()
        }
        
        cache.set(cache_key, result, CACHE_TIMEOUT)
        return result
    
    def _get_emploi_semaine(self, area_id, room_id, date_ref, force):
        cache_key = self._get_cache_key(area_id, room_id, date_ref, True)
        
        if not force:
            cached = cache.get(cache_key)
            if cached:
                return cached
        
        start = date_ref - timedelta(days=date_ref.weekday())
        
        extracteur = ExtracteurUPGC()
        semaine_complete = extracteur.recuperer_emploi_du_temps(
            area=area_id,
            room=room_id,
            date_cible=date_ref,
            date_specifique=False
        )
        
        semaine_data = []
        for i in range(7):
            d = start + timedelta(days=i)
            cours_du_jour = [e for e in semaine_complete if e['jour'] == d]
            semaine_data.append({
                'date': d.isoformat(),
                'jour_semaine': ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'][d.weekday()],
                'nombre_evenements': len(cours_du_jour),
                'evenements': CoursSerializer(cours_du_jour, many=True).data
            })
        
        result = {
            'semaine': {
                'debut': start.isoformat(),
                'fin': (start + timedelta(days=6)).isoformat(),
                'numero': start.isocalendar()[1],
                'annee': start.year
            },
            'area': area_id,
            'room': room_id,
            'source': 'scraping',
            'nombre_total_evenements': sum(j['nombre_evenements'] for j in semaine_data),
            'jours': semaine_data,
            'timestamp': timezone.now().isoformat()
        }
        
        cache.set(cache_key, result, CACHE_TIMEOUT)
        return result
