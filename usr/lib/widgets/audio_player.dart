import 'package:flutter/material.dart';

class AudioPlayer extends StatefulWidget {
  final String audioData;
  final bool isDark;
  
  const AudioPlayer({
    super.key,
    required this.audioData,
    required this.isDark,
  });

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  bool _isPlaying = false;
  
  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // In a real implementation, this would play/pause the audio
  }
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _togglePlayback,
      icon: Icon(
        _isPlaying ? Icons.pause : Icons.play_arrow,
        color: widget.isDark ? Colors.purple.shade300 : Colors.indigo,
      ),
      style: IconButton.styleFrom(
        backgroundColor: (widget.isDark ? Colors.purple : Colors.indigo).withOpacity(0.1),
      ),
    );
  }
}