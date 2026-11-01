import '../domain/book.dart';

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

  /// сохраняет данные каталога при смене типа состояния.
  CatalogState.from(CatalogState previous, {required CatalogStatus status})
    : this(
        status: status,
        books: previous.books,
        likeCounts: previous.likeCounts,
        likedIds: previous.likedIds,
        busyLikes: previous.busyLikes,
        onlyLiked: previous.onlyLiked,
        savingBook: previous.savingBook,
        query: previous.query,
        error: status == CatalogStatus.failure ? previous.error : null,
        notice: previous.notice,
        noticeId: previous.noticeId,
      );

  /// считает избранные книги, которые есть в загруженном каталоге.
  int get favoriteCount =>
      books.where((book) => likedIds.contains(book.id)).length;

  /// создаёт список книг, которые должны отображаться на экране.
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
        .toList(); // преобразуем результат фильтрации в список.
  }

  /// меняем нужные данные, оставляя остальные прежними.
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
  }) {
    final updated = CatalogState(
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
    return switch (updated.status) {
      CatalogStatus.loading => CatalogLoadInProgress(updated),
      CatalogStatus.ready => CatalogLoadSuccess(updated),
      CatalogStatus.failure => CatalogLoadFailure(updated),
    };
  }
}

///результаты загрузки
///1. загрузка каталога
class CatalogLoadInProgress extends CatalogState {
  CatalogLoadInProgress(super.previous)
    : super.from(status: CatalogStatus.loading);
}

/// Каталог успешно загружен.
class CatalogLoadSuccess extends CatalogState {
  CatalogLoadSuccess(super.previous)
    : super.from(status: CatalogStatus.ready);
}

/// При загрузке произошла ошибка.
class CatalogLoadFailure extends CatalogState {
  CatalogLoadFailure(super.previous)
    : super.from(status: CatalogStatus.failure);
}
