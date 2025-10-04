import 'package:http/http.dart' as http;
import 'package:mangaapp/features/models/cover_art_model.dart';
import 'package:mangaapp/features/models/model_chapeter.dart';
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

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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

  // get manga details for a given manga ID
  Future<Manga> getMangaDetails(String mangaId) async {
    final uri = Uri.parse(
      '$baseUrl/manga/$mangaId',
    ).replace(queryParameters: {'includes[]': 'cover_art'});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Manga.fromJson(data['data']);
    }

    throw Exception('Error obteniendo detalles');
  }

  // get all manga covers
  Future<List<CoverArtModel>> getMangaCover(
    String mangaId, {
    int limit = 100,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/cover').replace(
        queryParameters: {
          'manga[]': mangaId,
          'limit': limit.toString(),
          'order[volume]': 'asc',
        },
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dataList = (data['data'] as List)
            .map((json) => (CoverArtModel.fromJson(json)))
            .toList();

        return dataList;
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener portadas del manga: $e');
    }
  }

  // Obtener TODOS los capítulos con paginación automática
  Future<List<Chapter>> getAllMangaChapters(
    String mangaId, {
    List<String>? languages,
    String orderVolume = 'asc',
    String orderChapter = 'asc',
    Function(int current, int total)? onProgress, // Callback para progreso
  }) async {
    final allChapters = <Chapter>[];
    int offset = 0;
    const int limit = 100; // Tamaño de página (máximo permitido por MangaDex)
    int totalChapters = 0;

    try {
      do {
        print('📥 Cargando capítulos: offset=$offset');

        final queryParams = <String, dynamic>{
          'limit': limit.toString(),
          'offset': offset.toString(),
          'order[volume]': orderVolume,
          'order[chapter]': orderChapter,
          'translatedLanguage[]': languages ?? ['es', 'en'],
          'contentRating[]': ['safe', 'suggestive', 'erotica'],
          'includes[]': ['scanlation_group', 'user'],
        };

        final uri = Uri.parse(
          '$baseUrl/manga/$mangaId/feed',
        ).replace(queryParameters: queryParams);

        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final dataList = data['data'] as List? ?? [];

          // Obtener total de capítulos disponibles
          totalChapters = data['total'] ?? 0;

          // Parsear capítulos de esta página
          for (var chapterJson in dataList) {
            try {
              final chapter = Chapter.fromJson(chapterJson);
              allChapters.add(chapter);
            } catch (e) {
              print('❌ Error parseando capítulo: $e');
            }
          }

          // Reportar progreso
          onProgress?.call(allChapters.length, totalChapters);

          // Si obtuvimos menos capítulos que el límite, ya no hay más
          if (dataList.length < limit) {
            break;
          }

          // Incrementar offset para siguiente página
          offset += limit;

          // Pequeña pausa para no saturar la API (respeto al rate limiting)
          await Future.delayed(const Duration(milliseconds: 250));
        } else {
          throw Exception('Error ${response.statusCode}');
        }
      } while (allChapters.length < totalChapters);

      print('✅ Total de capítulos cargados: ${allChapters.length}');
      return allChapters;
    } catch (e) {
      print('❌ Error obteniendo capítulos: $e');
      // Si hubo error pero ya tenemos algunos capítulos, retornarlos
      if (allChapters.isNotEmpty) {
        return allChapters;
      }
      throw Exception('Error obteniendo capítulos: $e');
    }
  }
}
