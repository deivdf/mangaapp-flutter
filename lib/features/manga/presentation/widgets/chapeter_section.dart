// lib/features/manga/presentation/widgets/chapters_section.dart
import 'package:flutter/material.dart';
import 'package:mangaapp/features/manga/presentation/widgets/chapeter_error_state.dart';
import 'package:mangaapp/features/manga/presentation/widgets/chapeter_list_item.dart';
import 'package:mangaapp/features/manga/presentation/widgets/languaje_selector_selector.dart';
import 'package:mangaapp/features/models/model_chapeter.dart';
import 'package:mangaapp/features/data/api_consults.dart';
import 'package:mangaapp/features/shared/widgets/lightweight_skeleton.dart';
import 'package:mangaapp/features/shared/widgets/skeleton_widgets.dart';

class ChaptersSection extends StatefulWidget {
  final String mangaId;
  final Function(Chapter)? onChapterTap;

  const ChaptersSection({super.key, required this.mangaId, this.onChapterTap});

  @override
  State<ChaptersSection> createState() => _ChaptersSectionState();
}

class _ChaptersSectionState extends State<ChaptersSection> {
  static const bool useUltraLightSkeletons = false;
  final MangadexService _apiService = MangadexService();

  List<Chapter>? chapters;
  bool isLoading = true;
  String selectedLanguage = 'es';
  String? errorMessage;
  int loadedChapters = 0;
  int totalChapters = 0;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      loadedChapters = 0;
      totalChapters = 0;
    });

    try {
      final chapterList = await _apiService.getAllMangaChapters(
        widget.mangaId,
        languages: [selectedLanguage],
        orderVolume: 'asc',
        orderChapter: 'asc',
        onProgress: (current, total) {
          setState(() {
            loadedChapters = current;
            totalChapters = total;
          });
        },
      );

      setState(() {
        chapters = chapterList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error cargando capítulos: $e';
        isLoading = false;
      });
    }
  }

  void _showLanguageDialog() {
    LanguageSelectorDialog.show(
      context,
      selectedLanguage: selectedLanguage,
      onLanguageSelected: (language) {
        setState(() {
          selectedLanguage = language;
        });
        _loadChapters();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return ChapterErrorState(
        errorMessage: errorMessage!,
        onRetry: _loadChapters,
      );
    }

    if (isLoading) {
      if (useUltraLightSkeletons) {
        return const UltraLightChapterLoading();
      } else {
        return ChapterLoadingSkeleton(
          showProgress: totalChapters > 0,
          itemCount: 3,
        );
      }
    }

    return ChapterListItem(
      chapters: chapters,
      isLoading: false,
      selectedLanguage: selectedLanguage,
      onLanguageChange: _showLanguageDialog,
      onChapterTap: widget.onChapterTap,
      groupByVolume: true,
    );
  }
}
