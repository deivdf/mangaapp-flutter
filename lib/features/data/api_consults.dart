import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mangaapp/features/models/model_manga.dart';

class MangadexService {
  static const String baseUrl = 'https://api.mangadex.org';

  Future<List<Manga>> getPopularMangas({int limit = 10, int offset = 0}) async {
    final params = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      'order[rating]': 'desc', // Ordenar por rating descendente
      'order[followedCount]': 'desc', // Ordenar por follows
      'contentRating[]': ['safe', 'suggestive'], // Filtrar contenido
      'includes[]': ['cover_art', 'author', 'artist'], // Incluir relaciones
    };

    final uri = Uri.parse('$baseUrl/manga').replace(queryParameters: params);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final mangaList = (data['data'] as List)
            .map((json) => Manga.fromJson(json))
            .toList();

        return mangaList;
      } else {
        throw Exception('Failed to load popular mangas');
      }
    } catch (e) {
      throw Exception('Error fetching popular mangas: $e');
    }
  }

  // Obtener mangas recomendados (actualizados recientemente)
  Future<List<Manga>> getRecommendedMangas({int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/manga').replace(
        queryParameters: {
          'limit': limit.toString(),
          'order[updatedAt]': 'desc',
          'contentRating[]': ['safe', 'suggestive'],
          'includes[]': 'cover_art',
          'hasAvailableChapters': 'true',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('aqui trae los datos de recomendados $data');
        final mangaList = (data['data'] as List)
            .map((json) => Manga.fromJson(json))
            .toList();

        return mangaList;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener recomendados: $e');
    }
  }
}
