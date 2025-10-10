class Manga {
  final String id;
  final String title;
  final String? description;
  final List<String> tags;
  final String? coverFileName;
  final int? total;

  Manga({
    required this.id,
    required this.title,
    this.description,
    required this.tags,
    this.coverFileName,
    this.total,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];

    // Extract title
    final titleMap = attributes['title'] as Map<String, dynamic>;
    final title =
        titleMap['en'] ??
        titleMap['es'] ??
        titleMap['ja-ro'] ??
        (titleMap.values.isNotEmpty ? titleMap.values.first : 'Sin título');

    // Extract description
    final descMap = attributes['description'] as Map<String, dynamic>? ?? {};
    final description =
        descMap['en'] ??
        descMap['es'] ??
        descMap['ja-ro'] ??
        (descMap.values.isNotEmpty
            ? descMap.values.firstOrNull
            : 'Sin descripción');

    // Extract tags
    final tagsList = attributes['tags'] as List? ?? [];
    final tags = tagsList
        .map((tag) => tag['attributes']['name']['en'] as String)
        .toList();
    // Extract cover filename from relationships
    String? coverFileName;
    final relationships = json['relationships'] as List? ?? [];
    for (var rel in relationships) {
      if (rel['type'] == 'cover_art') {
        coverFileName = rel['attributes']?['fileName'];
        break;
      }
    }

    return Manga(
      id: json['id'],
      title: title,
      description: description,
      tags: tags,
      coverFileName: coverFileName,
      total: attributes['total'] as int?,
    );
  }

  // Make URL of the cover
  String getCoverUrl({int size = 512}) {
    if (coverFileName == null) return '';
    return 'https://uploads.mangadex.org/covers/$id/$coverFileName';
  }
}
