class Chapterpage {
  final String baseUrl;
  final String hash;
  final List<String> data;
  final List<String> dataSaver;

  Chapterpage({
    required this.baseUrl,
    required this.hash,
    required this.data,
    required this.dataSaver,
  });

  factory Chapterpage.fromJson(Map<String, dynamic> json) {
    final chapter = json['chapter'];
    return Chapterpage(
      baseUrl: chapter['baseUrl'],
      hash: chapter['hash'],
      data: List<String>.from(chapter['data'] ?? []),
      dataSaver: List<String>.from(chapter['dataSaver'] ?? []),
    );
  }

  List<String> getPageUrls({bool dataSaver = false}) {
    final quality = dataSaver ? 'data-saver' : 'data';
    final files = dataSaver ? this.dataSaver : data;

    return files.map((filename) {
      return '$baseUrl/$quality/$filename';
    }).toList();
  }

  String getPageUrl(int pageIdex, {bool dataSaver = false}) {
    final urls = getPageUrls(dataSaver: dataSaver);
    if (pageIdex >= 0 && pageIdex < urls.length) {
      return urls[pageIdex];
    }
    throw Exception('indice de pagina no valido $pageIdex');
  }

  int get totalPages => data.length;
}
