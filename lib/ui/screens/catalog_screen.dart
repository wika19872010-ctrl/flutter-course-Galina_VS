import 'package:flutter/material.dart'; // виджеты и оформление Flutter

import '../widgets/book_card.dart'; // виджет карточки книги
import '../../domain/entities/book.dart'; // модель книги

import 'dart:async';
import 'dart:convert'; // для преобразования JSON в объекты Dart (встроенная библиотека)

import 'package:http/http.dart' as http; // библиотека для HTTP-запросов

import 'add_book_screen.dart'; //это второй экран
import '../../core/api_constants.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  //класс, который будет хранить состояние экрана каталога книг и управлять его изменениями.
  final Set<int> _likedIds = {}; // ID книг, добавленных в избранное
  bool _showOnlyLiked = false; // проверка включён ли фильтр избранного
  String _searchQuery = ''; // текст, введённый в строку поиска
  List<Book> _serverBooks = []; // книги, полученные с сервера
  bool _isLoading = false; // проверка выполняется ли загрузка книг
  String? _errorMessage; // cообщение об ошибке, если загрузка не удалась (String? - cтрока, которая может содержать текст или null)
  final TextEditingController _searchController = TextEditingController();

  Future<void> _loadBooks() async {
    // Асинхронная функция для получения книг с сервера
    //Future<void> означает, что функция выполняется не мгновенно и после завершения не возвращает значение
    if (!mounted || _isLoading) return;
    setState(() {
      _isLoading = true; // начинает загрузку книг
      _errorMessage = null; // убирает сообщение о предыдущей ошибке
    });
    try {
      //получение книг с сервера
      final url = Uri.parse(
        booksUrl, // откуда берем книги конкретно
      );
      debugPrint('Ожидаем загрузку каталога'); //сообщение о загрузке
      final response = await http.get(url).timeout(const Duration(seconds: 10)); //get запрос, await помогает ждать завершение запроса не блокируя интерфейс
      debugPrint('Ответ сервера: ${response.statusCode}'); //ответ сервера
      if (response.statusCode == 200) {
        //проверка ответа от сервера
        final List<dynamic> jsonList = jsonDecode(
          response.body,
        ); //раскодировка кода json в данные Dart
        final loadedBooks = jsonList.map((json) {
          //map() — метод, который проходит по каждому элементу списка и преобразует его
          return Book.fromJson(json as Map<String, dynamic>); //.fromJson() — фабричный конструктор, который создаёт объект Book из JSON
          //as Map<String, dynamic> — указываем, что текущий JSON-объект представляет собой словарь с текстовыми ключами
        }).toList(); //собирает полученные элементы в обычный список Dart.
        // Сортируем книги по ID: новые книги будут первыми
        loadedBooks.sort((a, b) => b.id.compareTo(a.id));
        if (!mounted) return;
        setState(() {
          _serverBooks = loadedBooks;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Не удалось загрузить каталог (HTTP ${response.statusCode}). '
              'Попробуйте ещё раз позже.';
        }); //если сервер вернул код ошибки типа 400, 404,500
      }
    } catch (error, stackTrace) {
      debugPrint('Ошибка загрузки каталога: $error\n$stackTrace');
      if (!mounted) return;
      final String message;
      if (error is TimeoutException) {
        message = 'Сервер не ответил за 10 секунд. Попробуйте ещё раз.';
      } else if (error is http.ClientException) {
        message =
            'Не удалось подключиться к серверу. '
            'Проверьте интернет-соединение и повторите загрузку.';
      } else if (error is FormatException ||
          error is TypeError ||
          error is ArgumentError) {
        message =
            'Сервер вернул данные в неподдерживаемом формате. '
            'Попробуйте ещё раз позже.';
      } else {
        message = 'Не удалось загрузить каталог. Попробуйте ещё раз.';
      }
      setState(() {
        _errorMessage = message;
      });
    } finally {
      //для завершения загрузки
      debugPrint('Загрузка завершена');
      if (mounted) {
        setState(() {
          _isLoading = false; //сообщаем Flutter, что загрузка закончилась
        });
      }
    }
  }

  @override
  void initState() {
    // Метод вызывается один раз при создании состояния экрана
    super.initState(); // Вызываем метод родительского класса
    _loadBooks(); // Запускаем загрузку книг с сервера
  }

  // функция удаления книги
  Future<void> _deleteBook(Book book) async {
    // Показываем окно подтверждения удаления
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          //cоздаёт окно с заголовком и кнопками
          title: Text('Удалить книгу?'),
          content: Text(
            'Вы действительно хотите удалить книгу «${book.title}»?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Удалить'),
            ),
          ],
        );
      },
    );
    // Если пользователь отказался — прекращаем выполнение
    if (confirmed != true || !mounted) return;
    try {
      // Отправляем запрос на удаление книги с сервера
      final response = await http
          .delete(Uri.parse('$booksUrl/${book.id}'))
          .timeout(const Duration(seconds: 10));
      // Проверяем, подтвердил ли сервер удаление
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        setState(() {
          // Удаляем книгу из каталога
          _serverBooks.removeWhere((item) => item.id == book.id);
          // Удаляем книгу из избранного
          _likedIds.remove(book.id);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Книга успешно удалена')));
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось удалить книгу: $error')),
      );
    }
  }

  //функция отвечает за добавление книги в избранное и удаление из избранного
  void _toggleLike(int id) {
    setState(() {
      //специальный метод: он сообщает Flutter, что состояние экрана изменилось и интерфейс необходимо обновить
      if (_likedIds.contains(id)) {
        //if - проверка условия = .contains(id) проверяет, содержится ли указанный id в этом множестве.
        _likedIds.remove(id); // если книга уже находится в избранном, удаляем её номер из множества.
      } else {
        //else означает «иначе» - эта часть выполняется, если условие if оказалось ложным
        _likedIds.add(id); // если книги нет в избранном — добавляем её
      }
    });
  }

  void _toggleFilter() {
    //отвечает за переключение между всеми книгами и только избранными (_toggleFilter — переключить фильтр)
    setState(() {
      _showOnlyLiked = !_showOnlyLiked; // Меняем значение на противоположное: false → true — включаем фильтр избранного, true → false — выключаем фильтр и показываем все книги
    });
  }

  @override
  void dispose() {
    // Освобождаем ресурсы при закрытии экрана
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleBooks = _serverBooks.where((book) {
      //берем книги с сервера
      // final visibleBooks = books.where((book) { //когда берем книги с локального файла
      // создаём список книг, которые должны отображаться на экране (books — исходный список всех книг, where() — перебирает книги и оставляет только подходящие)
      final matchesSearch = book.title.toLowerCase().contains(
        // проверяем, соответствует ли название книги поисковому запросу
        // book.title — название текущей книги
        // toLowerCase() — переводим название в нижний регистр
        // contains() — проверяем, содержится ли поисковый текст в названии
        _searchQuery.toLowerCase().trim(),
        // _searchQuery — текст, который пользователь ввёл в поиск
        // trim() — удаляет пробелы в начале и конце строки
      );

      // Проверяем, должна ли книга отображаться при фильтрации избранного:
      final matchesLiked = !_showOnlyLiked || _likedIds.contains(book.id);
      // ! — логическое НЕ, || — логическое ИЛИ (сли фильтр выключен, подходят все книги; если фильтр включён, подходят только книги из избранного)
      return matchesSearch && matchesLiked;
      // возвращаем результат проверки книги: && — логическое И; книга попадёт в список, только если обе проверки равны true
    }).toList(); // преобразует результат фильтрации в список
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 224, 239),
      //кнопка добавления новой книги
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 146, 176, 227),
        foregroundColor: Colors.black,
        shape: CircleBorder(side: BorderSide(color: Colors.black, width: 1)),
        tooltip: 'Добавить новую книгу', //подсказка всплывающая
        onPressed: () async {
          //переключает на второй экран и сохраняет изменения
          final Book? newBook = await Navigator.push<Book>(
            context,
            MaterialPageRoute(builder: (context) => const AddBookScreen()),
          );
          if (!mounted) return;
          if (newBook != null) {
            _searchController.clear();
            setState(() {
              _serverBooks.insert(0, newBook);
              _showOnlyLiked = false;
              _searchQuery = '';
              _errorMessage = null; //очищаем старую ошибку
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      appBar: AppBar(
        //основной заголовок
        backgroundColor: const Color.fromARGB(255, 165, 193, 241),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Каталог книг',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              'В избранном: ${_likedIds.length}', //${} позволяет вставить значение переменной в строку, _likedIds.length — количество ID в множестве избранного
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleFilter, // при нажатии вызываем функцию переключения фильтра
            tooltip:
                _showOnlyLiked // tooltip — всплывающая подсказка для кнопки
                ? 'Показать все книги' // если фильтр включён, предлагаем показать все книги
                : 'Показать только избранные', // если фильтр выключен, предлагаем показать избранные

            icon: Icon(_showOnlyLiked ? Icons.favorite : Icons.favorite_border), // если фильтр включён — показываем заполненное сердечко, если выключен — сердечко с контуром
          ),
        ],
      ),
      body: Column(
        children: [
          // Строка поиска
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  //обновляет отображение при вводе текста.
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Поиск по названию книги',
                prefixIcon: Tooltip(
                  message: 'Введите название книги или его часть',
                  child: Icon(Icons.search),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Список книг
          Expanded(
            child:
                _isLoading //если _isLoading == true показываем индикатор загрузки
                ? Center(child: CircularProgressIndicator())
                : _errorMessage !=
                      null // если загрузка завершилась, проверяем наличие ошибки
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                          ), // показываем текст ошибки
                          SizedBox(height: 16),
                          ElevatedButton(
                            // кнопка повторной загрузки
                            onPressed: _loadBooks,
                            child: Text('Повторить загрузку'),
                          ),
                        ],
                      ),
                    ),
                  )
                : visibleBooks //список книг, оставшихся после поиска и фильтрации
                      .isEmpty //проверка пустой список или нет
                ? Center(
                    // если список пустой, размещает сообщение по центру
                    child: Text(
                      _showOnlyLiked &&
                              _likedIds
                                  .isEmpty // Проверяет два условия: включён фильтр избранного; в списке избранного нет книг
                          ? 'В избранном пока пусто' // если оба условия выполняются, показываем этот текст
                          : 'Ничего не нашлось', // в остальных вариантах
                    ),
                  )
                : ListView.builder(
                    //если книги есть создаем список
                    itemCount: visibleBooks
                        .length, // количество книг после поиска и фильтрации
                    itemBuilder: (context, index) {
                      final book = visibleBooks[index]; // получаем книгу из списка по индексу

                      return BookCard(
                        book: book,
                        isLiked: _likedIds.contains(
                          book.id,
                        ), // проверяет, находится ли книга в избранном
                        onLikeTap: () => _toggleLike(book.id), // при нажатии на сердечко добавляет или удаляет книгу из избранного
                        onDeleteTap: () => _deleteBook(book), // для удаления
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
