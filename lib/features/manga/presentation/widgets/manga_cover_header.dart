import 'package:flutter/material.dart';

class MangaCoverHeader extends StatelessWidget {
  final String imageUrl;
  final double height;

  const MangaCoverHeader({
    super.key,
    required this.imageUrl,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, StackTrace) {
          return Container(
            height: height,
            width: double.infinity,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            child: Icon(
              Icons.broken_image,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}
