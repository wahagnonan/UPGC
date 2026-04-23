import logging
import json
from datetime import date
from django.core.cache import cache
from .scraping import ExtracteurUPGC

logger = logging.getLogger(__name__)

AREAS_KEY = "areas_dynamic"
ROOMS_KEY_PREFIX = "rooms_area_"
REDIS_TTL = 86400


def sync_areas_from_grr():
    """
    Scrape areas and rooms from GRR and store in Redis.
    Returns dict with areas, rooms_par_area.
    """
    from .data import AREAS as AREAS_STATIC, ROOMS_PAR_AREA as ROOMS_STATIC
    
    extracteur = ExtracteurUPGC()
    scraped_areas = []
    rooms_par_area = {}
    
    try:
        logger.info("Starting sync of areas from GRR...")
        
        area_ids = [a['id'] for a in AREAS_STATIC]
        
        for area_id in area_ids:
            try:
                rooms = extracteur.recuperer_rooms(area=area_id, date_cible=date.today())
                if rooms:
                    rooms_par_area[area_id] = rooms
                    logger.info(f"Area {area_id}: {len(rooms)} rooms")
            except Exception as e:
                logger.error(f"Error scraping area {area_id}: {e}")
                if area_id in ROOMS_STATIC:
                    rooms_par_area[area_id] = ROOMS_STATIC[area_id]
        
        scraped_areas = [
            {'id': a['id'], 'nom': a['nom']}
            for a in AREAS_STATIC
            if a['id'] in rooms_par_area
        ]
        
        cache.set(AREAS_KEY, json.dumps(scraped_areas), REDIS_TTL)
        
        for area_id, rooms in rooms_par_area.items():
            cache.set(f"{ROOMS_KEY_PREFIX}{area_id}", json.dumps(rooms), REDIS_TTL)
        
        logger.info(f"Sync complete: {len(scraped_areas)} areas, {sum(len(r) for r in rooms_par_area.values())} rooms")
        
        return {
            'areas': scraped_areas,
            'rooms_par_area': rooms_par_area,
            'source': 'redis',
            'timestamp': date.today().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Sync failed: {e}")
        return None


def get_areas():
    """
    Get areas list - from Redis or fallback to static data.
    """
    from .data import AREAS as AREAS_STATIC
    
    try:
        cached = cache.get(AREAS_KEY)
        if cached:
            return json.loads(cached)
    except Exception:
        pass
    
    return AREAS_STATIC


def get_rooms_for_area(area_id):
    """
    Get rooms for a specific area - from Redis or fallback to static data.
    """
    from .data import ROOMS_PAR_AREA as ROOMS_STATIC
    
    try:
        cached = cache.get(f"{ROOMS_KEY_PREFIX}{area_id}")
        if cached:
            return json.loads(cached)
    except Exception:
        pass
    
    return ROOMS_STATIC.get(area_id, [])


def get_all_rooms():
    """
    Get all rooms combined from Redis or fallback.
    """
    from .data import AREAS_PAR_DEFAUT, ROOMS_PAR_AREA as ROOMS_STATIC
    
    areas = get_areas()
    area_ids = [a['id'] for a in areas]
    
    rooms = []
    for area_id in area_ids:
        area_rooms = get_rooms_for_area(area_id)
        if area_rooms:
            for r in area_rooms:
                r['area'] = area_id
            rooms.extend(area_rooms)
    
    if not rooms:
        for area_id in AREAS_PAR_DEFAUT:
            static_rooms = ROOMS_STATIC.get(area_id, [])
            for r in static_rooms:
                r['area'] = area_id
            rooms.extend(static_rooms)
    
    return rooms


def get_rooms_par_area():
    """
    Get all rooms grouped by area - from Redis or fallback.
    """
    from .data import ROOMS_PAR_AREA as ROOMS_STATIC
    
    areas = get_areas()
    rooms_par_area = {}
    
    for area in areas:
        area_id = area['id']
        rooms = get_rooms_for_area(area_id)
        if rooms:
            rooms_par_area[area_id] = rooms
        elif area_id in ROOMS_STATIC:
            rooms_par_area[area_id] = ROOMS_STATIC[area_id]
    
    return rooms_par_area


def force_sync():
    """
    Force full sync from GRR.
    """
    logger.info("Forcing full sync from GRR...")
    result = sync_areas_from_grr()
    if result:
        logger.info("Forced sync completed successfully")
    return result