// Файл экрана общего каталога с поиском, избранным, добавлением книг и выходом из аккаунта.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/login_error_messages.dart';
import '../../data/book_repository.dart';
import '../../data/favorites_store.dart';
import '../../domain/book.dart';
import '../../logic/books_cubit.dart';
import '../navigation/book_page_route.dart';
import '../theme/app_styles.dart';
import '../widgets/book_card.dart';
import '../widgets/book_form.dart';
import '../widgets/delete_book_dialog.dart';
import 'book_details_screen.dart';
import '../../logic/books_state.dart';

/// Создаёт общее управление каталогом и передаёт ему хранилища книг и лайков.
class CatalogScreen extends StatelessWidget {
  final BookRepository repository; // Здесь читаем и сохраняем общие книги.
  final FavoritesStore
  favorites; // Сохраняем лайки отдельно для текущего аккаунта.
  final Future<void> Function()? onSignOut;

  /// Принимает хранилища книг и избранного, а также действие выхода из аккаунта.
  const CatalogScreen({
    super.key,
    required this.repository,
    required this.favorites,
    this.onSignOut,
  });

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => CatalogCubit(
      // Создаём общее управление книгами и лайками для каталога.
      shared: repository, // Подключаем чтение и сохранение общих книг.
      favorites: favorites, // Передаём хранилище избранного текущего UID.
    )..load(), // Загружаем книги и лайки текущего пользователя.
    child: _CatalogView(onSignOut: onSignOut),
  );
}

/// Показывает каталог и передаёт его состоянию действие выхода из аккаунта.
class _CatalogView extends StatefulWidget {
  final Future<void> Function()? onSignOut;

  /// Принимает действие выхода, которое будет вызвано кнопкой каталога.
  const _CatalogView({this.onSignOut});

  /// Создаёт объект состояния, который хранит изменяемые данные этого виджета.
  @override
  State<_CatalogView> createState() => _CatalogViewState();
}

/// Обрабатывает поиск, переходы между экранами и выход из каталога.
class _CatalogViewState extends State<_CatalogView> {
  /// Контроллер позволяет работать с текстом строки поиска.
  final _search = TextEditingController();
  bool _signingOut = false;

  /// Освобождает контроллеры при закрытии виджета, чтобы они больше не занимали ресурсы.
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Выполняет выход из аккаунта, блокирует повторное нажатие и показывает ошибку при неудаче.
  Future<void> _signOut() async {
    if (_signingOut) {
      // Не запускаем повторный выход.
      return; // Дожидаемся завершения текущего выхода.
    }
    setState(
      () => _signingOut = true,
    ); // Обновляем поля и кнопки на этом экране.
    try {
      await widget.onSignOut!();
    } catch (error) {
      // Если запрос не удался, показываем ошибку вместо закрытия приложения.
      if (mounted) {
        // Обновляем экран, только если пользователь ещё не ушёл с него.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loginErrorMessage(error))),
        ); // Переводим ошибку авторизации в понятный русский текст.
      }
    } finally {
      // Убираем признак ожидания и при успехе, и при ошибке.
      if (mounted) {
        // Проверяем, что экран ещё открыт.
        setState(
          () => _signingOut = false,
        ); // Снимаем индикатор выполнения выхода.
      }
    }
  }

  /// Открывает экран с анимацией и передаёт ему общий CatalogCubit списка и подробностей.
  void _open(Widget screen, {bool slowOpening = false}) {
    // Открываем экран с теми же книгами и лайками, что в списке.
    final cubit = context
        .read<CatalogCubit>(); // Получаем общие данные списка и подробностей.
    Navigator.push(
      // Открываем следующий экран в стеке навигации.
      context,
      BookPageRoute<void>(
        openingDuration: Duration(milliseconds: slowOpening ? 700 : 280),
        builder: (_) => BlocProvider.value(value: cubit, child: screen),
      ),
    );
  }

  /// Запрашивает подтверждение удаления и после согласия вызывает удаление через CatalogCubit.
  Future<void> _delete(Book book) async {
    // Запрашиваем подтверждение перед удалением.
    final cubit = context
        .read<CatalogCubit>(); // Получаем общие данные списка и подробностей.
    if (await confirmBookDeletion(context, book) && mounted) {
      // Обновляем экран, только если пользователь ещё не ушёл с него.
      await cubit.deleteBook(book);
    }
  }

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<CatalogCubit, CatalogState>(
    listenWhen: (previous, current) => previous.query != current.query,
    // Следим за изменениями данных каталога.
    listener: (context, state) {
      // Реагируем на обновление общих данных каталога.
      if (_search.text != state.query) {
        // Проверяем, совпадает ли текст поля с текущим поиском.
        _search.text = state.query; // Обновляем текст после сброса поиска.
      }
    },
    child: BlocListener<CatalogCubit, CatalogState>(
      listenWhen: (previous, current) => previous.noticeId != current.noticeId, // Определяем, какие изменения состояния требуют уведомления.
      listener: (context, state) =>
          ScaffoldMessenger.of(
              context,
            ) // Реагируем на обновление общих данных каталога.
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.notice!))),
      child: BlocBuilder<CatalogCubit, CatalogState>(
        // Поиск обновляет только результаты, сохраняя поле ввода и панель.
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.onlyLiked != current.onlyLiked ||
            previous.favoriteCount != current.favoriteCount,
        builder: (context, state) {
          final cubit = context
              .read<
                CatalogCubit
              >(); // Получаем общие данные списка и подробностей.
          return Scaffold(
            backgroundColor: AppColors.background, // Выбираем цвет фона.
            appBar: AppBar(
              // Создаём верхнюю панель экрана.
              backgroundColor: AppColors.surface, // Выбираем цвет фона.
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.onlyLiked ? 'Книги к прочтению' : 'Каталог книг',
                    maxLines: 1, // Ограничиваем число строк текста.
                    overflow: TextOverflow.ellipsis, // Сокращаем слишком длинный текст многоточием.
                    style: const TextStyle(
                      // Выбираем оформление текста.
                      fontSize: 25, // Выбираем размер текста.
                      fontWeight: FontWeight.bold, // Выбираем толщину букв.
                    ),
                  ),
                  Text(
                    'В избранном: ${state.favoriteCount}',
                    style: const TextStyle(
                      fontSize: 14,
                    ), // Выбираем оформление текста.
                  ),
                ],
              ),
              actions: [
                // Размещаем кнопки доступных действий.
                if (widget.onSignOut != null && !state.onlyLiked)
                  TextButton.icon(
                    // Создаём кнопку с надписью.
                    onPressed: _signingOut ? null : _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Выйти'),
                  ),
                IconButton(
                  // Создаём кнопку со значком.
                  onPressed: cubit.toggleFilter,
                  tooltip:
                      state
                          .onlyLiked // Поясняем назначение кнопки при долгом нажатии.
                      ? 'Показать все книги'
                      : 'Показать только избранные',
                  icon: Icon(
                    state.onlyLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                ),
                IconButton(
                  // Создаём кнопку со значком.
                  onPressed: state.status == CatalogStatus.loading
                      ? null
                      : cubit.load,
                  tooltip: 'Обновить каталог', // Поясняем назначение кнопки при долгом нажатии.
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            floatingActionButtonLocation: // Сохраняем положение кнопки добавления.
                FloatingActionButtonLocation.endDocked,
            floatingActionButton: FloatingActionButton(
              // Добавляем кнопку создания книги.
              backgroundColor: AppColors.accent, // Выбираем цвет фона.
              foregroundColor: Colors.black, // Задаём цвет текста и иконок.
              shape: const CircleBorder(
                side: BorderSide(color: Colors.black),
              ), // Сохраняем форму кнопки или карточки.
              tooltip: 'Добавить новую книгу', // Поясняем назначение кнопки при долгом нажатии.
              onPressed: () => _open(
                const BookForm(),
              ), // Открываем экран с теми же книгами и лайками, что в списке.
              child: const Icon(Icons.add),
            ),
            body: Column(
              children: [
                Padding(
                  // Оставляем свободное место вокруг содержимого.
                  padding: const EdgeInsets.all(
                    16,
                  ), // Создаём отступы внутри блока.
                  child: TextField(
                    controller: _search, // Запоминаем введённый текст, чтобы использовать его при сохранении.
                    onChanged: cubit.search, // Обрабатываем изменение поля.
                    onTapOutside:
                        (_) => // При нажатии вне поля завершаем ввод и скрываем клавиатуру.
                            FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: InputDecoration(
                      // Оформляем фон и рамку.
                      hintText: 'Поиск по названию книги', // Подсказываем ожидаемый формат ввода.
                      prefixIcon: const Icon(
                        Icons.search,
                      ), // Добавляем иконку перед вводимым текстом.
                      filled: true, // Закрашиваем фон поля ввода.
                      fillColor: Colors.white, // Выбираем цвет поля ввода.
                      border: OutlineInputBorder(
                        // Настраиваем рамку элемента.
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Делаем углы закруглёнными.
                        borderSide: BorderSide.none, // Задаём вид границы.
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<CatalogCubit, CatalogState>(
                    builder: (context, state) => _catalogBody(state, cubit),
                  ),
                ), // Выбираем загрузку, ошибку, пустую заглушку или список книг.
              ],
            ),
          );
        },
      ),
    ),
  );

  /// Показывает загрузку, ошибку, пустой список или список книг.
  /// По замечанию преподавателя состояния разделены обычными if,
  /// чтобы build не содержал вложенный тернарный оператор.
  Widget _catalogBody(CatalogState state, CatalogCubit cubit) {
    // Выбираем загрузку, ошибку, пустую заглушку или список книг.
    if (state is CatalogLoadInProgress) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is CatalogLoadFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16), // Создаём отступы внутри блока.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.error!, textAlign: TextAlign.center),
              const SizedBox(
                height: 16,
              ), // Оставляем промежуток между соседними элементами.
              ElevatedButton(
                // Создаём кнопку с фоном.
                onPressed: cubit.load,
                child: const Text('Обновить'),
              ),
            ],
          ),
        ),
      );
    }
    final books = state.visibleBooks; // Книги общего каталога.
    if (books.isEmpty) {
      return Center(
        child: Text(
          state.onlyLiked
              ? 'В избранном пока пусто'
              : state.query.trim().isNotEmpty
              ? 'Ничего не нашлось'
              : 'В каталоге пока пусто',
        ),
      );
    }
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
          .onDrag, // Разрешаем скрывать системную клавиатуру прокруткой.
      itemCount: books.length, // Передаём число элементов видимого списка.
      itemBuilder: (context, index) {
        // Строим карточку по её индексу.
        final book = books[index];
        return BookCard(
          book: book,
          likeCount:
              state.likeCounts[book.id] ??
              0, // Читаем общий счётчик из состояния каталога.
          isLiked: state.likedIds.contains(
            book.id,
          ), // Показываем, понравилась ли книга текущему пользователю.
          onLikeTap: () => cubit.toggleLike(
            book.id,
          ), // Ставим или снимаем лайк; при ошибке возвращаем прежнее значение.
          onDeleteTap: cubit.canManage(book)
              ? () => _delete(book)
              : null, // Разрешаем менять и удалять только свои книги.
          onCardTap: () => _open(
            BookDetailsScreen(book: book),
            slowOpening: true,
          ), // Открываем экран с теми же книгами и лайками, что в списке.
        );
      },
    );
  }
}
