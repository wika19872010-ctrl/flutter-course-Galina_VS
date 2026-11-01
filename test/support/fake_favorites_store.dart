// Файл подмены хранилища личных лайков для тестов.

import 'package:flutter_application_dz_27092026/data/favorites_store.dart';

class FakeFavoritesStore implements FavoritesStore {
  final Set<String> ids;
  Object? error;
  final Map<String, int> otherCounts =
      {}; // Имитируем голоса остальных аккаунтов.

  @override
  Future<Map<String, int>> loadLikeCounts() async => {
    for (final id in {...otherCounts.keys, ...ids})
      id: (otherCounts[id] ?? 0) + (ids.contains(id) ? 1 : 0),
  };

  FakeFavoritesStore([Set<String>? ids]) : ids = {...?ids};

  @override
  Future<Set<String>> loadIds() async => {...ids}; // Загружаем номера понравившихся книг только для этого аккаунта.

  @override
  Future<void> setLiked(String bookId, bool liked) async {
    // Сохраняем или удаляем личный лайк.
    if (error != null) throw error!;
    if (liked) {
      ids.add(bookId);
    } else {
      ids.remove(bookId); // Убираем ненужные записи из списка.
    }
  }
}
