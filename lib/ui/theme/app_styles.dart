// Файл общих цветов и оформления приложения.

import 'package:flutter/material.dart';

// Общая палитра сохраняет существующее оформление приложения.
/// Хранит общие цвета, чтобы все экраны приложения были оформлены одинаково.
abstract final class AppColors {
  static const background = Color.fromARGB(
    255,
    216,
    224,
    239,
  ); // Храним цвет фона приложения.
  static const surface = Color.fromARGB(
    255,
    165,
    193,
    241,
  ); // Храним цвет карточек и верхней панели.
  static const accent = Color.fromARGB(
    255,
    146,
    176,
    227,
  ); // Храним цвет акцентных элементов.
  static const tag = Color(0xFFE0F2F1);
}

/// Хранит общее оформление текста, которое используется на разных экранах.
abstract final class AppStyles {
  static const fieldLabel = TextStyle(
    fontSize: 16, // Выбираем размер текста.
    fontWeight: FontWeight.w600, // Выбираем толщину букв.
  );
  static const detail = TextStyle(fontSize: 14);
}
