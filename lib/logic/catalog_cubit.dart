// Файл состояния и управления каталогом: загрузка, поиск, избранное, добавление, редактирование и удаление книг.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/error_messages.dart';
import '../data/book_repository.dart';
import '../data/favorites_store.dart';
import '../domain/book.dart';

/// Управляет каталогом, поиском, лайками и фильтром избранного.
class CatalogCubit extends Cubit<CatalogState> {
  /// Репозиторий читает и сохраняет книги на сервере.
  final BookRepository shared;

  /// Хранилище избранного текущего пользователя.
  final FavoritesStore favorites;
  StreamSubscription<List<Book>>? _booksSubscription;
  int _watchVersion = 0;
  int _loadVersion =
      0; // Считаем загрузки, чтобы игнорировать устаревшие ответы.
  int _likesVersion =
      0; // Считаем изменения лайков, чтобы загрузка их не перезаписала.
  final Map<String, bool> _pendingLikes =
      {}; // Запоминаем лайки, сохранение которых сервер ещё не подтвердил.
  final Set<String> _deleting = {};

  /// Создаёт управление каталогом с переданными хранилищами книг и избранного.
  CatalogCubit({required this.shared, required this.favorites})
    : super(CatalogState());

  /// Разрешаем менять и удалять только свои книги.
  bool canManage(Book book) => shared.canManage(book);

  /// Асинхронная функция для получения книг и лайков с сервера.
  /// `Future<void>` означает, что функция выполняется не мгновенно
  /// и после завершения не возвращает значение.
  /// await ждёт завершения запроса, не блокируя интерфейс.
  Future<void> load() async {
    final version = ++_loadVersion;
    final watchVersion = ++_watchVersion;
    await _booksSubscription?.cancel();
    if (isClosed || version != _loadVersion) {
      return;
    }
    final likesVersion = _likesVersion;
    emit(state.copyWith(status: CatalogStatus.loading));
    try {
      final results = await Future.wait<Object>([
        shared.loadBooks(),
        favorites.loadIds(),
        favorites.loadLikeCounts(),
      ]);
      final books = results[0] as List<Book>;
      // Старые лайки привязаны к числовому номеру: связываем их с ID документа.
      final aliases = {for (final book in books) book.favoriteId: book.id};
      final loadedLikes = {
        for (final id in results[1] as Set<String>) aliases[id] ?? id,
      };
      final counts = {
        for (final entry in (results[2] as Map<String, int>).entries)
          aliases[entry.key] ?? entry.key: entry.value,
      };
      if (isClosed || version != _loadVersion) {
        return;
      }
      final likedIds = {
        ...(likesVersion == _likesVersion ? loadedLikes : state.likedIds),
      };
      for (final entry in _pendingLikes.entries) {
        entry.value ? likedIds.add(entry.key) : likedIds.remove(entry.key);
      }
      emit(
        state.copyWith(
          status: CatalogStatus.ready,
          books: books,
          // Загрузка не должна перезаписывать счётчик после более свежего нажатия.
          likeCounts: likesVersion == _likesVersion && _pendingLikes.isEmpty
              ? counts
              : state.likeCounts,
          likedIds: likedIds,
        ),
      );
      _booksSubscription = shared.watchBooks().listen(
        (books) {
          if (isClosed || watchVersion != _watchVersion) return;
          emit(state.copyWith(status: CatalogStatus.ready, books: books));
        },
        onError: (Object error) {
          if (isClosed || watchVersion != _watchVersion) return;
          emit(
            state.copyWith(
              status: CatalogStatus.failure,
              error: requestErrorMessage(
                error,
                fallback: 'Не удалось обновить каталог. Попробуйте ещё раз.',
              ),
            ),
          );
        },
      );
    } catch (error) {
      if (isClosed || version != _loadVersion) {
        return;
      }
      emit(
        state.copyWith(
          status: CatalogStatus.failure,
          error: requestErrorMessage(
            error,
            fallback: 'Не удалось загрузить каталог. Попробуйте ещё раз.',
          ),
        ),
      );
    }
  }

  /// Отменяет получение новых списков книг и закрывает управление каталогом.
  /// Это освобождает ресурсы, когда каталог больше не используется.
  @override
  Future<void> close() async {
    _loadVersion++;
    _watchVersion++;
    await _booksSubscription?.cancel();
    return super.close();
  }

  /// Запоминаем текст поиска и обновляем список книг.
  void search(String value) {
    if (value == state.query) return;
    emit(state.copyWith(query: value));
  }

  /// Переключает показ всех книг и только избранных.
  /// ! меняет значение на противоположное: false → true или true → false.
  void toggleFilter() => emit(state.copyWith(onlyLiked: !state.onlyLiked));

  /// Готовим короткое сообщение о результате действия.
  void _notice(String message) =>
      emit(state.copyWith(notice: message, noticeId: state.noticeId + 1));

  /// Добавляет книгу в избранное или удаляет из избранного.
  /// contains(id) проверяет, есть ли номер книги в множестве.
  /// Интерфейс обновляется через emit нового состояния.
  /// При ошибке сохранения возвращается прежнее значение лайка.
  Future<bool> toggleLike(String id) async {
    if (_pendingLikes.containsKey(id)) return state.likedIds.contains(id);
    final liked = !state.likedIds.contains(id);
    _pendingLikes[id] = liked;
    _likesVersion++;
    final ids = {...state.likedIds};
    liked ? ids.add(id) : ids.remove(id);
    final counts = {...state.likeCounts};
    final previousCount =
        counts[id] ?? 0; // Запоминаем значение для точного отката при ошибке.
    counts[id] = liked
        ? previousCount + 1
        : (previousCount - 1).clamp(0, 1 << 53);
    emit(
      state.copyWith(
        likeCounts: counts,
        likedIds: ids,
        busyLikes: _pendingLikes.keys.toSet(),
      ),
    );
    try {
      final book = state.books.firstWhere((book) => book.id == id);
      await favorites.setLiked(book.favoriteId, liked);
    } catch (error) {
      if (isClosed) return !liked;
      final restored = {...state.likedIds};
      liked ? restored.remove(id) : restored.add(id);
      final restoredCounts = {...state.likeCounts, id: previousCount};
      emit(state.copyWith(likeCounts: restoredCounts, likedIds: restored));
      _notice(
        requestErrorMessage(error, fallback: 'Не удалось сохранить лайк.'),
      );
    } finally {
      _pendingLikes.remove(id);
      _likesVersion++;
      if (!isClosed) {
        emit(state.copyWith(busyLikes: _pendingLikes.keys.toSet()));
      }
    }
    return state.likedIds.contains(id);
  }

  /// Сохраняем книгу и возвращаем подтверждённые данные.
  Future<Book> saveBook(Map<String, dynamic> data, {String? id}) async {
    if (state.savingBook) {
      throw const CatalogException('Дождитесь сохранения книги.');
    }
    emit(state.copyWith(savingBook: true));
    try {
      final saved = await shared.saveBook(data, id: id);
      if (!isClosed) {
        _loadVersion++;
        emit(
          state.copyWith(
            books: [saved, ...state.books.where((book) => book.id != saved.id)],
            query: '',
            onlyLiked: false,
            status: CatalogStatus.ready,
          ),
        );
      }
      return saved;
    } finally {
      if (!isClosed) {
        emit(state.copyWith(savingBook: false));
      }
    }
  }

  /// Удаляем книгу с проверкой версии документа.
  Future<bool> deleteBook(Book book) async {
    if (!_deleting.add(book.id)) return false;
    try {
      final result = await shared.deleteBook(book.id);
      if (isClosed) return true;
      _loadVersion++;
      emit(
        state.copyWith(
          status: CatalogStatus.ready,
          books: state.books.where((item) => item.id != book.id).toList(),
        ),
      );
      _notice(
        result == DeleteBookResult.alreadyAbsent
            ? 'Книги уже нет на сервере. Карточка убрана из каталога.'
            : 'Книга успешно удалена',
      );
      return true;
    } catch (error) {
      if (!isClosed) {
        _notice(
          requestErrorMessage(error, fallback: 'Не удалось удалить книгу.'),
        );
      }
      return false;
    } finally {
      _deleting.remove(book.id);
    }
  }
}

/// Перечисляет состояния каталога: загрузка, готовые данные и ошибка.
enum CatalogStatus { loading, ready, failure }

/// Хранит текущие книги, лайки, поиск, фильтр и сообщения для экрана каталога.
class CatalogState {
  /// Показывает, выполняется ли загрузка, получены ли данные или возникла ошибка.
  final CatalogStatus status;

  /// Книги, полученные с сервера.
  final List<Book> books;
  final Map<String, int> likeCounts;

  /// Множество номеров книг, добавленных пользователем в избранное.
  final Set<String> likedIds;
  final Set<String> busyLikes;

  /// true — показываем только избранное, false — все подходящие книги.
  final bool onlyLiked;

  /// true — книга сохраняется на сервере, false — сохранение не выполняется.
  final bool savingBook;

  /// Текст, который пользователь ввёл в поиск.
  final String query;

  /// Сообщение об ошибке; String? допускает текст или null, если ошибки нет.
  final String? error;
  final String? notice;
  final int noticeId;

  /// Собирает данные одного состояния каталога; списки защищает от изменений извне.
  CatalogState({
    this.status = CatalogStatus.loading,
    List<Book> books = const [],
    Map<String, int> likeCounts = const {},
    Set<String> likedIds = const {},
    Set<String> busyLikes = const {},
    this.onlyLiked = false,
    this.savingBook = false,
    this.query = '',
    this.error,
    this.notice,
    this.noticeId = 0,
  }) : books = List.unmodifiable(books),
       likeCounts = Map.unmodifiable(likeCounts),
       likedIds = Set.unmodifiable(likedIds),
       busyLikes = Set.unmodifiable(busyLikes);

  /// Считает избранные книги, которые есть в загруженном каталоге.
  int get favoriteCount =>
      books.where((book) => likedIds.contains(book.id)).length;

  /// Создаёт список книг, которые должны отображаться на экране.
  /// where перебирает книги и оставляет только подходящие по обоим условиям.
  List<Book> get visibleBooks {
    // trim убирает пробелы по краям, toLowerCase позволяет искать без учёта регистра.
    final normalizedQuery = query.trim().toLowerCase();
    // || — логическое ИЛИ: если фильтр выключен, подходят все книги.
    // && — логическое И: должны совпасть и фильтр избранного, и поиск.
    // contains проверяет, содержится ли поисковый текст в названии книги.
    return books
        .where(
          (book) =>
              (!onlyLiked || likedIds.contains(book.id)) &&
              (normalizedQuery.isEmpty ||
                  book.title.toLowerCase().contains(normalizedQuery)),
        )
        .toList(); // Преобразуем результат фильтрации в список.
  }

  /// Меняем нужные данные, оставляя остальные прежними.
  CatalogState copyWith({
    CatalogStatus? status,
    List<Book>? books,
    Map<String, int>? likeCounts,
    Set<String>? likedIds,
    Set<String>? busyLikes,
    bool? onlyLiked,
    bool? savingBook,
    String? query,
    String? error,
    String? notice,
    int? noticeId,
  }) => CatalogState(
    status: status ?? this.status,
    books: books ?? this.books,
    likeCounts: likeCounts ?? this.likeCounts,
    likedIds: likedIds ?? this.likedIds,
    busyLikes: busyLikes ?? this.busyLikes,
    onlyLiked: onlyLiked ?? this.onlyLiked,
    savingBook: savingBook ?? this.savingBook,
    query: query ?? this.query,
    error:
        error ??
        (status == CatalogStatus.loading || status == CatalogStatus.ready
            ? null
            : this.error),
    notice: notice ?? this.notice,
    noticeId: noticeId ?? this.noticeId,
  );
}
