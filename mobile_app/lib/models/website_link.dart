import 'package:cloud_firestore/cloud_firestore.dart';

class WebsiteLink {
  final String id;
  final String title;
  final String url;
  final String description;
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  WebsiteLink({
    required this.id,
    required this.title,
    required this.url,
    required this.description,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WebsiteLink.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return WebsiteLink(
      id: doc.id,
      title: data['title'] ?? '',
      url: data['url'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '🌐',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'description': description,
      'icon': icon,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  String toString() {
    return 'WebsiteLink(id: $id, title: $title, url: $url, description: $description, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebsiteLink && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
