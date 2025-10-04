import 'package:flutter/material.dart';
import 'package:mangaapp/features/models/model_chapeter.dart';

class ChapterListItem extends StatelessWidget {
  final List<Chapter>? chapters;
  final bool isLoading;
  final String selectedLanguage;
  final VoidCallback? onLanguageChange;
  final Function(Chapter)? onChapterTap;
  final bool groupByVolume; // Nueva opción para agrupar

  const ChapterListItem({
    super.key,
    this.chapters,
    this.isLoading = false,
    this.selectedLanguage = 'es',
    this.onLanguageChange,
    this.onChapterTap,
    this.groupByVolume = false, // Por defecto lista simple
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la sección
        _buildHeader(context),

        // Estado de carga
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        // Estado vacío
        else if (chapters == null || chapters!.isEmpty)
          _buildEmptyState(context)
        // Lista de capítulos (agrupada o simple)
        else
          groupByVolume
              ? _buildGroupedChapterList(context)
              : _buildSimpleChapterList(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('Capítulos', style: Theme.of(context).textTheme.titleLarge),
              if (chapters != null && chapters!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${chapters!.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (onLanguageChange != null)
            TextButton.icon(
              onPressed: onLanguageChange,
              icon: const Icon(Icons.language, size: 20),
              label: Text(_getLanguageFlag(selectedLanguage)),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay capítulos disponibles',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'en ${_getLanguageFlag(selectedLanguage)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChapterList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: chapters!.length,
      itemBuilder: (context, index) {
        final chapter = chapters![index];
        return _buildChapterCard(context, chapter);
      },
    );
  }

  Widget _buildGroupedChapterList(BuildContext context) {
    // Agrupar capítulos por volumen
    final grouped = <String, List<Chapter>>{};

    for (var chapter in chapters!) {
      final volumeKey = chapter.volume ?? 'Sin volumen';
      grouped.putIfAbsent(volumeKey, () => []).add(chapter);
    }

    // Ordenar volúmenes
    final sortedVolumes = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Sin volumen') return 1;
        if (b == 'Sin volumen') return -1;
        final aNum = double.tryParse(a) ?? 0;
        final bNum = double.tryParse(b) ?? 0;
        return aNum.compareTo(bNum);
      });

    return Column(
      children: sortedVolumes.map((volume) {
        final volumeChapters = grouped[volume]!;
        return _buildVolumeSection(context, volume, volumeChapters);
      }).toList(),
    );
  }

  Widget _buildVolumeSection(
    BuildContext context,
    String volume,
    List<Chapter> volumeChapters,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del volumen
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.book,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                volume == 'Sin volumen' ? volume : 'Volumen $volume',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${volumeChapters.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Capítulos del volumen
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: volumeChapters
                .map((chapter) => _buildChapterCard(context, chapter))
                .toList(),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildChapterCard(BuildContext context, Chapter chapter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onChapterTap?.call(chapter),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Número del capítulo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    chapter.chapter ?? '?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Información del capítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title ?? 'Capítulo ${chapter.chapter}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip(
                          context,
                          Icons.image_outlined,
                          '${chapter.pages} pág.',
                        ),
                        _buildInfoChip(
                          context,
                          Icons.calendar_today_outlined,
                          _formatDate(chapter.publishAt),
                        ),
                        if (chapter.scanlationGroup != null)
                          _buildInfoChip(
                            context,
                            Icons.group_outlined,
                            chapter.scanlationGroup!,
                            maxWidth: 150,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Icono de navegación
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label, {
    double? maxWidth,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return 'Hace ${(difference.inDays / 7).floor()}sem';
    } else if (difference.inDays < 365) {
      return '${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getLanguageFlag(String lang) {
    switch (lang) {
      case 'es':
        return '🇪🇸 ES';
      case 'es-la':
        return '🌎 ES-LA';
      case 'en':
        return '🇺🇸 EN';
      case 'pt-br':
        return '🇧🇷 PT';
      case 'fr':
        return '🇫🇷 FR';
      case 'de':
        return '🇩🇪 DE';
      case 'ja':
        return '🇯🇵 JA';
      default:
        return lang.toUpperCase();
    }
  }
}
