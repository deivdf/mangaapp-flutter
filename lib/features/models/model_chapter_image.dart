class ChapterImages {
  final String baseUrl;
  final String chapterHash;
  final List<String> data;
  final List<String> dataSaver;

  ChapterImages({
    required this.baseUrl,
    required this.chapterHash,
    required this.data,
    required this.dataSaver,
  });

  factory ChapterImages.fromJson(Map<String, dynamic> json) {
    return ChapterImages(
      baseUrl: json['baseUrl'],
      chapterHash: json['chapter']['hash'],
      data: List<String>.from(json['chapter']['data'] ?? []),
      dataSaver: List<String>.from(json['chapter']['dataSaver'] ?? []),
    );
  }

  /// Construir URL de imagen de calidad normal o data-saver
  List<String> getImageUrls({bool dataSaver = false}) {
    final images = dataSaver ? this.dataSaver : data;
    final quality = dataSaver ? 'data-saver' : 'data';

    return images
        .map((filename) => '$baseUrl/$quality/$chapterHash/$filename')
        .toList();
  }

  /// Obtener una sola imagen por índice
  String getImageUrl(int index, {bool dataSaver = false}) {
    final images = dataSaver ? this.dataSaver : data;
    final quality = dataSaver ? 'data-saver' : 'data';

    if (index < 0 || index >= images.length) {
      throw RangeError('Índice fuera de rango');
    }

    return '$baseUrl/$quality/$chapterHash/${images[index]}';
  }

  /// Total de páginas disponibles
  int get totalPages => data.length;
}
