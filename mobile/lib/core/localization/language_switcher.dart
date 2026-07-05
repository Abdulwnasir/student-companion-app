import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'localization_service.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool isSidebar;
  
  const LanguageSwitcher({super.key, this.isSidebar = true});
  
  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    if (isSidebar) {
      return ExpansionTile(
        leading: const Icon(Icons.language),
        title: Text(localizationService.translate('language')),
        children: [
          _buildLanguageTile(
            context,
            localizationService,
            '🇺🇸',
            localizationService.translate('english'),
            'en',
          ),
          _buildLanguageTile(
            context,
            localizationService,
            '🇪🇹',
            localizationService.translate('amharic'),
            'am',
          ),
          _buildLanguageTile(
            context,
            localizationService,
            '🇪🇹',
            localizationService.translate('oromiffa'),
            'or',
          ),
        ],
      );
    }
    
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (value) => localizationService.changeLanguage(value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'en', child: Text('🇺🇸 English')),
        const PopupMenuItem(value: 'am', child: Text('🇪🇹 አማርኛ')),
        const PopupMenuItem(value: 'or', child: Text('🇪🇹 Oromoo')),
      ],
    );
  }
  
  Widget _buildLanguageTile(
    BuildContext context,
    LocalizationService localizationService,
    String flag,
    String label,
    String code,
  ) {
    return ListTile(
      leading: Text(flag),
      title: Text(label),
      trailing: localizationService.currentLanguage == code
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () => localizationService.changeLanguage(code),
    );
  }
}
