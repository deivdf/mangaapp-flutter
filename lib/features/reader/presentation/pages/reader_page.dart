import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mangaapp/features/data/api_consults.dart';
import 'package:mangaapp/features/models/model_chapeter.dart';
import 'package:mangaapp/features/models/model_chapter_image.dart';
import '../widgets/navegation_controls.dart';
import '../widgets/reader_app_bar.dart';
import '../widgets/page_indicator.dart';

class ReaderPage extends StatefulWidget {
  final Chapter chapter;
  final String mangaTitle;

  const ReaderPage({
    super.key,
    required this.chapter,
    required this.mangaTitle,
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final MangadexService _apiService = MangadexService();
  final PageController _pageController = PageController();

  ChapterImages? chapterImages;
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 0;
  bool useDataSaver = false;
  bool showControls = true;

  @override
  void initState() {
    super.initState();
    _loadChapterImages();
    _setFullScreen();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _exitFullScreen();
    super.dispose();
  }

  void _setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _loadChapterImages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final images = await _apiService.getChapterImages(widget.chapter.id);

      setState(() {
        chapterImages = images;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error cargando imágenes: $e';
        isLoading = false;
      });
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void _toggleControls() {
    setState(() {
      showControls = !showControls;
    });
  }

  void _toggleQuality() {
    setState(() {
      useDataSaver = !useDataSaver;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(useDataSaver ? 'Calidad reducida' : 'Calidad normal'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _goToNextPage() {
    if (currentPage < (chapterImages?.totalPages ?? 0) - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: showControls
          ? ReaderAppBar(
              mangaTitle: widget.mangaTitle,
              chapterNumber: widget.chapter.chapter ?? '?',
              useDataSaver: useDataSaver,
              onQualityToggle: _toggleQuality,
            )
          : null,
      body: GestureDetector(onTap: _toggleControls, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Cargando capítulo...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadChapterImages,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (chapterImages == null || chapterImages!.totalPages == 0) {
      return const Center(
        child: Text(
          'No hay páginas disponibles',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // Visor de páginas
        PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: chapterImages!.totalPages,
          itemBuilder: (context, index) {
            return _buildPage(index);
          },
        ),

        // Controles de navegación
        if (showControls)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavigationControls(
              currentPage: currentPage,
              totalPages: chapterImages!.totalPages,
              onPreviousPage: _goToPreviousPage,
              onNextPage: _goToNextPage,
            ),
          ),

        // Indicador de página
        if (showControls)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: PageIndicator(
              currentPage: currentPage,
              totalPages: chapterImages!.totalPages,
            ),
          ),
      ],
    );
  }

  Widget _buildPage(int index) {
    final imageUrl = chapterImages!.getImageUrl(index, dataSaver: useDataSaver);

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Página ${index + 1}...',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error cargando imagen',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
