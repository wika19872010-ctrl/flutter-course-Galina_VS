// Файл экрана подробностей книги с личным лайком, редактированием и удалением своих книг.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/book.dart';
import '../../logic/catalog_cubit.dart';
import '../theme/app_styles.dart';
import '../widgets/book_cover.dart';
import '../widgets/book_form.dart';
import '../widgets/book_metadata.dart';
import '../widgets/book_property.dart';
import '../widgets/delete_book_dialog.dart';

/// Показывает полную информацию о книге, лайк и доступные действия с книгой.
class BookDetailsScreen extends StatelessWidget {
  final Book book;

  /// Принимает книгу, подробную информацию о которой нужно открыть.
  const BookDetailsScreen({super.key, required this.book});

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) => BlocBuilder<CatalogCubit, CatalogState>(
    builder: (context, state) {
      final cubit = context
          .read<CatalogCubit>(); // Получаем общие данные списка и подробностей.
      final current = state.books.firstWhere(
        // Находим последнюю сохранённую версию открытой книги.
        (item) => item.id == book.id,
        orElse: () => book,
      );
      return Scaffold(
        backgroundColor: AppColors.background, // Выбираем цвет фона.
        appBar: AppBar(
          // Создаём верхнюю панель экрана.
          backgroundColor: AppColors.surface, // Выбираем цвет фона.
          title: const Text('О книге'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12), // Создаём отступы внутри блока.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cubit.canManage(current)) ...[
                        // Показываем редактирование и удаление только у своей книги.
                        IconButton(
                          // Создаём кнопку со значком.
                          tooltip: 'Редактировать книгу', // Поясняем назначение кнопки при долгом нажатии.
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                            size: 25,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              // Открываем форму с данными выбранной книги.
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: BookForm(book: current),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          // Создаём кнопку со значком.
                          tooltip: 'Удалить книгу', // Поясняем назначение кнопки при долгом нажатии.
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 25,
                          ),
                          onPressed: () async {
                            if (!await confirmBookDeletion(
                                  // Сначала спрашиваем, действительно ли нужно удалить книгу.
                                  context,
                                  current,
                                ) ||
                                !context.mounted) {
                              return;
                            }
                            if (await cubit.deleteBook(current) &&
                                context.mounted) {
                              Navigator.pop(context); // Закрываем текущий экран и возвращаемся назад.
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  // Создаём горизонтальный ряд.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      // Оставляем свободное место вокруг содержимого.
                      padding: EdgeInsets.zero, // Создаём отступы внутри блока.
                      child: BookCover(
                        book: current,
                        isLiked: state.likedIds.contains(current.id), // Показываем, понравилась ли книга текущему пользователю.
                        onLikeTap: () => cubit.toggleLike(current.id), // Ставим или снимаем лайк; при ошибке возвращаем прежнее значение.
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ), // Оставляем промежуток между соседними элементами.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BookHeading(
                            book: current,
                          ), // Создаём название, автора, год и страну книги.
                          const SizedBox(
                            height: 12,
                          ), // Оставляем промежуток между соседними элементами.
                          BookProperty(
                            // Показываем дополнительное сведение о книге.
                            label: 'Страниц',
                            value: current.pages,
                            emptyText: 'Не указано',
                          ),
                          const SizedBox(
                            height: 8,
                          ), // Оставляем промежуток между соседними элементами.
                          BookProperty(
                            // Показываем дополнительное сведение о книге.
                            label: 'Издательство',
                            value: current.publisher,
                            emptyText: 'Не указано',
                          ),
                          const SizedBox(
                            height: 8,
                          ), // Оставляем промежуток между соседними элементами.
                          BookProperty(
                            // Показываем дополнительное сведение о книге.
                            label: 'Размеры',
                            value: current.dimensions,
                            emptyText: 'Не указаны',
                          ),
                          const SizedBox(
                            height: 8,
                          ), // Оставляем промежуток между соседними элементами.
                          BookProperty(
                            // Показываем дополнительное сведение о книге.
                            label: 'ISBN',
                            value: current.isbn,
                            emptyText: 'Не указан',
                          ),
                          const SizedBox(
                            height: 12,
                          ), // Оставляем промежуток между соседними элементами.
                          BookGenres(
                            book: current,
                          ), // Показываем жанры книги в цветных плашках.
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ), // Оставляем промежуток между соседними элементами.
                const Text(
                  'Подробное описание книги',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ), // Выбираем оформление текста.
                ),
                const SizedBox(
                  height: 12,
                ), // Оставляем промежуток между соседними элементами.
                Container(
                  // Создаём оформленный контейнер.
                  height: 200, // Задаём высоту элемента.
                  width: double.infinity, // Задаём ширину элемента.
                  padding: const EdgeInsets.all(
                    12,
                  ), // Создаём отступы внутри блока.
                  decoration: BoxDecoration(
                    // Оформляем фон и рамку.
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Делаем углы закруглёнными.
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      current.description?.trim().isNotEmpty == true
                          ? current.description!
                          : 'Описание отсутствует',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ), // Выбираем оформление текста.
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
