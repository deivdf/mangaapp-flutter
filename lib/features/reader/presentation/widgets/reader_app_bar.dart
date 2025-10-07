import 'package:flutter/material.dart';

class ReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String mangaTitle;
  final String chapterNumber;
  final bool useDataSaver;
  final VoidCallback onQualityToggle;

  const ReaderAppBar({
    super.key,
    required this.mangaTitle,
    required this.chapterNumber,
    required this.useDataSaver,
    required this.onQualityToggle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.7),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mangaTitle,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Capítulo $chapterNumber',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(useDataSaver ? Icons.sd : Icons.hd, color: Colors.white),
          tooltip: useDataSaver ? 'Calidad reducida' : 'Calidad normal',
          onPressed: onQualityToggle,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            // TODO: Mostrar menú con más opciones
          },
        ),
      ],
    );
  }
}
