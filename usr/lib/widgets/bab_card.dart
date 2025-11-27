import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class BabCard extends StatelessWidget {
  final Map<String, dynamic> bab;
  final bool isSelected;
  final VoidCallback onTap;
  
  const BabCard({
    super.key,
    required this.bab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected 
                ? LinearGradient(
                    colors: [
                      bab['gradient'][0],
                      bab['gradient'][1],
                    ],
                  )
                : null,
              color: isSelected 
                ? null 
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected 
                  ? Colors.transparent 
                  : (isDark ? Colors.purple : Colors.indigo).withOpacity(0.2),
                width: 1,
              ),
              boxShadow: isSelected 
                ? [
                    BoxShadow(
                      color: bab['gradient'][0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bab['icon'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  bab['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                      ? Colors.white 
                      : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}