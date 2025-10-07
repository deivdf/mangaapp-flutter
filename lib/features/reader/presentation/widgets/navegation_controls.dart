import 'package:flutter/material.dart';

class NavigationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const NavigationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.0),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botón anterior
            ElevatedButton.icon(
              onPressed: currentPage > 0 ? onPreviousPage : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Anterior'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.withOpacity(0.1),
                disabledForegroundColor: Colors.grey,
              ),
            ),

            // Contador de páginas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${currentPage + 1} / $totalPages',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Botón siguiente
            ElevatedButton.icon(
              onPressed: currentPage < totalPages - 1 ? onNextPage : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Siguiente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.withOpacity(0.1),
                disabledForegroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
