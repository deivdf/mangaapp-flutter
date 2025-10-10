import 'package:flutter/material.dart';
import 'package:mangaapp/features/data/api_consults.dart';
import 'package:mangaapp/features/manga/presentation/pages/MangaDetails_page.dart';
import 'package:mangaapp/features/models/model_manga.dart';
import 'package:mangaapp/features/shared/widgets/skeleton_widgets.dart';
import 'package:mangaapp/features/shared/widgets/lightweight_skeleton.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MangadexService _apiService = MangadexService();
  final ScrollController _scrollController =
      ScrollController(); // ← Controla el scroll principal

  bool _isLoadingRecommended = true;
  bool _isLoadingPopular = true;

  List<Manga> _recommendedMangas = [];
  List<Manga> _popularMangas = [];
  bool _isLoadingMore = false;
  bool _hasMorePopular = true;
  int _popularOffset = 0;
  final int _pageSize = 20;

  String? _recommendedError;
  String? _popularError;

  static const bool useUltraLightSkeletons = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ Método separado para el listener
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = 200.0;

    if (currentScroll >= maxScroll - threshold &&
        _hasMorePopular &&
        !_isLoadingMore &&
        !_isLoadingPopular) {
      print('🔄 Cargando más mangas populares...');
      _loadMorePopularMangas();
    }
  }

  Future<void> _loadData() async {
    // Resetear estado al hacer pull-to-refresh
    setState(() {
      _popularOffset = 0;
      _hasMorePopular = true;
      _popularMangas.clear();
    });

    await Future.wait([_loadRecommendedMangas(), _loadPopularMangas()]);
  }

  Future<void> _loadRecommendedMangas() async {
    try {
      final mangas = await _apiService.getRecommendedMangas(limit: 10);
      setState(() {
        _recommendedMangas = mangas;
        _isLoadingRecommended = false;
      });
    } catch (e) {
      setState(() {
        _recommendedError = e.toString();
        _isLoadingRecommended = false;
      });
    }
  }

  Future<void> _loadPopularMangas() async {
    try {
      final mangas = await _apiService.getPopularMangas(
        limit: _pageSize,
        offset: _popularOffset,
      );

      setState(() {
        _popularMangas.addAll(mangas);
        _popularOffset += _pageSize;
        _isLoadingPopular = false;
        // Si recibimos menos mangas que el límite, no hay más
        _hasMorePopular = mangas.length >= _pageSize;

        print(
          '✅ Cargados ${mangas.length} mangas. Offset: $_popularOffset, Hay más: $_hasMorePopular',
        );
      });
    } catch (e) {
      setState(() {
        _popularError = e.toString();
        _isLoadingPopular = false;
      });
      print('❌ Error cargando populares: $e');
    }
  }

  Future<void> _loadMorePopularMangas() async {
    if (_isLoadingMore || !_hasMorePopular) return;

    setState(() => _isLoadingMore = true);

    try {
      final mangas = await _apiService.getPopularMangas(
        limit: _pageSize,
        offset: _popularOffset,
      );

      setState(() {
        _popularMangas.addAll(mangas);
        _popularOffset += _pageSize;
        _isLoadingMore = false;
        _hasMorePopular = mangas.length >= _pageSize;

        print(
          '✅ Cargados ${mangas.length} mangas más. Total: ${_popularMangas.length}',
        );
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      print('❌ Error cargando más: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando más mangas: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'MangaVerse',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implementar búsqueda
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        controller: _scrollController, // ← AQUÍ va el controller
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 24),

            // Recomendaciones
            _buildSectionHeader(context, 'Recomendaciones para ti'),
            const SizedBox(height: 12),
            _buildRecommendationsRow(context),
            const SizedBox(height: 32),

            // Populares
            _buildSectionHeader(context, 'Populares ahora'),
            const SizedBox(height: 12),
            _buildPopularGrid(context),

            // Loader al final
            if (_isLoadingMore) _buildLoadingMore(),

            // Mensaje cuando no hay más
            if (!_hasMorePopular && _popularMangas.isNotEmpty)
              _buildNoMoreContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar manga...',
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }

  Widget _buildRecommendationsRow(BuildContext context) {
    if (_isLoadingRecommended) {
      return useUltraLightSkeletons
          ? const UltraLightHorizontalList(height: 280, itemCount: 5)
          : const HorizontalMangaListSkeleton(height: 280, itemCount: 5);
    }

    if (_recommendedError != null) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 8),
              Text('Error: $_recommendedError'),
            ],
          ),
        ),
      );
    }

    if (_recommendedMangas.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(child: Text('No hay mangas recomendados')),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _recommendedMangas.length,
        itemBuilder: (context, index) {
          final manga = _recommendedMangas[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildMangaCard(context, manga: manga, width: 160),
          );
        },
      ),
    );
  }

  Widget _buildPopularGrid(BuildContext context) {
    if (_isLoadingPopular) {
      return useUltraLightSkeletons
          ? const UltraLightPopularGrid(itemCount: 6)
          : const PopularMangaGridSkeleton(itemCount: 6);
    }

    if (_popularError != null) {
      return SizedBox(
        height: 400,
        child: Center(child: Text('Error: $_popularError')),
      );
    }

    return GridView.builder(
      shrinkWrap: true, // ← Necesario porque está dentro de un scroll
      physics:
          const NeverScrollableScrollPhysics(), // ← IMPORTANTE: No scrollea, usa el padre
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _popularMangas.length,
      itemBuilder: (context, index) {
        final manga = _popularMangas[index];
        return _buildMangaCard(context, manga: manga);
      },
    );
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Cargando más mangas...'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMoreContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Has visto todos los mangas populares',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMangaCard(
    BuildContext context, {
    required Manga manga,
    double? width,
  }) {
    final genres = manga.tags.take(2).join(', ');

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MangaDetailsPage(manga: manga),
            ),
          );
        },
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: manga.coverFileName != null
                      ? Image.network(
                          manga.getCoverUrl(size: 512),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return useUltraLightSkeletons
                                ? const UltraLightImageSkeleton()
                                : const SimpleSkeleton(
                                    width: double.infinity,
                                    height: double.infinity,
                                  );
                          },
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      genres.isEmpty ? 'Sin géneros' : genres,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
