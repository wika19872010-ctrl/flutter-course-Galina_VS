// Хранилище общего каталога через Firestore.
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/book.dart';
import '../core/api_constants.dart';
import 'book_repository.dart';

/// Загружает, добавляет, изменяет и удаляет книги в Firestore.
class FirestoreBookRepository implements BookRepository {
  final FirebaseFirestore db;
  final String userId;
  final Future<String?> Function()? getNickname;
  final Map<String, _SavedBook> _records = {};

  /// Принимает базу, текущего пользователя и функцию получения его никнейма.
  FirestoreBookRepository({
    required this.db,
    required this.userId,
    this.getNickname,
  });

  /// Возвращает ссылку на общую коллекцию книг, не загружая её содержимое.
  CollectionReference<Map<String, dynamic>> get _books =>
      db.collection(sharedBooksCollection);

  /// Разрешает менять и удалять только книги текущего пользователя.
  @override
  bool canManage(Book book) => book.ownerId == userId;

  /// Превращает документы в книги, запоминает ссылки и сортирует список по названию.
  List<Book> _readBooks(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final books = <Book>[];
    _records.clear();
    for (final doc in snapshot.docs) {
      final book = Book.fromFirestore(doc);
      books.add(book);
      _records[book.id] = _SavedBook(doc.reference, book);
    }
    books.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return books;
  }

  /// Один раз загружает книги с сервера; ждёт ответ не более 10 секунд.
  @override
  Future<List<Book>> loadBooks() async => _readBooks(
    await _books
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10)),
  );

  /// Передаёт новый список книг при изменениях в базе.
  @override
  Stream<List<Book>> watchBooks() => _books.snapshots().map(_readBooks);

  /// Собирает данные книги в строку для проверки, не изменились ли они в базе.
  String _version(Book book) => jsonEncode({
    ...book.toJson(),
    'id': book.id,
    'legacyId': book.legacyId,
    'ownerId': book.ownerId,
    'publisherNickname': book.publisherNickname,
  });

  /// Останавливает запись, если книгу изменили, удалили или она принадлежит другому.
  void _checkVersion(
    DocumentSnapshot<Map<String, dynamic>> current,
    Book previous,
  ) {
    if (!current.exists ||
        _version(Book.fromFirestore(current)) != _version(previous)) {
      throw const CatalogException(
        'Книга была изменена. Обновите каталог и повторите попытку.',
      );
    }
    if (!canManage(Book.fromFirestore(current))) {
      throw const CatalogException(
        'Изменять и удалять можно только свои книги.',
      );
    }
  }

  /// Без id добавляет книгу через add: ID нового документа выдаёт Firestore.
  /// С id изменяет тот же документ, даже если название или автор поменялись.
  /// Одинаковые названия разрешены; личные лайки хранятся отдельно от книги.
  @override
  Future<Book> saveBook(Map<String, dynamic> data, {String? id}) async {
    final title = data['title'] as String? ?? '';
    if (title.trim().isEmpty) {
      throw const CatalogException('Введите название книги.');
    }
    final old = id == null ? null : _records[id];
    if (id != null && old == null) {
      throw const CatalogException('Книга не найдена. Обновите каталог.');
    }
    final nickname = old == null ? (await getNickname?.call())?.trim() : null;
    final values = {
      ...Book.fromJson({...data, 'id': id ?? '', 'title': title.trim()})
          .toJson(),
      'ownerId': old?.book.ownerId ?? userId,
      'publisherNickname': old == null
          ? (nickname?.isNotEmpty == true ? nickname! : 'Пользователь')
          : old.book.publisherNickname ?? 'Не указан',
    };
    final DocumentReference<Map<String, dynamic>> target;
    if (old == null) {
      target = await _books.add(values);
    } else {
      target = old.reference;
      // Проверка и изменение выполняются вместе, чтобы не затереть свежие данные.
      await db.runTransaction((transaction) async {
        final current = await transaction.get(target);
        _checkVersion(current, old.book);
        transaction.update(target, values);
      });
    }
    final saved = Book.fromJson({
      ...values,
      'id': target.id,
      'legacyId': old?.book.legacyId,
    });
    _records[saved.id] = _SavedBook(target, saved);
    return saved;
  }

  /// Удаляет документ по ID после проверки владельца и прочитанной версии книги.
  @override
  Future<DeleteBookResult> deleteBook(String id) async {
    final old = _records[id];
    if (old == null) {
      throw const CatalogException('Обновите каталог перед удалением.');
    }
    final result = await db.runTransaction((transaction) async {
      final current = await transaction.get(old.reference);
      if (!current.exists) return DeleteBookResult.alreadyAbsent;
      _checkVersion(current, old.book);
      transaction.delete(old.reference);
      return DeleteBookResult.deleted;
    });
    _records.remove(id);
    return result;
  }
}

/// Хранит прочитанную книгу и ссылку на её документ для проверки изменений.
class _SavedBook {
  final DocumentReference<Map<String, dynamic>> reference;
  final Book book;

  /// Запоминает ссылку и данные последней прочитанной версии книги.
  const _SavedBook(this.reference, this.book);
}
