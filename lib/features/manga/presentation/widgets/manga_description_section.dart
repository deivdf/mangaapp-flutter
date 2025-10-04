import 'package:flutter/material.dart';

class MangaDescriptionSection extends StatelessWidget {
  final String title;
  final String description;
  final List<String>? tags;

  const MangaDescriptionSection({
    super.key,
    required this.title,
    required this.description,
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Descripción
          Text(
            'Descripción',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),

          // Tags/Géneros
          if (tags != null && tags!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Géneros',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags!
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
