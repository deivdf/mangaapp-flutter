class Chapter {
  final String id;
  final String? chapter;
  final String? title;
  final String? volume;
  final String translatedLanguage;
  final DateTime? publishAt;
  final int pages;
  final String? scanlationGroup; // Agregar esto

  Chapter({
    required this.id,
    this.chapter,
    this.title,
    this.volume,
    required this.translatedLanguage,
    this.publishAt,
    required this.pages,
    this.scanlationGroup,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];

    // Extraer grupo de scanlation de las relaciones
    String? scanlationGroup;
    final relationships = json['relationships'] as List? ?? [];
    for (var rel in relationships) {
      if (rel['type'] == 'scanlation_group') {
        scanlationGroup = rel['attributes']?['name'];
        break;
      }
    }

    return Chapter(
      id: json['id'],
      chapter: attributes['chapter'],
      title: attributes['title'],
      volume: attributes['volume'],
      translatedLanguage: attributes['translatedLanguage'],
      publishAt: attributes['publishAt'] != null
          ? DateTime.parse(attributes['publishAt'])
          : null,
      pages: attributes['pages'] ?? 0,
      scanlationGroup: scanlationGroup,
    );
  }
}
