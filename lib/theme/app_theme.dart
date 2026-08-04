import 'package:flutter/material.dart';

// Thème unifié UKAN V2 (clair + sombre).
//
// Ce fichier ne crée PAS un nouveau système de thème : il organise la
// définition des `ThemeData` clair et sombre déjà pilotés par `ThemeNotifier`
// via `MaterialApp.themeMode`. Il constitue la source unique des couleurs de
// l'interface. Les couleurs de marque (doré, vert) restent identiques et
// lisibles dans les deux modes ; le reste (fonds, cartes, textes, bordures,
// modales, champs) suit automatiquement le thème.
class AppTheme {
  AppTheme._();

  // ── Couleurs de marque (constantes dans les deux modes) ──
  static const Color gold = Color(0xFFFFC300);
  static const Color green = Color(0xFF2ECC71);
  static const Color danger = Color(0xFFE5484D);

  // ── Palette SOMBRE (reprend le design sombre existant) ──
  static const Color _dBg = Color(0xFF0D1117);
  static const Color _dSurface = Color(0xFF161B22);
  static const Color _dSurfaceVariant = Color(0xFF21262D);
  static const Color _dBorder = Color(0xFF30363D);
  static const Color _dText = Color(0xFFF0F6FC);
  static const Color _dMuted = Color(0xFF8B949E);

  // ── Palette CLAIRE (soignée, bon contraste) ──
  static const Color _lBg = Color(0xFFF5F6F8);
  static const Color _lSurface = Color(0xFFFFFFFF);
  static const Color _lSurfaceVariant = Color(0xFFEFF1F4);
  static const Color _lBorder = Color(0xFFE2E5EA);
  static const Color _lText = Color(0xFF1A1D21);
  static const Color _lMuted = Color(0xFF6B7280);

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: _dBg,
        surface: _dSurface,
        surfaceVariant: _dSurfaceVariant,
        border: _dBorder,
        text: _dText,
        muted: _dMuted,
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: _lBg,
        surface: _lSurface,
        surfaceVariant: _lSurfaceVariant,
        border: _lBorder,
        text: _lText,
        muted: _lMuted,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surfaceVariant,
    required Color border,
    required Color text,
    required Color muted,
  }) {
    final bool isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: gold,
      onPrimary: Colors.black,
      secondary: green,
      onSecondary: Colors.black,
      error: danger,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: muted,
      outline: border,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: bg,
      colorScheme: colorScheme,
      canvasColor: surface,
      cardColor: surface,
      dividerColor: border,
      primaryColor: gold,
      iconTheme: IconThemeData(color: text),
      splashColor: gold.withValues(alpha: 0.12),
      highlightColor: gold.withValues(alpha: 0.08),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 0 : 1,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle:
            TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: TextStyle(color: text, fontSize: 14),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: gold,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: gold.withValues(alpha: 0.20),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? gold : muted,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      iconTheme: IconThemeData(color: text),
      listTileTheme: ListTileThemeData(iconColor: text, textColor: text),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        hintStyle: TextStyle(color: muted),
        labelStyle: TextStyle(color: muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
      ),
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: text),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: text,
        unselectedLabelColor: muted,
        indicatorColor: gold,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? gold : muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? gold.withValues(alpha: 0.45)
              : border,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? _dSurfaceVariant : const Color(0xFF252321),
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: gold),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceVariant,
        labelStyle: TextStyle(color: text),
        side: BorderSide(color: border),
      ),
    );
  }
}
