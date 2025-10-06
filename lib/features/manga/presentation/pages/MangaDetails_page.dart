import 'package:flutter/material.dart';
import 'package:mangaapp/features/manga/presentation/widgets/chapeter_section.dart';
import 'package:mangaapp/features/manga/presentation/widgets/manga_cover_header.dart';
import 'package:mangaapp/features/manga/presentation/widgets/manga_description_section.dart';
import 'package:mangaapp/features/models/model_manga.dart';
import 'package:mangaapp/features/models/model_chapeter.dart';
import 'package:mangaapp/features/reader/presentation/pages/reader_page.dart';

class MangaDetailsPage extends StatelessWidget {
  final Manga manga;

  const MangaDetailsPage({super.key, required this.manga});

  void _onChapterTap(BuildContext context, Chapter chapter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChapterReaderPage(chapter: chapter, mangaTitle: manga.title),
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
            MangaCoverHeader(imageUrl: manga.getCoverUrl()),

            const SizedBox(height: 16),

            MangaDescriptionSection(
              title: manga.title,
              description: manga.description ?? 'Sin descripción disponible',
              tags: manga.tags,
            ),

            const SizedBox(height: 24),

            const Divider(thickness: 1),

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
