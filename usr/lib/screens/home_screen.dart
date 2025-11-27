import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

import '../main.dart';
import '../widgets/message_bubble.dart';
import '../widgets/audio_recorder.dart';
import '../widgets/audio_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? _selectedPhoto;
  String? _selectedAudioPath;
  bool _isRecording = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedPhoto = File(pickedFile.path);
      });
    }
  }
  
  void _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final filePath = '${directory.path}/$fileName';
        
        await _audioRecorder.start(const RecordConfig(), path: filePath);
        setState(() {
          _isRecording = true;
          _selectedAudioPath = filePath;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording failed: $e')),
      );
    }
  }
  
  void _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _selectedAudioPath = path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: $e')),
      );
    }
  }
  
  void _sendMessage() {
    final appState = context.read<AppState>();
    final text = _textController.text.trim();
    
    if (text.isEmpty && _selectedPhoto == null && _selectedAudioPath == null) {
      return;
    }
    
    final message = Message(
      id: const Uuid().v4(),
      text: text.isNotEmpty ? text : null,
      photoPath: _selectedPhoto?.path,
      audioPath: _selectedAudioPath,
      timestamp: DateTime.now(),
      babId: appState.selectedBabId,
    );
    
    appState.addMessage(message);
    
    _textController.clear();
    setState(() {
      _selectedPhoto = null;
      _selectedAudioPath = null;
    });
  }
  
  void _exportToText() {
    final appState = context.read<AppState>();
    final messages = appState.filteredMessages;
    final bab = babsStructure.firstWhere((b) => b['id'] == appState.selectedBabId);
    
    String content = 'الکتاب - ${bab['name']}\n\n';
    
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      content += '${i + 1}. ${msg.text ?? '[Media]'}\n';
      content += '   وقت: ${DateFormat('dd/MM/yyyy HH:mm', 'ur_PK').format(msg.timestamp)}\n\n';
    }
    
    // For now, just show in dialog. In real app, save to file
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تصدیر شدہ مواد'),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ٹھیک ہے'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final appState = context.watch<AppState>();
    final currentBab = babsStructure.firstWhere((b) => b['id'] == appState.selectedBabId);
    final filteredMessages = appState.filteredMessages.where((m) => m.babId == appState.selectedBabId).toList();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFFE8F4FD), const Color(0xFFF3E8FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withOpacity(0.9),
                  border: Border(
                    bottom: BorderSide(
                      color: (isDark ? Colors.purple : Colors.indigo).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.book,
                      color: isDark ? Colors.purple.shade300 : Colors.indigo,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'الکتاب',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.yellow : Colors.indigo.shade700,
                      ),
                    ),
                    const Spacer(),
                    // Search
                    if (MediaQuery.of(context).size.width > 600)
                      SizedBox(
                        width: 200,
                        child: TextField(
                          onChanged: appState.setSearchTerm,
                          decoration: InputDecoration(
                            hintText: 'تلاش...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDark ? Colors.purple.shade300 : Colors.indigo,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    // Theme toggle
                    IconButton(
                      onPressed: context.read<ThemeProvider>().toggleTheme,
                      icon: Icon(
                        isDark ? Icons.sunny : Icons.nightlight_round,
                        color: isDark ? Colors.yellow : Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? Colors.purple : Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bab Navigation
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withOpacity(0.95),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: babsStructure.length,
                  itemBuilder: (context, index) {
                    final bab = babsStructure[index];
                    final isSelected = bab['id'] == appState.selectedBabId;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: ElevatedButton(
                        onPressed: () => appState.setSelectedBab(bab['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected 
                            ? Color.lerp(bab['gradient'][0], bab['gradient'][1], 0.5)
                            : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                          foregroundColor: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: isSelected ? 4 : 0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('${bab['icon']} ${bab['name']}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Status Message
              if (appState.statusMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    appState.statusMessage,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Bab Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (currentBab['gradient'][0] as Color).withOpacity(0.7),
                      (currentBab['gradient'][1] as Color).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: (isDark ? Colors.purple : Colors.indigo).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          currentBab['icon'],
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentBab['name'],
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.yellow : Colors.indigo.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildStatChip('${filteredMessages.length} پیغامات', isDark),
                                  const SizedBox(width: 8),
                                  _buildStatChip(DateFormat('dd/MM/yyyy', 'ur_PK').format(DateTime.now()), isDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: filteredMessages.isNotEmpty ? _exportToText : null,
                          icon: const Icon(Icons.download, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Messages List
              Expanded(
                child: filteredMessages.isEmpty
                  ? _buildEmptyState(currentBab, isDark)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredMessages.length,
                      itemBuilder: (context, index) {
                        final message = filteredMessages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: MessageBubble(
                            message: message,
                            isDark: isDark,
                            onDelete: () => appState.deleteMessage(message.id),
                          ),
                        );
                      },
                    ),
              ),
              
              // Input Area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withOpacity(0.9),
                  border: Border(
                    top: BorderSide(
                      color: (isDark ? Colors.purple : Colors.indigo).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Preview
                    if (_selectedPhoto != null || _selectedAudioPath != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            if (_selectedPhoto != null)
                              Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: FileImage(_selectedPhoto!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: IconButton(
                                      onPressed: () => setState(() => _selectedPhoto = null),
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      iconSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            if (_selectedAudioPath != null)
                              Container(
                                margin: const EdgeInsets.only(left: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.purple : Colors.indigo).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.mic,
                                      color: isDark ? Colors.purple.shade300 : Colors.indigo,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('آڈیو ریکارڈ ہو گیا'),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => setState(() => _selectedAudioPath = null),
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      iconSize: 16,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    
                    // Input Controls
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'پیغام لکھیں...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _pickImage,
                          icon: Icon(
                            Icons.image,
                            color: isDark ? Colors.purple.shade300 : Colors.indigo,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: (isDark ? Colors.purple : Colors.indigo).withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _isRecording ? _stopRecording : _startRecording,
                          icon: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: _isRecording ? Colors.red : (isDark ? Colors.purple.shade300 : Colors.indigo),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: _isRecording 
                              ? Colors.red.withOpacity(0.1) 
                              : (isDark ? Colors.purple : Colors.indigo).withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(Icons.send, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? Colors.purple : Colors.indigo,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          onPressed: (_textController.text.trim().isNotEmpty || _selectedPhoto != null || _selectedAudioPath != null) ? _sendMessage : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatChip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(Map<String, dynamic> bab, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: (isDark ? Colors.purple : Colors.indigo).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.text_snippet,
              size: 64,
              color: isDark ? Colors.purple.shade300 : Colors.indigo,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ابھی کوئی پیغام نہیں',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.yellow : Colors.indigo.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${bab['name']} کے لیے اپنا پہلا پیغام بھیجیں',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: (isDark ? Colors.purple : Colors.indigo).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              '💡 نیچے سے ٹیکسٹ، تصویر یا آڈیو بھیجیں',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}