from rest_framework import serializers
from .models import Cours, Information

class CoursSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cours
        fields = '__all__'
        extra_kwargs = {
            'niveau': {'required': False, 'allow_blank': True},
            'salle': {'required': False, 'allow_blank': True},
            'enseignant': {'required': False, 'allow_blank': True},
            'type_cours': {'required': False, 'allow_blank': True},
            'intitule': {'required': False, 'allow_blank': True},
        }

class InformationSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Information
        fields = ['id', 'titre', 'image', 'image_url', 'description', 'date_publication', 'date_expiration']
        extra_kwargs = {
            'image': {'required': False, 'allow_null': True},
            'date_expiration': {'required': False, 'allow_null': True},
        }

    def get_image_url(self, obj):
        if obj.image:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.image.url)
            return f"/media/{obj.image.name}"
        return None

class EmploiDuTempsJourResponseSerializer(serializers.Serializer):
    date = serializers.DateField()
    jour_semaine = serializers.CharField()
    area = serializers.IntegerField()
    source = serializers.CharField()
    timestamp = serializers.DateTimeField()
    nombre_evenements = serializers.IntegerField()
    donnees = CoursSerializer(many=True)

class EmploiDuTempsSemaineResponseSerializer(serializers.Serializer):
    semaine = serializers.DictField()
    area = serializers.IntegerField()
    nombre_total_evenements = serializers.IntegerField()
    jours = serializers.ListField()
    timestamp = serializers.DateTimeField()

class ErreurResponseSerializer(serializers.Serializer):
    erreur = serializers.CharField()
    code = serializers.IntegerField()
    details = serializers.DictField(required=False)
    timestamp = serializers.DateTimeField()