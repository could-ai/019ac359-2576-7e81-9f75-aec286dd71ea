import 'package:flutter/material.dart';

class AudioRecorder extends StatefulWidget {
  final Function(String) onRecordComplete;
  final bool isDark;
  
  const AudioRecorder({
    super.key,
    required this.onRecordComplete,
    required this.isDark,
  });

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;
  int _recordingTime = 0;
  
  void _toggleRecording() {
    if (_isRecording) {
      // Stop recording
      setState(() {
        _isRecording = false;
        _recordingTime = 0;
      });
      // In a real implementation, this would return the audio file path
      widget.onRecordComplete('mock_audio_path');
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
        _recordingTime = 0;
      });
      // Mock timer for UI
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted && _isRecording) {
          setState(() => _recordingTime++);
          return true;
        }
        return false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _toggleRecording,
      icon: Icon(
        Icons.mic,
        color: _isRecording ? Colors.white : (widget.isDark ? Colors.purple.shade300 : Colors.indigo),
      ),
      style: IconButton.styleFrom(
        backgroundColor: _isRecording 
          ? Colors.red 
          : (widget.isDark ? Colors.purple : Colors.indigo).withOpacity(0.1),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}