// Личные лайки и общий реестр голосов через SDK Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

/// Описывает, какие действия нужны для личного избранного и подсчёта лайков.
abstract class FavoritesStore {
  /// Загружаем номера понравившихся книг только для этого аккаунта.
  Future<Set<String>> loadIds();

  /// Считаем голоса всех аккаунтов по постоянному ID книги.
  Future<Map<String, int>> loadLikeCounts();

  /// Сохраняем или удаляем личный лайк.
  Future<void> setLiked(String bookId, bool liked);
}

/// Хранит личное избранное пользователя и общие записи лайков в Firestore.
class FirestoreFavoritesStore implements FavoritesStore {
  /// Идентификатор пользователя, чьё избранное загружается и изменяется.
  final String userId;
  final FirebaseFirestore db;

  ///конструктор с проверкой идентификатора пользователя
  FirestoreFavoritesStore({required this.userId, required this.db}) {
    if (userId.isEmpty || userId.contains('/')) {
      throw ArgumentError.value(userId, 'userId');
    }
  }

  /// Возвращает ссылку на личное избранное текущего пользователя.
  /// Путь в базе: users / идентификатор пользователя / favorites.
  CollectionReference<Map<String, dynamic>> get _personal =>
      db.collection('users').doc(userId).collection('favorites');

  /// Возвращает ссылку на общие лайки всех пользователей.
  /// Эта коллекция нужна для подсчёта количества лайков каждой книги.
  CollectionReference<Map<String, dynamic>> get _public =>
      db.collection('bookLikes');

  ///метод загружает номера избранных книг текущего пользователя
  @override
  Future<Set<String>> loadIds() async => {
    for (final doc
        in (await _personal
                .get(const GetOptions(source: Source.server))
                .timeout(const Duration(seconds: 10)))
            .docs)
      doc.id,
  };

  /// Подсчитывает лайки каждой книги.
  @override
  Future<Map<String, int>> loadLikeCounts() async {
    final counts = <String, int>{};
    final ownMirrors = <String>{};
    final votes = await _public
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    for (final doc in votes.docs) {
      final fields = doc.data();
      final id = fields['bookId'].toString();
      counts[id] = (counts[id] ?? 0) + 1;
      if (fields['userId'] == userId) ownMirrors.add(id);
    }
    // Сохраняем совместимость со старыми личными лайками.
    final legacy = (await loadIds()).difference(ownMirrors).toList();
    for (var offset = 0; offset < legacy.length; offset += 10) {
      final batch = db.batch();
      final chunk = legacy.skip(offset).take(10);
      for (final id in chunk) {
        batch.set(_public.doc('${id}_$userId'), {
          'bookId': int.tryParse(id) ?? id,
          'userId': userId,
        });
      }
      await batch.commit();
      for (final id in chunk) {
        counts[id] = (counts[id] ?? 0) + 1;
      }
    }
    return counts;
  }

  ///метод ставит или снимает лайк, обновляя личное избранное и общий счётчик
  @override
  Future<void> setLiked(String bookId, bool liked) async {
    final personal = _personal.doc(bookId);
    final public = _public.doc('${bookId}_$userId');
    // Транзакция требует сеть: при офлайне лайк откатится в Cubit,
    // а отложенная запись не появится после выхода из аккаунта.
    await db.runTransaction((transaction) async {
      await transaction.get(personal);
      final mirror = await transaction.get(public);
      if (liked) {
        transaction.set(personal, {'bookId': int.tryParse(bookId) ?? bookId});
        transaction.set(public, {
          'bookId': int.tryParse(bookId) ?? bookId,
          'userId': userId,
        });
      } else {
        transaction.delete(personal);
        if (mirror.exists) transaction.delete(public);
      }
    });
  }
}
