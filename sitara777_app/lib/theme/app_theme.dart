import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === LIGHT THEME COLORS ===
  
  // Primary Brand Colors
  static const Color lightPrimary = Color(0xFFD32F2F); // Red - Main brand color
  static const Color lightSecondary = Color(0xFFF4C10F); // Golden Yellow - Accent
  static const Color lightAccent = Color(0xFF0288D1); // Blue - Secondary accent
  
  // Background Colors
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure white background
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white surfaces
  static const Color lightCardColor = Color(0xFFFFFFFF); // White cards
  
  // Text Colors
  static const Color lightTextPrimary = Color(0xFF212121); // Dark text
  static const Color lightTextSecondary = Color(0xFF757575); // Gray text
  static const Color lightTextTertiary = Color(0xFF9E9E9E); // Light gray text
  static const Color lightTextOnPrimary = Color(0xFFFFFFFF); // White text on primary
  
  // === DARK THEME COLORS ===
  
  // Primary Brand Colors (Dark Mode)
  static const Color darkPrimary = Color(0xFFEF5350); // Lighter red for dark mode
  static const Color darkSecondary = Color(0xFFFDD835); // Brighter yellow for dark mode
  static const Color darkAccent = Color(0xFF29B6F6); // Lighter blue for dark mode
  
  // Background Colors (Dark Mode)
  static const Color darkBackground = Color(0xFF121212); // Dark background
  static const Color darkSurface = Color(0xFF1E1E1E); // Dark surfaces
  static const Color darkCardColor = Color(0xFF2D2D2D); // Dark cards
  
  // Text Colors (Dark Mode)
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // White text
  static const Color darkTextSecondary = Color(0xFFBDBDBD); // Light gray text
  static const Color darkTextTertiary = Color(0xFF757575); // Gray text
  static const Color darkTextOnPrimary = Color(0xFF000000); // Black text on primary
  
  // === SHARED COLORS ===
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color infoColor = Color(0xFF2196F3); // Blue
  
  // Market Status Colors
  static const Color marketOpenColor = Color(0xFF4CAF50); // Green for open markets
  static const Color marketClosedColor = Color(0xFFF44336); // Red for closed markets
  
  // Special UI Colors
  static const Color goldColor = Color(0xFFFDD835); // Gold
  static const Color silverColor = Color(0xFFC0C0C0); // Silver
  static const Color bronzeColor = Color(0xFFCD7F32); // Bronze
  
  // Shadows and Effects
  static const Color shadowLight = Color(0x1A000000); // Light shadow
  static const Color shadowDark = Color(0x40000000); // Dark shadow

  // === ALIASES FOR BACKWARD COMPATIBILITY ===
  // These aliases ensure existing code continues to work
  static const Color primaryColor = lightPrimary;
  static const Color secondaryColor = lightSecondary;
  static const Color accentColor = lightAccent;
  static const Color backgroundColor = lightBackground;
  static const Color surfaceColor = lightSurface;
  static const Color cardColor = lightCardColor;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textTertiary = lightTextTertiary;
  static const Color textOnPrimary = lightTextOnPrimary;
  static const Color shadowColor = shadowLight;

  // === NEON COLORS FOR SPECIAL EFFECTS ===
  static const Color neonGold = Color(0xFFFFD700);
  static const Color neonBlue = Color(0xFF00BFFF);
  static const Color neonPurple = Color(0xFF9370DB);
  static const Color neonGreen = Color(0xFF00FF7F);

  // === INPUT FIELD COLORS ===
  static const Color inputFieldColor = Color(0xFFF5F5F5);
  static const Color inputBorderColor = Color(0xFFE0E0E0);

  // === GRADIENT METHODS ===
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [lightPrimary, lightSecondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get accentGradient => const LinearGradient(
        colors: [lightAccent, Color(0xFFFF8E53)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get successGradient => const LinearGradient(
        colors: [successColor, Color(0xFF8BC34A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Method to get gradient by index
  static LinearGradient getGradient(int index) {
    final gradients = [
      primaryGradient,
      accentGradient,
      successGradient,
      const LinearGradient(
        colors: [neonGold, neonBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [neonPurple, neonGreen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    return gradients[index % gradients.length];
  }

  // === SHADOW METHODS ===
  static BoxShadow get cardShadow => BoxShadow(
        color: lightPrimary.withOpacity(0.2),
        blurRadius: 20,
        offset: const Offset(0, 10),
      );

  static BoxShadow get buttonShadow => BoxShadow(
        color: lightPrimary.withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 6),
      );

  // Performance-optimized shadows (const where possible)
  static const BoxShadow softShadow = BoxShadow(
    color: shadowLight,
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow cardShadowConst = BoxShadow(
    color: Color(0x1A0288D1),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  // === LIGHT THEME DATA ===
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.red,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightCardColor,
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: lightTextPrimary,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: lightTextPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: lightTextPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: lightTextPrimary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: lightTextPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: lightCardColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightPrimary,
      elevation: 1,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: lightPrimary,
      unselectedItemColor: lightTextTertiary,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Input field decoration for uniform UI
  static InputDecoration gameInputDecoration({
    required String hintText,
    Widget? suffixIcon,
    bool showBorder = true,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: lightTextTertiary,
        fontSize: 14,
      ),
      filled: true,
      fillColor: lightSurface,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: showBorder 
          ? const BorderSide(color: lightTextTertiary, width: 1)
          : BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: showBorder 
          ? const BorderSide(color: lightTextTertiary, width: 1)
          : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Game screen app bar style
  static AppBar gameAppBar({
    required String title,
    required String balance,
    VoidCallback? onBackPressed,
  }) {
    return AppBar(
      backgroundColor: lightPrimary,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet, 
              color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              balance,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
    );
  }

  // Proceed button style
  static Widget proceedButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [softShadow],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
    );
  }
}
