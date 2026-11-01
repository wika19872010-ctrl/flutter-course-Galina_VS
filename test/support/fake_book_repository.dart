// Файл подмены хранилища книг для тестов без обращения к серверу.

import 'package:flutter_application_dz_27092026/data/book_repository.dart';
import 'package:flutter_application_dz_27092026/domain/book.dart';

class FakeBookRepository implements BookRepository {
  final List<Book> books; // Книги общего каталога.
  Stream<List<Book>>? updates;
  Object? loadError;
  Object? saveError;
  Object? deleteError;
  bool alreadyAbsent = false;
  Future<List<Book>> Function()? onLoad;
  int saves = 0;
  int deletes = 0;
  FakeBookRepository([List<Book> books = const []]) : books = [...books];
  @override
  Future<List<Book>> loadBooks() async {
    // Читаем книги выбранной коллекции.
    if (onLoad != null) return onLoad!();
    if (loadError != null) throw loadError!;
    return [...books];
  }

  @override
  Stream<List<Book>> watchBooks() => updates ?? const Stream.empty();

  @override
  Future<Book> saveBook(Map<String, dynamic> data, {String? id}) async {
    // Сохраняем книгу и возвращаем подтверждённые данные.
    saves++;
    if (saveError != null) throw saveError!;
    final book = Book.fromJson({
      ...data,
      'id': id ?? 'new-$saves', // Сохраняем постоянный номер книги, чтобы её лайки не потерялись.
      'ownerId': 'a', // Запоминаем, кто добавил книгу.
    });
    books.removeWhere(
      (item) => item.id == book.id,
    ); // Убираем ненужные записи из списка.
    books.insert(0, book);
    return book;
  }

  @override
  Future<DeleteBookResult> deleteBook(String id) async {
    // Удаляем книгу с проверкой версии документа.
    deletes++;
    if (deleteError != null) throw deleteError!;
    books.removeWhere(
      (book) => book.id == id,
    ); // Убираем ненужные записи из списка.
    return alreadyAbsent
        ? DeleteBookResult.alreadyAbsent
        : DeleteBookResult.deleted;
  }

  @override
  bool canManage(Book book) => true; // Разрешаем менять и удалять только свои книги.
}
