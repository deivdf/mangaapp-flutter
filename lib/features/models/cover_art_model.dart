class CoverArtModel {
  final String id;
  final String fileName;
  final String? description;
  final String? volume;
  final String mangaId;

  CoverArtModel({
    required this.id,
    required this.fileName,
    this.description,
    this.volume,
    required this.mangaId,
  });

  factory CoverArtModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];

    //extrating id for realtionship
    String mangaId = '';
    final relationships = json['relationships'] as List? ?? [];

    for (var rel in relationships) {
      if (rel['type'] == 'manga') {
        mangaId = rel['id'];
        break;
      }
    }

    return CoverArtModel(
      id: json['id'],
      fileName: attributes['fileName'],
      description: attributes['description'],
      volume: attributes['volume'],
      mangaId: mangaId,
    );
  }
  String getCoverUrl({int? size}) {
    String url = 'https://api.mangadex.org/covers/$id/$fileName';
    if (size != null) {
      url += '?size=$size';
    }
    return url;
  }
}
