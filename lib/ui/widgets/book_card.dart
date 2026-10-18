import 'package:flutter/material.dart'; //библиотека Flutter

import '../../domain/entities/book.dart'; //откуда подключена модель книг

class BookCard extends StatelessWidget {
  //создала виджет карточки книги
  final Book book; //информация о книге
  final bool isLiked; //информация - добавлена ли книга в избранное
  final VoidCallback onLikeTap; //эта строка нужна, чтобы карточка книги могла реагировать на нажатие сердечка
  final VoidCallback onDeleteTap; // действие при нажатии на кнопку удаления

  // конструктор, через который карточка получает необходимые данные
  const BookCard({
    super.key, //ключ (super - обращение к родительскому классу, key - специальный параметр Flutter для идентификации виджета)
    required this.book,
    required this.isLiked,
    required this.onLikeTap,
    required this.onDeleteTap,
  });

  // Функция переводит жанр на русский язык
  String getGenreName(BookGenre genre) {
    switch (genre) {
      //проверяем, какое значение жанра передано в функцию
      //к примеру: если жанр fantasy — возвращаем "Зарубежное фэнтези"
      case BookGenre.fantasy:
        return 'Зарубежное фэнтези';

      case BookGenre.novella:
        return 'Новелла';

      case BookGenre.noRomance:
        return 'Нет романтики';

      case BookGenre.friendship:
        return 'Дружба';
    }
  }

  @override // указываем, что переопределяем метод build родительского класса
  Widget build(BuildContext context) {
    // метод build создаёт интерфейс карточки книги
    // Widget — тип возвращаемого значения
    // BuildContext context — информация о положении виджета в дереве Flutter
    return Card(
      //возвращаем виджет Card — основную карточку книги
      color: const Color.fromARGB(255, 165, 193, 241),
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), //внешние отступы карточки
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), //форма карточки
      child: Padding(
        // Padding добавляет внутренние отступы
        padding: EdgeInsets.all(12),
        //карточка
        child: Row(
          //Row размещает элементы горизонтально:
          crossAxisAlignment:
              CrossAxisAlignment.start, //выравниваем элементы по верхнему краю
          //обложка с сердечком
          children: [
            Stack(
              //Stack позволяет накладывать виджеты друг на друга
              children: [
                ClipRRect(
                  //ClipRRect обрезает изображение по заданной форме
                  borderRadius: BorderRadius.circular(12),
                  child: book.image.trim().isEmpty
                      ? Container(
                          width: 125,
                          height: 183,
                          color: Colors.white,
                          child: const Center(
                            child: Icon(
                              Icons.menu_book,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Image.asset(
                          book.image,
                          width: 125,
                          height: 183,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 125,
                              height: 183,
                              color: Colors.white,
                              child: Center(
                                child: Icon(
                                  Icons.menu_book,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (book.ageRating > 0) //показываем возрастной бейдж, только если есть возрастное ограничение
                  Positioned(
                    //Positioned размещает виджет внутри Stack
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 243, 133, 100),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        '${book.ageRating}+', //получаем возраст из модели Book
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 7,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 226, 206, 206),
                      shape: BoxShape.circle, //делает контейнер круглым
                    ),
                    child: IconButton(
                      //IconButton — кнопка с иконкой избранное
                      padding:
                          EdgeInsets.zero, //убирает внутренние отступы кнопки
                      onPressed: onLikeTap, //функция, которая вызывается при нажатии, onLikeTap передаётся из CatalogScreen
                      constraints: BoxConstraints(), //убираем дополнительные ограничения размера кнопки
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border, //условие ? значениеЕслиДа : значениеЕслиНет
                        color: isLiked
                            ? Colors.red
                            : const Color.fromARGB(255, 97, 96, 96),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //для расстояния между обложкой и текстом
            SizedBox(width: 12),
            //информация о книге
            Expanded(
              //Expanded занимает всё оставшееся место внутри Row
              child: Column(
                //колонна
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: onDeleteTap,
                      tooltip: 'Удалить книгу',
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                        size: 25,
                      ),
                    ),
                  ),
                  Text(
                    book.title, //получаем название из объекта Book
                    maxLines: 5, //количество строк для текста

                    overflow: TextOverflow.ellipsis, // если текст не помещается - обрезаем текст и добавляем многоточие (...)
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${book.author},${book.year}', //объединяем автора и год в одну строку
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 32, 24, 135),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    // Wrap размещает теги жанров рядом друг с другом, если теги не помещаются по ширине, они автоматически переносятся на следующую строку
                    spacing: 8, //горизонтальное расстояние между тегами
                    runSpacing:
                        6, //вертикальное расстояние между строками тегов
                    children: [
                      for (final genre
                          in book
                              .genres) //for перебирает все жанры текущей книги
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            getGenreName(
                              genre,
                            ), //функция переводит жанр на русский язык
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                        ),
                      if (book.description != null) //условие проверяет наличие описания, != означает "не равно", null означает отсутствие значения
                        // Если описание существует — показываем контейнер
                        // Если description == null — контейнер не создаётся
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            book.description!, // ! сообщает Dart, что здесь значение не null, выше мы уже проверили это условием if
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
