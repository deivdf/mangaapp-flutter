import 'package:flutter/material.dart';

class LanguageSelectorDialog extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelected;

  const LanguageSelectorDialog({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String selectedLanguage,
    required Function(String) onLanguageSelected,
  }) {
    return showDialog(
      context: context,
      builder: (context) => LanguageSelectorDialog(
        selectedLanguage: selectedLanguage,
        onLanguageSelected: onLanguageSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar idioma'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, '🇪🇸 Español', 'es'),
            _buildLanguageOption(context, '🇺🇸 Inglés', 'en'),
            _buildLanguageOption(context, '🌎 Español Latino', 'es-la'),
            _buildLanguageOption(context, '🇧🇷 Portugués', 'pt-br'),
            _buildLanguageOption(context, '🇫🇷 Francés', 'fr'),
            _buildLanguageOption(context, '🇩🇪 Alemán', 'de'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String label, String code) {
    return RadioListTile<String>(
      title: Text(label),
      value: code,
      groupValue: selectedLanguage,
      onChanged: (value) {
        if (value != null) {
          Navigator.pop(context);
          onLanguageSelected(value);
        }
      },
    );
  }
}
