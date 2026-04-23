from django.core.management.base import BaseCommand
from core.sync_areas import sync_areas_from_grr, force_sync, get_areas, get_rooms_par_area


class Command(BaseCommand):
    help = "Synchronise les areas et rooms depuis le site GRR vers Redis"

    def add_arguments(self, parser):
        parser.add_argument(
            '--force',
            action='store_true',
            help='Force un sync complet meme si donnees en cache',
        )

    def handle(self, *args, **options):
        force = options.get('force', False)
        
        self.stdout.write(self.style.WARNING("Demarrage sync areas/rooms..."))
        
        if force:
            result = force_sync()
        else:
            result = sync_areas_from_grr()
        
        if result:
            areas = result.get('areas', [])
            rooms_count = sum(len(r) for r in result.get('rooms_par_area', {}).values())
            
            self.stdout.write(self.style.SUCCESS(
                f"Sync termine: {len(areas)} areas, {rooms_count} rooms"
            ))
            
            self.stdout.write("\nAreas trouvees:")
            for a in areas:
                self.stdout.write(f"  - {a['id']}: {a['nom']}")
            
            self.stdout.write("\nRooms par area:")
            for area_id, rooms in result.get('rooms_par_area', {}).items():
                self.stdout.write(f"  Area {area_id}: {len(rooms)} rooms")
        else:
            self.stdout.write(self.style.ERROR("Echec du sync"))
            return
        
        test_areas = get_areas()
        test_rooms = get_rooms_par_area()
        
        self.stdout.write(self.style.SUCCESS(
            f"\nVerification: {len(test_areas)} areas, {len(test_rooms)} areas avec rooms"
        ))