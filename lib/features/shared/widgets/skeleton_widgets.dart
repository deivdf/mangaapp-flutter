import 'package:flutter/material.dart';

/// Widget base para crear efectos skeleton con shimmer
class SkeletonContainer extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final Widget? child;

  const SkeletonContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.child,
  });

  @override
  State<SkeletonContainer> createState() => _SkeletonContainerState();
}

class _SkeletonContainerState extends State<SkeletonContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        color: baseColor,
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [baseColor, highlightColor, baseColor],
                stops: [
                  (_animation.value - 1).clamp(0.0, 1.0),
                  _animation.value.clamp(0.0, 1.0),
                  (_animation.value + 1).clamp(0.0, 1.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton para chips de tags horizontales
class TagChipsSkeleton extends StatelessWidget {
  const TagChipsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(8, (index) {
          // Diferentes anchos para simular nombres de tags reales
          final widths = [80.0, 100.0, 60.0, 120.0, 90.0, 110.0, 70.0, 95.0];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SkeletonContainer(
              width: widths[index % widths.length],
              height: 32,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }),
      ),
    );
  }
}

/// Skeleton para una card de manga individual
class MangaCardSkeleton extends StatelessWidget {
  final double? width;
  final double aspectRatio;

  const MangaCardSkeleton({super.key, this.width, this.aspectRatio = 0.75});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skeleton para la imagen
            Expanded(
              child: SkeletonContainer(
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
            // Skeleton para la información del manga
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del manga (2 líneas)
                  const SkeletonContainer(
                    width: double.infinity,
                    height: 16,
                    margin: EdgeInsets.only(bottom: 4),
                  ),
                  const SkeletonContainer(
                    width: 120,
                    height: 16,
                    margin: EdgeInsets.only(bottom: 8),
                  ),
                  // Géneros (1 línea más corta)
                  const SkeletonContainer(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton para grid de mangas de búsqueda
class SearchResultsSkeleton extends StatelessWidget {
  const SearchResultsSkeleton({super.key});

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
        itemCount: 6, // Mostrar 6 skeletons
        itemBuilder: (context, index) {
          return const MangaCardSkeleton();
        },
      ),
    );
  }
}

/// Skeleton para fila horizontal de recomendaciones
class HorizontalMangaListSkeleton extends StatelessWidget {
  final double height;
  final int itemCount;

  const HorizontalMangaListSkeleton({
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
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: MangaCardSkeleton(width: 160, aspectRatio: 0.65),
          );
        },
      ),
    );
  }
}

/// Skeleton para grid de mangas populares
class PopularMangaGridSkeleton extends StatelessWidget {
  final int itemCount;

  const PopularMangaGridSkeleton({super.key, this.itemCount = 6});

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
        return const MangaCardSkeleton(aspectRatio: 0.65);
      },
    );
  }
}

/// Widget simple skeleton sin animación para mejor performance
class SimpleSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const SimpleSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        color: color,
      ),
    );
  }
}

/// Skeleton simple para chips (sin animación para mejor performance)
class SimpleTagChipsSkeleton extends StatelessWidget {
  const SimpleTagChipsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(8, (index) {
          final widths = [80.0, 100.0, 60.0, 120.0, 90.0, 110.0, 70.0, 95.0];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SimpleSkeleton(
              width: widths[index % widths.length],
              height: 32,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }),
      ),
    );
  }
}

/// Skeleton para el estado de carga de capítulos con progreso
class ChapterLoadingSkeleton extends StatelessWidget {
  final bool showProgress;
  final int itemCount;

  const ChapterLoadingSkeleton({
    super.key,
    this.showProgress = true,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Circular progress skeleton
          SkeletonContainer(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(20),
          ),

          const SizedBox(height: 16),

          // Texto "Cargando capítulos"
          SkeletonContainer(
            width: 180,
            height: 20,
            borderRadius: BorderRadius.circular(4),
          ),

          if (showProgress) ...[
            const SizedBox(height: 12),

            // Texto de progreso "X de Y"
            SkeletonContainer(
              width: 100,
              height: 16,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 16),

            // Barra de progreso
            SkeletonContainer(
              width: double.infinity,
              height: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],

          const SizedBox(height: 32),

          // Preview de cards de capítulos
          ...List.generate(
            itemCount,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildChapterCardSkeleton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCardSkeleton(BuildContext context) {
    return SkeletonContainer(
      width: double.infinity,
      height: 80,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Número del capítulo
            SkeletonContainer(
              width: 50,
              height: 50,
              borderRadius: BorderRadius.circular(8),
            ),

            const SizedBox(width: 12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonContainer(
                    width: double.infinity,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  SkeletonContainer(
                    width: 150,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
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
