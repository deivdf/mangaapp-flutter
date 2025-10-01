import 'package:flutter/material.dart';
import 'package:mangaapp/features/data/api_consults.dart';
import 'package:mangaapp/features/models/model_manga.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final MangadexService _apiService = MangadexService();

  // Estados de carga
  bool _isLoadingRecommended = true;
  bool _isLoadingPopular = true;

  // Listas de mangas
  List<Manga> _recommendedMangas = [];
  List<Manga> _popularMangas = [];

  // Mensajes de error
  String? _recommendedError;
  String? _popularError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadRecommendedMangas(), _loadPopularMangas()]);
  }

  Future<void> _loadRecommendedMangas() async {
    try {
      final mangas = await _apiService.getRecommendedMangas(limit: 10);
      setState(() {
        _recommendedMangas = mangas;
        print('aqui trae los datos de recomendados en la vista home $mangas');
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
      final mangas = await _apiService.getPopularMangas(limit: 12);
      setState(() {
        _popularMangas = mangas;
        _isLoadingPopular = false;
      });
    } catch (e) {
      setState(() {
        _popularError = e.toString();
        _isLoadingPopular = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
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
            // Implementar búsqueda
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(context),

            const SizedBox(height: 24),

            // Sección: Recomendaciones para ti
            _buildSectionHeader(context, 'Recomendaciones para ti'),
            const SizedBox(height: 12),
            _buildRecommendationsRow(context),

            const SizedBox(height: 32),

            // Sección: Populares ahora
            _buildSectionHeader(context, 'Populares ahora'),
            const SizedBox(height: 12),
            _buildPopularGrid(context),
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
        onTap: () {
          // Navegar a pantalla de búsqueda
        },
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
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recommendedError != null) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48),
              SizedBox(height: 8),
              Text('Error: $_recommendedError'),
            ],
          ),
        ),
      );
    }

    if (_recommendedMangas.isEmpty) {
      return SizedBox(
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
          print('mosttrando mangas aqui: ${manga}');
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
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_popularError != null) {
      return SizedBox(
        height: 400,
        child: Center(child: Text('Error: $_popularError')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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

  Widget _buildMangaCard(
    BuildContext context, {
    required Manga manga,
    double? width,
  }) {
    final genres = manga.tags.take(2).join(', ');

    return SizedBox(
      width: width,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del manga
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
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
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

            // Información del manga
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
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Biblioteca',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configuración',
        ),
      ],
    );
  }
}
