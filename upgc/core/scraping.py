# core/scraping.py
import requests
from bs4 import BeautifulSoup
from datetime import datetime, date
import logging
import re
from .models import Cours

logger = logging.getLogger(__name__)

TYPE_COURS_MAP = {
    'typeA': 'CM',
    'typeB': 'TD',
    'typeC': 'TP',
    'typeD': 'EXAMEN',
    'typeE': 'DEVOIR',
    'typeF': 'AEM',
    'typeG': 'CONFERENCE',
    'typeH': 'SEMINAIRE',
    'typeI': 'REUNION',
    'typeJ': 'COLLOQUE',
    'typeK': 'DELIBERATION',
    'typeL': 'SOUTENANCE',
    'typeM': 'MISE A NIVEAU',
    'typeN': 'SPORT',
}


class ExtracteurUPGC:
    """
    Extracteur robuste pour le site UPGC.
    Utilise le title et le texte des liens pour extraire les infos.
    """
    
    URL_BASE = "https://upgc.mygrr.net/app.php"
    
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
    
    def parse_date_from_url(self, url):
        import urllib.parse
        try:
            parsed = urllib.parse.urlparse(url)
            params = urllib.parse.parse_qs(parsed.query)
            if 'year' in params and 'month' in params and 'day' in params:
                date_str = f"{params['year'][0]}-{params['month'][0].zfill(2)}-{params['day'][0].zfill(2)}"
                return datetime.strptime(date_str, "%Y-%m-%d").date()
        except Exception as e:
            logger.warning(f"Erreur parsing date url {url}: {e}")
        return None
    
    def parse_title(self, title_text):
        """
        Parse le title pour extraire Niveau et Salle.
        Ex: "Réservation n° 56177\nNiveau : L2  BIO \nSalle  : AMPHI B"
        """
        niveau = ""
        salle = ""
        
        match = re.search(r'Niveau\s*:\s*(.+)', title_text)
        if match:
            niveau = match.group(1).strip()
        
        match = re.search(r'Salle\s*:\s*(.+)', title_text)
        if match:
            salle = match.group(1).strip()
        
        return niveau, salle
    
    TITRES_ENSEIGNANTS = {'Dr', 'M.', 'Mme', 'Mlle', 'Prof.', 'Pr.', 'Ing.'}

    def parse_link_text(self, text):
        """
        Parse le texte du lien pour extraire horaire, type_cours, enseignant, intitule.
        Format: "11:30 à 14:30\nCM\nDr (MC) COULIBALY...\nNUTRITION CARBONEE..."
        """
        lignes = [l.strip() for l in text.split('\n') if l.strip()]
        
        horaire = ""
        type_cours = ""
        enseignant = ""
        intitule = ""
        idx_horaire = -1
        
        pattern_horaire = r'(\d{1,2}:\d{2})\s*à\s*(\d{1,2}:\d{2})'
        for i, ligne in enumerate(lignes):
            match = re.search(pattern_horaire, ligne)
            if match:
                horaire = f"{match.group(1)} à {match.group(2)}"
                idx_horaire = i
                break
        
        if idx_horaire == -1:
            return horaire, type_cours, enseignant, intitule
        
        if idx_horaire + 1 < len(lignes):
            type_ligne = lignes[idx_horaire + 1].upper()
            for type_key, type_val in TYPE_COURS_MAP.items():
                if type_val in type_ligne:
                    type_cours = type_val
                    break
            if not type_cours:
                type_cours = lignes[idx_horaire + 1]
        
        reste = lignes[idx_horaire + 2:]
        
        for ligne in reste:
            if not enseignant and any(t in ligne for t in self.TITRES_ENSEIGNANTS):
                enseignant = ligne
            elif not intitule and not any(x in ligne for x in ['Niveau', 'Salle']):
                intitule = ligne
        
        return horaire, type_cours, enseignant, intitule
    
    def extract_cours_from_link(self, link, td_element, ressource, jour):
        """
        Extrait un cours depuis un lien <a> dans une cellule.
        """
        try:
            # Récupérer le title
            title = link.get('title', '')
            niveau_title, salle_title = self.parse_title(title)
            
            text = link.get_text(separator='\n', strip=True)
            horaire, type_cours, enseignant, intitule = self.parse_link_text(text)
            
            # Récupérer le type depuis la classe CSS de la cellule
            type_from_class = ""
            for cls in td_element.get('class', []):
                if cls.startswith('type'):
                    type_from_class = TYPE_COURS_MAP.get(cls, cls)
                    break
            
            # Utiliser le type depuis la classe si pas trouvé dans le texte
            if not type_cours and type_from_class:
                type_cours = type_from_class
            
            # Si pas de salle dans le title, utiliser la ressource
            salle = salle_title if salle_title else ressource
            
            # Si pas de niveau dans le title, on laisse vide
            niveau = niveau_title
            
            # Créer l'objet cours
            if horaire:
                return {
                    'jour': jour,
                    'horaire': horaire,
                    'type_cours': type_cours or 'AUTRE',
                    'enseignant': enseignant or 'Non spécifié',
                    'intitule': intitule or 'Cours',
                    'niveau': niveau,
                    'salle': salle,
                    'ressource': ressource
                }
        except Exception as e:
            logger.error(f"Erreur extraction lien: {e}")
        return None
    
    def recuperer_emploi_du_temps(self, area=2, room=None, date_cible=None, date_specifique=None):
        """
        Récupère l'emploi du temps.
        
        Args:
            area: ID de la zone/département
            room: ID de la salle/niveau (optionnel)
            date_cible: date pour laquelle on veut les cours
            date_specifique: si True, retourne seulement les cours de date_cible
                           si False (défaut), retourne toute la semaine
        """
        if date_cible is None:
            date_cible = date.today()
        
        url = self.URL_BASE
        
        # p=jour: single day view, shows resources as columns (good for filtering)
        # p=semaine_all: week view, shows resources as rows
        # p=semaine: week view with time slots (for UPGC/salles louées)
        AREAS_UPGC = [2, 16]
        
        if date_specifique:
            # Single day view - use p=jour
            if room and room > 0:
                # Specific room - always include area for UPGC
                params = {
                    'p': 'jour',
                    'area': area if area else 2,
                    'room': room,
                    'year': date_cible.year,
                    'month': date_cible.month,
                    'day': date_cible.day
                }
            else:
                # All rooms for an area - use area param
                params = {
                    'p': 'jour',
                    'area': area if area else 2,
                    'year': date_cible.year,
                    'month': date_cible.month,
                    'day': date_cible.day
                }
        else:
            # Week view
            if room and room > 0:
                if area and area in AREAS_UPGC:
                    # UPGC with specific room - use p=semaine
                    params = {
                        'p': 'semaine',
                        'area': area,
                        'room': room,
                        'year': date_cible.year,
                        'month': date_cible.month,
                        'day': date_cible.day
                    }
                else:
                    # Other domains - use p=semaine_all
                    params = {
                        'p': 'semaine_all',
                        'area': area,
                        'year': date_cible.year,
                        'month': date_cible.month,
                        'day': date_cible.day
                    }
            else:
                # All rooms
                if area and area in AREAS_UPGC:
                    params = {
                        'p': 'semaine',
                        'area': area if area else 2,
                        'year': date_cible.year,
                        'month': date_cible.month,
                        'day': date_cible.day
                    }
                else:
                    params = {
                        'p': 'semaine_all',
                        'area': area if area else 2,
                        'year': date_cible.year,
                        'month': date_cible.month,
                        'day': date_cible.day
                    }
        
        try:
            logger.info(f"Scraping UPGC: area={area}, room={room}, date={date_cible}, date_specifique={date_specifique}, params={params}")
            response = self.session.get(url, params=params)
            response.raise_for_status()
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # Chercher le tableau - peut être table.semaine, table.calendar, ou table.jour
            main_table = soup.select_one('div#planning2 table.semaine')
            if not main_table:
                main_table = soup.select_one('div#planning2 table.calendar')
            if not main_table:
                main_table = soup.select_one('div#planning2 table.jour')
            if not main_table:
                main_table = soup.select_one('div#planning2 table')
            if not main_table:
                logger.error("Tableau principal non trouvé")
                return []
            
            # 1. Extraire les dates depuis les en-têtes
            dates = []
            thead = main_table.find('thead')
            if thead:
                headers_row = thead.find('tr')
                if headers_row:
                    for th in headers_row.find_all('th')[1:]:
                        link = th.find('a')
                        if link and link.get('href'):
                            d = self.parse_date_from_url(link.get('href'))
                            if d:
                                dates.append(d)
                        else:
                            # Pas de lien - pas de date identifiable dans l'en-tête
                            pass
            
            # Pour p=jour: toujours utiliser date_cible car on voit un seul jour
            # (L'en-tête peut avoir des liens qui ne sont pas des dates)
            if date_specifique or not dates or None in dates:
                dates = [date_cible]
            
            # Pour p=jour: extraire les noms de ressources depuis les en-têtes
            ressources_col = []
            if date_specifique and thead:
                headers_row = thead.find('tr')
                if headers_row:
                    # Pour p=jour: premier th est le nom de la ressource, pas "Heure"
                    all_th = headers_row.find_all('th')
                    for th in all_th:
                        text = th.get_text(strip=True)
                        # Nettoyer le nom (enlever les répétitions)
                        # Ex: "Licence 3Licence 3" -> "Licence 3"
                        text = text[:len(text)//2] if len(text) > 4 else text
                        ressources_col.append(text)
            
            logger.info(f"Dates trouvées dans le tableau: {dates}")
            logger.info(f"Ressources colonnes (p=jour): {ressources_col}")

            # Pour p=jour: le format est différent!
            # - Première colonne = créneau horaire
            # - Colonnes suivantes = ressources
            # Si date_specifique=True, on utilise p=jour donc le format est toujours spécial
            is_p_jour = date_specifique
            
            # 2. Parser chaque ligne de ressource
            tbody = main_table.find('tbody')
            if not tbody:
                return []
            
            evenements = []
            
            rows = tbody.find_all('tr', recursive=False)
            logger.info(f"Nombre de lignes (ressources): {len(rows)}")
            
            for row in rows:
                cells = row.find_all('td', recursive=False)
                if not cells:
                    continue
                
                # Première colonne: nom de la ressource/salle
                ressource_elem = cells[0]
                ressource_link = ressource_elem.find('a')
                ressource = ressource_link.get_text(strip=True) if ressource_link else ""
                if not ressource:
                    ressource = ressource_elem.get_text(strip=True)
                
                # Pour p=jour: les colonnes sont des ressources, pas des jours
                # Première colonne = créneau horaire, colonnes suivantes = ressources
                if is_p_jour:
                    # Pour chaque colonne après la première, c'est une ressource
                    for i, cell in enumerate(cells[1:]):
                        if i >= len(ressources_col):
                            break
                        
                        # Le "ressource" dans ce cas devrait être le nom de la colonne
                        current_ressource = ressources_col[i] if i < len(ressources_col) else ressource
                        
                        # Chercher les liens dans la cellule
                        links = cell.find_all('a')
                        
                        if len(links) > 0:
                            logger.debug(f"Ressource {current_ressource[:20]}, jour {date_cible}: {len(links)} événements")
                        
                        for link in links:
                            parent_td = link.find_parent('td')
                            cours = self.extract_cours_from_link(link, parent_td, current_ressource, date_cible)
                            if cours:
                                evenements.append(cours)
                else:
                    # Format normal: colonnes = jours
                    for i, cell in enumerate(cells[1:]):
                        if i >= len(dates):
                            break
                        jour = dates[i]
                        if not jour:
                            continue
                        
                        # Si date_specifique=True, ne garder que cette date
                        if date_specifique and jour != date_cible:
                            continue
                        
                        # Chercher les liens dans la cellule
                        links = cell.find_all('a')
                        
                        # DEBUG: logger le nombre de liens par cellule
                        if len(links) > 0:
                            logger.debug(f"Ressource {ressource[:20]}, jour {jour}: {len(links)} événements")
                        
                        for link in links:
                            # Trouver le td parent pour avoir la classe type*
                            parent_td = link.find_parent('td')
                            cours = self.extract_cours_from_link(link, parent_td, ressource, jour)
                            if cours:
                                evenements.append(cours)
            
            logger.info(f"Extraction terminée: {len(evenements)} événements")
            return evenements
        
        except Exception as e:
            logger.error(f"Erreur scraping: {e}", exc_info=True)
            return []
    
    def recuperer_rooms(self, area=2, date_cible=None):
        """
        Récupère la liste des rooms disponibles pour une area.
        """
        if date_cible is None:
            date_cible = date.today()
        
        url = self.URL_BASE
        params = {
            'p': 'jour',
            'area': area,
            'year': date_cible.year,
            'month': date_cible.month,
            'day': date_cible.day
        }
        
        try:
            logger.info(f"Récupération rooms: area={area}")
            response = self.session.get(url, params=params)
            response.raise_for_status()
            soup = BeautifulSoup(response.content, 'html.parser')
            
            room_select = soup.select_one('select[name="room"]')
            if not room_select:
                return []
            
            rooms = []
            options = room_select.find_all('option')
            for opt in options:
                href = opt.get('value', '')
                if not href or 'room=' not in href:
                    continue
                
                import urllib.parse
                parsed = urllib.parse.urlparse(href)
                qp = urllib.parse.parse_qs(parsed.query)
                
                room_id = int(qp.get('room', [0])[0]) if 'room' in qp else 0
                room_nom = opt.get_text(strip=True)
                
                if room_id > 0:
                    rooms.append({'id': room_id, 'nom': room_nom})
            
            return rooms
        
        except Exception as e:
            logger.error(f"Erreur récupération rooms: {e}")
            return []


def recuperer_emploi_du_temps(area=2, room=None, date_cible=None):
    """
    Fonction de compatibilité.
    Retourne les cours pour la semaine contenant date_cible.
    """
    extracteur = ExtracteurUPGC()
    return extracteur.recuperer_emploi_du_temps(area=area, room=room, date_cible=date_cible, date_specifique=False)


def synchroniser_cours(area=2, room=None, date_cible=None):
    """
    Synchronise les cours dans la base de données.
    """
    extracteur = ExtracteurUPGC()
    evts = extracteur.recuperer_emploi_du_temps(area=area, room=room, date_cible=date_cible, date_specifique=False)
    
    count = 0
    for evt in evts:
        Cours.objects.update_or_create(
            jour=evt['jour'],
            horaire=evt['horaire'],
            ressource=evt['ressource'],
            defaults={
                'type_cours': evt['type_cours'],
                'enseignant': evt['enseignant'],
                'intitule': evt['intitule'],
                'niveau': evt['niveau'],
                'salle': evt['salle']
            }
        )
        count += 1
    print(f"Import {count} cours")


def recuperer_rooms(area=2, date_cible=None):
    """
    Récupère la liste des rooms disponibles pour une area.
    """
    if date_cible is None:
        date_cible = date.today()
    
    extracteur = ExtracteurUPGC()
    return extracteur.recuperer_rooms(area, date_cible)
