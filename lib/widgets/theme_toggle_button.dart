import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:akiflash/providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;
  final double iconSize;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
            // Show feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${themeProvider.isDarkMode ? 'Dark' : 'Light'} mode enabled',
                    ),
                  ],
                ),
                backgroundColor: themeProvider.getPrimaryColor(context),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode 
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: showLabel
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: Colors.white,
                        size: iconSize,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.white,
                    size: iconSize,
                  ),
          ),
        );
      },
    );
  }
}
