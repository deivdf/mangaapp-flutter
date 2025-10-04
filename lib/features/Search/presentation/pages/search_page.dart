import 'package:flutter/material.dart';
import 'package:mangaapp/features/data/api_consults.dart';
import 'package:mangaapp/features/manga/presentation/pages/MangaDetails_page.dart';
import 'package:mangaapp/features/models/model_manga.dart';
import 'package:mangaapp/features/models/model_mangaTag.dart';
import 'package:mangaapp/features/shared/widgets/skeleton_widgets.dart';
import 'package:mangaapp/features/shared/widgets/lightweight_skeleton.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  List<Manga> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  String? _tagsError;
  bool _isTagLoading = true;
  List<MangaTag> allTags = [];
  Set<String> selectedTagIds = {};

  // Flag para usar skeletons ultra-ligeros en caso de performance crítico
  static const bool useUltraLightSkeletons =
      true; // Cambiar a true si necesitas máximo performance
  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  void _loadTags() async {
    setState(() {
      _isTagLoading = true;
      _tagsError = null;
    });
    try {
      final tags = await _apiService.getAlltags();

      final filteredTags = tags
          .where((tag) => tag.group == 'genre' || tag.group == 'theme')
          .toList();

      setState(() {
        allTags = filteredTags;
        _isTagLoading = false;
      });
    } catch (e) {
      setState(() {
        _isTagLoading = false;
        _tagsError = 'Error loading tags: $e';
      });
    }
  }

  final MangadexService _apiService = MangadexService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Buscar', style: Theme.of(context).textTheme.headlineSmall),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(context),
          _buildGenreChips(context),
          _buildResultsLabel(context),
          _buildSearchResults(context),
        ],
      ),
    );
  }

  Widget _buildGenreChips(BuildContext context) {
    if (_isTagLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: useUltraLightSkeletons
            ? const UltraLightTagChipsSkeleton()
            : const SimpleTagChipsSkeleton(),
      );
    }
    if (_tagsError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error, color: Colors.red),
              Text(_tagsError!),
              ElevatedButton(
                onPressed: () => _loadTags(), // Retry button
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (allTags.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No hay géneros disponibles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.inversePrimary.withOpacity(0.6),
            ),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: allTags.map((tag) {
          final selected = selectedTagIds.contains(tag.id);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(tag.name),
              selected: selected,
              selectedColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.8),
              checkmarkColor: Theme.of(context).colorScheme.onPrimary,
              labelStyle: selected
                  ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                  : null,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedTagIds.add(tag.id);
                  } else {
                    selectedTagIds.remove(tag.id);
                  }
                });
                _performSearch();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMangaTile(BuildContext context, Manga manga) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MangaDetailsPage(manga: manga),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  manga.getCoverUrl(),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.image, size: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Puedes mostrar más datos del objeto manga aquí
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        'Resultados de búsqueda',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar Por título o género',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        onChanged: (text) {
          setState(() {
            query = text;
            _isLoading = true;
          });
          _performSearch();
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_isLoading) {
      return useUltraLightSkeletons
          ? const UltraLightSearchResults()
          : const SearchResultsSkeleton();
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text(_error!)),
      );
    }
    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text('No se encontraron resultados')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final manga = _searchResults[index];
          return _buildMangaTile(context, manga); // Ahora espera Manga real
        },
      ),
    );
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await _apiService.searchMangas(
        title: query,
        includedTags: selectedTagIds.toList(),
      );
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Ocurrió un error: $e';
      });
    }
  }
}
