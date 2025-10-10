import 'package:dio/dio.dart';
import 'package:mangaapp/features/models/cover_art_model.dart';
import 'package:mangaapp/features/models/model_chapeter.dart';
import 'package:mangaapp/features/models/model_chapter_image.dart';
import 'package:mangaapp/features/models/model_manga.dart';
import 'package:mangaapp/features/models/model_mangaTag.dart';
import 'package:mangaapp/network/dio_client.dart';

class MangadexService {
  final Dio _dio = DioClient.dio;
  static const String baseUrl = 'https://api.mangadex.org';

  Future<List<Manga>> getPopularMangas({int limit = 10, int offset = 0}) async {
    final params = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      'order[rating]': 'desc', // Order for rating descendent
      'order[followedCount]': 'desc', // Order for follows
      'contentRating[]': ['safe', 'suggestive'], // Filter content
      'includes[]': ['cover_art', 'author', 'artist'], // Include relationships
    };

    final uri = Uri.parse('$baseUrl/manga').replace(queryParameters: params);

    try {
      final response = await _dio.get('$uri');

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;

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
  Future<List<Manga>> getRecommendedMangas({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/manga').replace(
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
          'order[updatedAt]': 'desc',
          'contentRating[]': ['safe', 'suggestive'],
          'includes[]': 'cover_art',
          'hasAvailableChapters': 'true',
        },
      );

      final response = await _dio.get('$uri');
      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;
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

      final response = await _dio.get(
        '$uri',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;
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

      // add title if exists
      if (title != null && title.isNotEmpty) {
        queryParams['title'] = title;
      }

      // add tags if exists
      if (includedTags != null && includedTags.isNotEmpty) {
        queryParams['includedTags[]'] = includedTags;
      }

      final uri = Uri.parse(
        '$baseUrl/manga',
      ).replace(queryParameters: queryParams);

      final response = await _dio.get('$uri');

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;
        final mangaList = <Manga>[];
        final dataList = data['data'] as List? ?? [];

        for (var mangaJson in dataList) {
          try {
            final manga = Manga.fromJson(mangaJson);
            mangaList.add(manga);
          } catch (e) {
            throw Exception('Error parseando manga: $e');
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

    final response = await _dio.get('$uri');

    if (response.statusCode == 200 || response.statusCode == 304) {
      final data = response.data;
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
      final response = await _dio.get('$uri');

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;
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

  // get TODOS the chapters with pagination auto
  Future<List<Chapter>> getAllMangaChapters(
    String mangaId, {
    List<String>? languages,
    String orderVolume = 'asc',
    String orderChapter = 'asc',
    Function(int current, int total)? onProgress, // Callback for progress
  }) async {
    final allChapters = <Chapter>[];
    int offset = 0;
    const int limit = 100; //size of page permit for the mangadexapi
    int totalChapters = 0;

    try {
      do {
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

        final response = await _dio.get('$uri');

        if (response.statusCode == 200 || response.statusCode == 304) {
          final data = response.data;
          final dataList = data['data'] as List? ?? [];

          totalChapters = data['total'] ?? 0;

          //parser chapters
          for (var chapterJson in dataList) {
            try {
              final chapter = Chapter.fromJson(chapterJson);
              allChapters.add(chapter);
            } catch (e) {
              throw Exception('Error parseando capítulo: $e');
            }
          }

          // Repor progres
          onProgress?.call(allChapters.length, totalChapters);

          // if get less chapters than the limit, and not more
          if (dataList.length < limit) {
            break;
          }

          // Increment offset for next page
          offset += limit;

          // Sleep for a short duration to avoid overwhelming the API (respecting rate limiting)
          await Future.delayed(const Duration(milliseconds: 250));
        } else {
          throw Exception('Error ${response.statusCode}');
        }
      } while (allChapters.length < totalChapters);

      return allChapters;
    } catch (e) {
      if (allChapters.isNotEmpty) {
        return allChapters;
      }
      throw Exception('Error obteniendo capítulos: $e');
    }
  }

  Future<ChapterImages> getChapterImages(String chapterId) async {
    try {
      final uri = Uri.parse(
        'https://api.mangadex.org/at-home/server/$chapterId',
      );

      final response = await _dio.get('$uri');

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = response.data;
        final chapterImages = ChapterImages.fromJson(data);

        return chapterImages;
      } else if (response.statusCode == 404) {
        throw Exception('Capítulo no encontrado');
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error obteniendo imágenes del capítulo: $e');
    }
  }
}
