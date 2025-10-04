import 'package:flutter/material.dart';
import 'package:mangaapp/features/manga/presentation/widgets/chapeter_section.dart';
import 'package:mangaapp/features/manga/presentation/widgets/manga_cover_header.dart';
import 'package:mangaapp/features/manga/presentation/widgets/manga_description_section.dart';
import 'package:mangaapp/features/models/model_manga.dart';
import 'package:mangaapp/features/models/model_chapeter.dart';

class MangaDetailsPage extends StatelessWidget {
  final Manga manga;

  const MangaDetailsPage({super.key, required this.manga});

  void _onChapterTap(BuildContext context, Chapter chapter) {
    // TODO: Navegar al lector de capítulos
    print('Abrir capítulo: ${chapter.id}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo capítulo ${chapter.chapter}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(manga.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            tooltip: 'Agregar a favoritos',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de favoritos próximamente'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir',
            onPressed: () {
              // TODO: Implementar compartir
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada
            MangaCoverHeader(imageUrl: manga.getCoverUrl()),

            const SizedBox(height: 16),

            // Descripción
            MangaDescriptionSection(
              title: manga.title,
              description: manga.description ?? 'Sin descripción disponible',
              tags: manga.tags,
            ),

            const SizedBox(height: 24),

            const Divider(thickness: 1),

            // Sección de capítulos (Widget independiente)
            ChaptersSection(
              mangaId: manga.id,
              onChapterTap: (chapter) => _onChapterTap(context, chapter),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
