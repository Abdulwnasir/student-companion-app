import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const List<String> supportedLanguages = ['en', 'am', 'or'];
  
  String _currentLanguage = 'en';
  Map<String, String> _translations = {};
  
  String get currentLanguage => _currentLanguage;
  
  LocalizationService() {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? 'en';
    await loadTranslations(_currentLanguage);
    notifyListeners();
  }
  
  Future<void> loadTranslations(String languageCode) async {
    try {
      final jsonString = await rootBundle.loadString(
        'lib/core/localization/l10n/$languageCode.json'
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _translations = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      _currentLanguage = languageCode;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      notifyListeners();
    } catch (e) {
      print('Error loading translations: $e');
    }
  }
  
  String translate(String key) {
    return _translations[key] ?? key;
  }
  
  Future<void> changeLanguage(String languageCode) async {
    if (supportedLanguages.contains(languageCode) && languageCode != _currentLanguage) {
      await loadTranslations(languageCode);
    }
  }
}
