import 'package:flutter/material.dart';

/// Ultra-lightweight skeleton widgets sin animaciones para máximo performance
/// Usa estos en lugar de los animados cuando el performance sea crítico

class UltraLightSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const UltraLightSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
      ),
    );
  }
}

/// Skeleton ultraligero para chips de tags
class UltraLightTagChipsSkeleton extends StatelessWidget {
  const UltraLightTagChipsSkeleton({super.key});

  static const _chipWidths = [
    80.0,
    100.0,
    60.0,
    120.0,
    90.0,
    110.0,
    70.0,
    95.0,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < 8; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: UltraLightSkeleton(
                width: _chipWidths[i % _chipWidths.length],
                height: 32,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card de manga ultraligera sin animaciones
class UltraLightMangaCard extends StatelessWidget {
  final double? width;
  final double aspectRatio;

  const UltraLightMangaCard({super.key, this.width, this.aspectRatio = 0.75});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final skeletonColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE0E0E0);

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen skeleton
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
            ),
            // Información skeleton
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título línea 1
                  Container(
                    width: double.infinity,
                    height: 16,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Título línea 2
                  Container(
                    width: 120,
                    height: 16,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Géneros
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid de resultados de búsqueda ultraligero
class UltraLightSearchResults extends StatelessWidget {
  final int itemCount;

  const UltraLightSearchResults({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => const UltraLightMangaCard(),
      ),
    );
  }
}

/// Lista horizontal ultraligera para recomendaciones
class UltraLightHorizontalList extends StatelessWidget {
  final double height;
  final int itemCount;

  const UltraLightHorizontalList({
    super.key,
    this.height = 280,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(right: 16),
            child: UltraLightMangaCard(width: 160, aspectRatio: 0.65),
          );
        },
      ),
    );
  }
}

/// Grid ultraligero para mangas populares
class UltraLightPopularGrid extends StatelessWidget {
  final int itemCount;

  const UltraLightPopularGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
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
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const UltraLightMangaCard(aspectRatio: 0.65);
      },
    );
  }
}

/// Skeleton minimalista para imágenes en carga
class UltraLightImageSkeleton extends StatelessWidget {
  const UltraLightImageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: isDark ? const Color(0xFF404040) : const Color(0xFFBDBDBD),
      ),
    );
  }
}
