from django.db import models

class Cours(models.Model):
    """Modèle représentant un cours dans l'emploi du temps"""
    # Informations extraites
    horaire = models.CharField('Horaire', max_length=50)  # ex: "07:30 à 11:30"
    type_cours = models.CharField('Type de cours', max_length=100)  # CM, TD, TP, EXAMEN
    enseignant = models.CharField('Enseignant(s)', max_length=300)  # peut être multiple
    intitule = models.TextField('Intitulé du cours')
    niveau = models.CharField('Niveau', max_length=100)  # ex: "L1 BIO"
    salle = models.CharField('Salle', max_length=50)  # ex: "AMPHI B"
    jour = models.DateField('Jour du cours', db_index=True)
    ressource = models.CharField('Ressource (salle principale)', max_length=100)  # ex: "Amphi B"
    date_import = models.DateTimeField('Date d\'import', auto_now_add=True)

    class Meta:
        verbose_name = 'Cours'
        verbose_name_plural = 'Cours'
        ordering = ['jour', 'horaire']

    def __str__(self):
        return f"{self.jour} {self.horaire} - {self.intitule[:50]}"



class Information(models.Model):

    titre = models.CharField('Titre', max_length=200)
    image = models.ImageField('Image', upload_to='informations/', null=True, blank=True)
    description = models.TextField('Description')
    date_publication = models.DateTimeField('Date de publication', auto_now_add=True)
    date_expiration = models.DateTimeField('Date d\'expiration', null=True, blank=True)
    
    class Meta:
        verbose_name = 'Information'
        verbose_name_plural = 'Informations'
        ordering = ['-date_publication']

    def __str__(self):
        return self.titre
