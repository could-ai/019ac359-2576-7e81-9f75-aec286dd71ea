import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';

import '../main.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isDark;
  final VoidCallback onDelete;
  
  const MessageBubble({
    super.key,
    required this.message,
    required this.isDark,
    required this.onDelete,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  void _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      if (widget.message.audioPath != null) {
        await _audioPlayer.setFilePath(widget.message.audioPath!);
        await _audioPlayer.play();
        setState(() => _isPlaying = true);
        
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() => _isPlaying = false);
          }
        });
      }
    }
  }
  
  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a', 'ur_PK').format(time);
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ur_PK').format(date);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDark 
                  ? [
                      Colors.purple.shade900.withOpacity(0.6),
                      Colors.indigo.shade900.withOpacity(0.6),
                      Colors.pink.shade900.withOpacity(0.6),
                    ]
                  : [
                      Colors.white.withOpacity(0.8),
                      Colors.indigo.shade50.withOpacity(0.5),
                      Colors.purple.shade50.withOpacity(0.5),
                    ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (widget.isDark ? Colors.purple : Colors.indigo).withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.isDark ? Colors.purple : Colors.indigo).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (widget.isDark ? Colors.purple : Colors.indigo).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Text('📅'),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(widget.message.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark ? Colors.purple.shade200 : Colors.indigo.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      iconSize: 20,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Text Content
                if (widget.message.text != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      widget.message.text!,
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.isDark ? Colors.white : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                
                // Photo Content
                if (widget.message.photoPath != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(widget.message.photoPath!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
                // Audio Content
                if (widget.message.audioPath != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (widget.isDark ? Colors.purple : Colors.indigo).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _togglePlayback,
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: widget.isDark ? Colors.purple.shade300 : Colors.indigo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: (widget.isDark ? Colors.purple : Colors.indigo).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 0.6, // Mock progress
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: widget.isDark 
                                          ? [Colors.purple, Colors.pink]
                                          : [Colors.indigo, Colors.purple],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'آڈیو پیغام',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.isDark ? Colors.purple.shade300 : Colors.indigo.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Footer
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Text(
                        '🕐 ${_formatTime(widget.message.timestamp)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (widget.message.text != null)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '📝 ٹیکسٹ',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          if (widget.message.photoPath != null)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '📷 تصویر',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          if (widget.message.audioPath != null)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (widget.isDark ? Colors.purple : Colors.indigo).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '🎤 آڈیو',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Decorative corner accent
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: (widget.isDark ? Colors.yellow : Colors.indigo).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(60),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}