from django.contrib import admin
from .models import Cours, Information

@admin.register(Cours)
class CoursAdmin(admin.ModelAdmin):
    list_display = ('jour', 'horaire', 'intitule', 'type_cours', 'niveau', 'enseignant')
    list_filter = ('jour', 'type_cours', 'niveau')
    search_fields = ('intitule', 'enseignant', 'salle')
    ordering = ('-jour', 'horaire')

@admin.register(Information)
class InformationAdmin(admin.ModelAdmin):
    list_display = ('titre', 'date_publication', 'date_expiration')
    list_filter = ('date_publication',)
    search_fields = ('titre', 'description')
    ordering = ('-date_publication',)
