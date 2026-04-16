class Information {
  final int id;
  final String titre;
  final String? image;
  final String? imageUrl;
  final String description;
  final String datePublication;
  final String? dateExpiration;

  Information({
    required this.id,
    required this.titre,
    this.image,
    this.imageUrl,
    required this.description,
    required this.datePublication,
    this.dateExpiration,
  });

  String? get displayImage => imageUrl ?? image;

  factory Information.fromJson(Map<String, dynamic> json) {
    return Information(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? '',
      image: json['image'],
      imageUrl: json['image_url'],
      description: json['description'] ?? '',
      datePublication: json['date_publication'] ?? '',
      dateExpiration: json['date_expiration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'image': image,
      'description': description,
      'date_expiration': dateExpiration,
    };
  }
}
