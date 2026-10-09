class FavoritePlace {
  const FavoritePlace({
    required this.id, required this.name, required this.category,
    required this.description, required this.latitude, required this.longitude,
    this.photoPath,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String? photoPath;

  factory FavoritePlace.fromMap(Map<String, dynamic> map) => FavoritePlace(
    id: map['id'].toString(), name: map['name'] as String,
    category: map['category'] as String, description: map['description'] as String? ?? '',
    latitude: (map['latitude'] as num).toDouble(), longitude: (map['longitude'] as num).toDouble(),
    photoPath: map['photo_path'] as String?,
  );
}
