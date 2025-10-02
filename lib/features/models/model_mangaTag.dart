class MangaTag {
  final String id;
  final String name;
  final String group;

  MangaTag({required this.id, required this.name, required this.group});

  factory MangaTag.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    final nameMap = attributes['name'] as Map<String, dynamic>;

    return MangaTag(
      id: json['id'],
      name: nameMap['en'] ?? nameMap.values.first,
      group: attributes['group'] ?? 'other',
    );
  }
}
