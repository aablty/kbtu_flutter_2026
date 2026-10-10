import 'package:flutter/material.dart';

// Sole seed input for ColorScheme.fromSeed, not a styling literal.
const _seed = Color(0xFF6750A4);

ThemeData buildLightTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seed),
);

ThemeData buildDarkTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  ),
);
