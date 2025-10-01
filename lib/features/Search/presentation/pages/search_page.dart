import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  Set<String> selectedGenres = {};

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
          });
        },
      ),
    );
  }

  Widget _buildGenreChips(BuildContext context) {
    final genres = ['Acción', 'Aventura', 'Comedia', 'Drama'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: genres.map((genre) {
          final selected = selectedGenres.contains(genre);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(genre),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedGenres.add(genre);
                  } else {
                    selectedGenres.remove(genre);
                  }
                });
              },
              selectedColor: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    // Ejemplo de datos
    final mangas = [
      {
        'title': 'El Viaje de Chihiro',
        'author': 'Hayao Miyazaki',
        'imagePath': 'assets/chihiro.png',
      },
      {
        'title': 'Mi Vecino Totoro',
        'author': 'Hayao Miyazaki',
        'imagePath': 'assets/totoro.png',
      },
      {
        'title': 'La Princesa Mononoke',
        'author': 'Hayao Miyazaki',
        'imagePath': 'assets/mononoke.png',
      },
      {
        'title': 'El Castillo Ambulante',
        'author': 'Hayao Miyazaki',
        'imagePath': 'assets/castillo.png',
      },
    ];

    // Filtrar según query y géneros si implementas lógica
    final filtered = mangas.where((manga) {
      final textMatch = manga['title']!.toLowerCase().contains(
        query.toLowerCase(),
      );
      // Aquí podrías filtrar por género si agregas esa propiedad
      return textMatch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dos columnas
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final manga = filtered[index];
          return _buildMangaTile(context, manga);
        },
      ),
    );
  }

  Widget _buildMangaTile(BuildContext context, Map manga) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                manga['imagePath'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manga['title'],
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  manga['author'],
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
}
