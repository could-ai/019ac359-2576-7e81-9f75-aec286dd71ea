import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'الکتاب',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            fontFamily: GoogleFonts.notoSansArabic().fontFamily,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primarySwatch: Colors.purple,
            fontFamily: GoogleFonts.notoSansArabic().fontFamily,
            scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          ),
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}

// Theme Provider
class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  
  bool get isDark => _isDark;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('is_dark') ?? true;
    notifyListeners();
  }
  
  void toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', _isDark);
    notifyListeners();
  }
}

// App State
class AppState extends ChangeNotifier {
  String _selectedBabId = 'ism_e_zaat';
  List<Message> _messages = [];
  String _searchTerm = '';
  String _statusMessage = '';
  bool _showSplash = true;
  
  String get selectedBabId => _selectedBabId;
  List<Message> get messages => _messages;
  String get searchTerm => _searchTerm;
  String get statusMessage => _statusMessage;
  bool get showSplash => _showSplash;
  
  List<Message> get filteredMessages {
    if (_searchTerm.isEmpty) return _messages;
    return _messages.where((m) => 
      m.text?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false
    ).toList();
  }
  
  AppState() {
    _loadMessages();
  }
  
  void _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('messages') ?? [];
    _messages = messagesJson.map((json) => Message.fromJson(jsonDecode(json))).toList();
    notifyListeners();
  }
  
  void _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = _messages.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList('messages', messagesJson);
  }
  
  void setSelectedBab(String babId) {
    _selectedBabId = babId;
    _searchTerm = '';
    notifyListeners();
  }
  
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }
  
  void setStatusMessage(String message) {
    _statusMessage = message;
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      _statusMessage = '';
      notifyListeners();
    });
  }
  
  void hideSplash() {
    _showSplash = false;
    notifyListeners();
  }
  
  void addMessage(Message message) {
    _messages.insert(0, message);
    _saveMessages();
    notifyListeners();
    setStatusMessage('پیغام بھیج دیا گیا!');
  }
  
  void deleteMessage(String id) {
    _messages.removeWhere((m) => m.id == id);
    _saveMessages();
    notifyListeners();
    setStatusMessage('پیغام حذف ہو گیا');
  }
}

// Message Model
class Message {
  final String id;
  final String? text;
  final String? photoPath;
  final String? audioPath;
  final DateTime timestamp;
  final String babId;
  
  Message({
    required this.id,
    this.text,
    this.photoPath,
    this.audioPath,
    required this.timestamp,
    required this.babId,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'photoPath': photoPath,
    'audioPath': audioPath,
    'timestamp': timestamp.toIso8601String(),
    'babId': babId,
  };
  
  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    text: json['text'],
    photoPath: json['photoPath'],
    audioPath: json['audioPath'],
    timestamp: DateTime.parse(json['timestamp']),
    babId: json['babId'],
  );
}

// Bab Structure
const List<Map<String, dynamic>> babsStructure = [
  {
    'id': 'ism_e_zaat',
    'name': 'اسم ذات',
    'icon': '✨',
    'gradient': [Colors.purple, Colors.pink],
  },
  {
    'id': 'ayat_e_qutb',
    'name': 'آیت قطب',
    'icon': '⭐',
    'gradient': [Colors.yellow, Colors.orange],
  },
  {
    'id': 'wa_qul_jaa_al_haqq',
    'name': 'و قل جاء الحق',
    'icon': '🌟',
    'gradient': [Colors.green, Colors.teal],
  },
  {
    'id': 'takbir_e_tashreeq',
    'name': 'تکبیر تشریق',
    'icon': '🕌',
    'gradient': [Colors.blue, Colors.cyan],
  },
  {
    'id': 'chehel_kaaf',
    'name': 'چہل کاف',
    'icon': '📿',
    'gradient': [Colors.indigo, Colors.purple],
  },
  {
    'id': 'hizb_ul_bahr',
    'name': 'حزب البحر',
    'icon': '🌊',
    'gradient': [Colors.cyan, Colors.blue],
  },
  {
    'id': 'muawwizatain',
    'name': 'معوذتین',
    'icon': '🛡️',
    'gradient': [Color(0xFF10B981), Colors.green], // Replaced Colors.emerald
  },
  {
    'id': 'surah_al_fatihah',
    'name': 'سورۃ الفاتحہ',
    'icon': '📖',
    'gradient': [Color(0xFFF43F5E), Colors.pink], // Replaced Colors.rose
  },
];
