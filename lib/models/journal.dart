class Journal {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Journal({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.locationName,
    this.latitude,
    this.longitude,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      locationName: json['location_name'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
