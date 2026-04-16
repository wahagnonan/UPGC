class Cours {
  final int id;
  final String horaire;
  final String typeCours;
  final String enseignant;
  final String intitule;
  final String niveau;
  final String salle;
  final String jour;
  final String ressource;
  final String dateImport;

  Cours({
    required this.id,
    required this.horaire,
    required this.typeCours,
    required this.enseignant,
    required this.intitule,
    required this.niveau,
    required this.salle,
    required this.jour,
    required this.ressource,
    required this.dateImport,
  });

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['id'] ?? 0,
      horaire: json['horaire'] ?? '',
      typeCours: json['type_cours'] ?? '',
      enseignant: json['enseignant'] ?? '',
      intitule: json['intitule'] ?? '',
      niveau: json['niveau'] ?? '',
      salle: json['salle'] ?? '',
      jour: json['jour'] ?? '',
      ressource: json['ressource'] ?? '',
      dateImport: json['date_import'] ?? '',
    );
  }
}

class ReponseEmploiDuTemps {
  final String date;
  final String jourSemaine;
  final dynamic area;
  final String source;
  final String timestamp;
  final int nombreEvenements;
  final List<Cours> donnees;

  ReponseEmploiDuTemps({
    required this.date,
    required this.jourSemaine,
    required this.area,
    required this.source,
    required this.timestamp,
    required this.nombreEvenements,
    required this.donnees,
  });

  factory ReponseEmploiDuTemps.fromJson(Map<String, dynamic> json) {
    return ReponseEmploiDuTemps(
      date: json['date'] ?? '',
      jourSemaine: json['jour_semaine'] ?? '',
      area: json['area'] ?? 0,
      source: json['source'] ?? '',
      timestamp: json['timestamp'] ?? '',
      nombreEvenements: json['nombre_evenements'] ?? 0,
      donnees:
          (json['donnees'] as List<dynamic>?)
              ?.map((e) => Cours.fromJson(e))
              .toList() ??
          [],
    );
  }
}
