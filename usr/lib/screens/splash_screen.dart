import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    _progressController.forward();
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.read<AppState>().hideSplash();
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)]
              : [const Color(0xFFE8F4FD), const Color(0xFFF3E8FF), const Color(0xFFFFF8E8)],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: MediaQuery.of(context).size.width * 0.2,
              child: AnimatedContainer(
                duration: const Duration(seconds: 2),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? Colors.purple : Colors.indigo).withOpacity(0.2),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.2,
              right: MediaQuery.of(context).size.width * 0.2,
              child: AnimatedContainer(
                duration: const Duration(seconds: 2),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? Colors.pink : Colors.purple).withOpacity(0.2),
                ),
              ),
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Book Icon with rotation
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _progressController.value * 2 * math.pi,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: isDark 
                                    ? [Colors.purple, Colors.pink]
                                    : [Colors.indigo, Colors.purple],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.purple : Colors.indigo).withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.book,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      // Rotating ring
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _progressController.value * 4 * math.pi,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? Colors.yellow : Colors.indigo,
                                  width: 4,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // App Name
                  Text(
                    'الکتاب',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.yellow : Colors.indigo,
                      shadows: [
                        Shadow(
                          color: (isDark ? Colors.yellow : Colors.indigo).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    'روحانی اعمال کا خزانہ',
                    style: TextStyle(
                      fontSize: 24,
                      color: isDark ? Colors.purple.shade200 : Colors.indigo.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 64),
                  
                  // Progress Bar
                  Container(
                    width: 300,
                    height: 8,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? Colors.yellow : Colors.indigo,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Text(
                        'لوڈ ہو رہا ہے... ${( _progressAnimation.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Feature preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureIcon('📝', 'ٹیکسٹ', isDark),
                      const SizedBox(width: 24),
                      _buildFeatureIcon('🎤', 'آڈیو', isDark),
                      const SizedBox(width: 24),
                      _buildFeatureIcon('📷', 'تصویر', isDark),
                      const SizedBox(width: 24),
                      _buildFeatureIcon('📄', 'PDF', isDark),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureIcon(String emoji, String text, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? Colors.purple : Colors.indigo).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }
}