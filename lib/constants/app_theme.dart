import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppSpacing {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const section = 24.0;
  static const radius = 18.0;
}

/// Reference-inspired midnight surfaces with cyan and electric-blue accents.
abstract final class AppTheme {
  static final dark = _build();

  static ThemeData _build() {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF16C8F4),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF27D0F4),
      onPrimary: const Color(0xFF002432),
      primaryContainer: const Color(0xFF07364A),
      onPrimaryContainer: const Color(0xFFBDEFFF),
      secondary: const Color(0xFF009BFA),
      onSecondary: const Color(0xFF001C2D),
      secondaryContainer: const Color(0xFF102C40),
      onSecondaryContainer: const Color(0xFFC8EBFF),
      tertiary: const Color(0xFFFFB45C),
      onTertiary: const Color(0xFF392000),
      surface: const Color(0xFF06121C),
      surfaceContainerLowest: const Color(0xFF040D14),
      surfaceContainerLow: const Color(0xFF111F2A),
      surfaceContainer: const Color(0xFF172733),
      surfaceContainerHigh: const Color(0xFF203440),
      surfaceContainerHighest: const Color(0xFF2B404E),
      onSurface: const Color(0xFFF1F7FB),
      onSurfaceVariant: const Color(0xFFA9BBC8),
      outline: const Color(0xFF526674),
      outlineVariant: const Color(0xFF263C4B),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
    );
    final base = ThemeData(
        useMaterial3: true, colorScheme: colors, fontFamily: 'Roboto');
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      side: BorderSide(color: colors.outlineVariant),
    );
    final text = base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium!.copyWith(
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8),
      titleLarge: base.textTheme.titleLarge!.copyWith(
          fontSize: 21, fontWeight: FontWeight.w600, letterSpacing: -0.3),
      titleMedium: base.textTheme.titleMedium!
          .copyWith(fontSize: 16, height: 1.35, fontWeight: FontWeight.w600),
      bodyLarge: base.textTheme.bodyLarge!.copyWith(fontSize: 16, height: 1.7),
      bodyMedium: base.textTheme.bodyMedium!
          .copyWith(fontSize: 14, height: 1.5, color: colors.onSurfaceVariant),
      labelSmall: base.textTheme.labelSmall!.copyWith(
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          color: colors.primary),
    );
    return base.copyWith(
      scaffoldBackgroundColor: colors.surface,
      textTheme: text,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: text.titleMedium,
        toolbarHeight: 64,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: colors.surfaceContainerLow,
        surfaceTintColor: colors.surfaceContainerLow,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.primary,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodyMedium,
        horizontalTitleGap: AppSpacing.large,
        minVerticalPadding: AppSpacing.large,
      ),
      iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
        foregroundColor: colors.primary,
        minimumSize: const Size(48, 48),
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.section, vertical: AppSpacing.large),
          shape: const StadiumBorder(),
          textStyle: text.titleMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              minimumSize: const Size(48, 48))),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 6,
        shape: const StadiumBorder(),
        extendedTextStyle: text.titleMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.primaryContainer,
        labelStyle: text.labelSmall!.copyWith(color: colors.onPrimaryContainer),
        iconTheme: IconThemeData(color: colors.primary, size: 18),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.small, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            borderSide: BorderSide(color: colors.outlineVariant)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            borderSide: BorderSide(color: colors.primary, width: 2)),
        filled: true,
        fillColor: colors.surface,
        labelStyle: text.bodyMedium,
        contentPadding: const EdgeInsets.all(AppSpacing.large),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
      dialogTheme: DialogTheme(
        shape: shape,
        backgroundColor: colors.surfaceContainerLow,
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      dividerTheme: DividerThemeData(
          color: colors.outlineVariant, space: AppSpacing.section),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
    );
  }
}
