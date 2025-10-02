import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mangaapp/features/models/model_manga.dart';
import 'package:mangaapp/features/models/model_mangaTag.dart';

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

  // Get recommended mangas (updated recently)
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

  Future<List<MangaTag>> getAlltags() async {
    try {
      final uri = Uri.parse('$baseUrl/manga/tag');
      print('Obteniendo tags...');
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      print('Tags obtenidos ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Tags obtenidos: ${data['data'].length}');
        final tagList = (data['data'] as List)
            .map((json) => MangaTag.fromJson(json))
            .toList();
        return tagList;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener tags: $e');
    }
  }

  Future<List<Manga>> searchMangas({
    String? title,
    List<String>? includedTags,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        'contentRating[]': ['safe', 'suggestive'],
        'includes[]': 'cover_art',
        'order[relevance]': 'desc',
      };

      // Agregar título si existe
      if (title != null && title.isNotEmpty) {
        queryParams['title'] = title;
      }

      // Agregar tags si existen
      if (includedTags != null && includedTags.isNotEmpty) {
        queryParams['includedTags[]'] = includedTags;
      }

      final uri = Uri.parse(
        '$baseUrl/manga',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mangaList = <Manga>[];
        final dataList = data['data'] as List? ?? [];

        for (var mangaJson in dataList) {
          try {
            final manga = Manga.fromJson(mangaJson);
            mangaList.add(manga);
          } catch (e) {
            print('❌ Error parseando manga: $e');
          }
        }

        return mangaList;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al buscar mangas: $e');
    }
  }
}
