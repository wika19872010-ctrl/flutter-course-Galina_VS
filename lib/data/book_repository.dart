// Здесь описано, что должно уметь хранилище книг: загружать, сохранять и удалять книги. Также определены возможные результаты удаления и ошибка для показа пользователю.

import '../domain/book.dart';

/// ошибка каталога с сообщением для пользователя
class CatalogException implements Exception {
  final String message;

  /// Создаёт ошибку и запоминает сообщение, которое можно показать пользователю.
  const CatalogException(this.message);

  /// возвращает текст ошибки для показа пользователю.
  @override
  String toString() => message;
}

/// результат попытки удалить книгу.
enum DeleteBookResult { deleted, alreadyAbsent }

///список действий, которые должно уметь выполнять хранилище книг
abstract class BookRepository {
  /// Читаем книги выбранной коллекции.
  Future<List<Book>> loadBooks();

  /// Получаем новый список при изменениях в базе.
  Stream<List<Book>> watchBooks();

  /// Сохраняем книгу и возвращаем подтверждённые данные.
  Future<Book> saveBook(Map<String, dynamic> data, {String? id});

  /// Удаляем книгу с проверкой версии документа.
  Future<DeleteBookResult> deleteBook(String id);

  /// Разрешаем менять и удалять только свои книги.
  bool canManage(Book book);
}
