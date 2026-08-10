class NarratorProfile {
  const NarratorProfile({
    required this.id,
    required this.name,
    this.fullName = '',
    this.kunyah = '',
    this.title = '',
    this.biography = '',
    this.highlights = const [],
    this.tags = const [],
    this.source = const {},
    this.verified = false,
  });

  final String id;
  final String name;
  final String fullName;
  final String kunyah;
  final String title;
  final String biography;
  final List<String> highlights;
  final List<String> tags;
  final Map<String, dynamic> source;
  final bool verified;

  factory NarratorProfile.fromJson(Map<String, dynamic> json) {
    return NarratorProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      kunyah: json['kunyah'] as String? ?? '',
      title: json['title'] as String? ?? '',
      biography: json['biography'] as String? ?? '',
      highlights: _stringList(json['highlights']),
      tags: _stringList(json['tags']),
      source: _map(json['source']),
      verified: json['verified'] == true,
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return {};
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) return value.whereType<String>().toList();
    return [];
  }
}
