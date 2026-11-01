// Файл формы добавления и редактирования книги; обязательным полем является только название.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/error_messages.dart';
import '../../domain/book.dart';
import '../../logic/books_cubit.dart';
import '../theme/app_styles.dart';
import 'book_cover_size.dart';
import 'book_form_field.dart';
import 'book_genre_labels.dart';
import 'book_image.dart';
import 'cover_picker.dart';
import '../../logic/books_state.dart';

/// Отдельный экран для добавления книги; переданная книга открывает редактирование.
class BookForm extends StatefulWidget {
  /// Книга для редактирования; null означает создание новой книги.
  final Book? book;

  /// Создаёт форму: без книги для добавления, с книгой для редактирования.
  const BookForm({super.key, this.book});

  /// Создаёт объект состояния, который хранит изменяемые данные этого виджета.
  @override
  State<BookForm> createState() => _BookFormState();
}

/// Хранит поля формы, выбранные жанры и превью обложки до сохранения книги.
class _BookFormState extends State<BookForm> {
  /// Контроллеры позволяют работать с текстом каждого поля формы.
  final Map<String, TextEditingController> _fields = {};

  /// Жанры, выбранные интерактивными кнопками FilterChip.
  final Set<BookGenre> _genres = {};

  /// Выбранное возрастное ограничение книги.
  int _ageRating = 0;

  /// Путь или ссылка на обложку, которые отправляются на сервер.
  String _imagePath = '';

  /// Открывает галерею для выбора фотографии.
  final ImagePicker _picker = ImagePicker();

  /// Локальное превью; байты фотографии не отправляются в Firestore.
  Uint8List? _selectedImage;

  /// Подготавливаем локальные поля один раз при открытии экрана.
  @override
  void initState() {
    super.initState(); // Подготавливаем локальные поля один раз при открытии экрана.
    final data =
        widget.book?.toJson() ??
        <String, dynamic>{}; // Храним данные книги в обычном JSON-формате.
    for (final key in [
      // Проверяем записи по одной.
      'title',
      'author',
      'year',
      'pages',
      'publisher',
      'isbn',
      'dimensions',
      'authorCountry',
      'description',
    ]) {
      _fields[key] = TextEditingController(
        text: data[key]?.toString() ?? '',
      ); // Используем запасное значение, если основное отсутствует.
    }
    _genres.addAll(
      widget.book?.genres ?? [],
    ); // Добавляем полученные записи в список.
    _ageRating =
        widget.book?.ageRating ??
        0; // Используем запасное значение, если основное отсутствует.
    _imagePath =
        widget.book?.image ??
        ''; // Используем запасное значение, если основное отсутствует.
  }

  /// Метод dispose освобождает ресурсы контроллеров при закрытии формы.
  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  /// Получает текст поля и убирает пробелы по краям перед сохранением.
  String _text(String key) => _fields[key]!.text.trim();

  /// Проверяет название и сохраняет книгу через Cubit.
  /// Запись в Firestore выполняет репозиторий.
  Future<void> _save() async {
    final cubit = context
        .read<CatalogCubit>(); // Получаем общие данные списка и подробностей.
    // Не разрешаем повторное сохранение, пока предыдущий запрос не завершён.
    if (cubit.state.savingBook) return;
    if (_text('title').isEmpty) {
      // Не отправляем книгу без обязательного названия.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название книги')));
      return;
    }
    if (_selectedImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Фото доступно только для предпросмотра. Выберите готовую обложку '
            'или ссылку, либо уберите фото перед сохранением.',
          ),
        ),
      );
      return;
    }
    // Подготавливаем данные для отправки на сервер.
    final data = <String, dynamic>{
      for (final key in _fields.keys)
        key: _text(key), // Проверяем записи по одной.
      'year':
          int.tryParse(_text('year')) ??
          0, // Передаём год издания; ноль означает, что год не указан.
      'pages': int.tryParse(
        _text('pages'),
      ), // Передаём число страниц, если оно известно.
      'genres': _genres
          .map((genre) => genre.name)
          .toList(), // Передаём список жанров книги.
      'ageRating': _ageRating, // Передаём возрастное ограничение.
      'image': _imagePath, // Передаём путь к обложке или адрес картинки.
    };
    try {
      await cubit.saveBook(data, id: widget.book?.id);
      if (!mounted) {
        return;
      } // Обновляем экран, только если пользователь ещё не ушёл с него.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
        } // Обновляем экран, только если пользователь ещё не ушёл с него.
      });
    } catch (error) {
      // Если запрос не удался, показываем ошибку вместо закрытия приложения.
      if (!mounted) {
        return;
      } // Обновляем экран, только если пользователь ещё не ушёл с него.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Создаём краткое сообщение пользователю.
          content: Text(
            requestErrorMessage(
              // Выбираем понятное сообщение о сетевой ошибке или формате данных.
              error,
              timeoutSeconds: 15,
              fallback: 'Не удалось сохранить книгу. Попробуйте ещё раз.',
            ),
          ),
        ),
      );
    }
  }

  /// Метод для выбора изображения из галереи и показа превью.
  /// Фото может отсутствовать: null означает, что пользователь его не выбрал.
  /// В Firestore сохраняется ссылка или asset, а не локальный файл фотографии.
  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1600,
      );
      if (!mounted || image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _selectedImage = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Не удалось открыть фотографию. Проверьте доступ к фото и попробуйте снова.',
          ),
        ),
      );
    }
  }

  /// Выбирает путь или ссылку, которую можно сохранить для всех пользователей.
  Future<void> _chooseCover() async {
    final path = await chooseBookCover(
      context,
      _imagePath,
    ); // Храним путь к asset либо HTTP-адрес картинки.
    if (mounted && path != null) {
      setState(() {
        _imagePath = path;
        _selectedImage = null;
      });
    } // Обновляем экран, только если пользователь ещё не ушёл с него.
  }

  /// Добавляем поле книги с общим оформлением.
  Widget _field(
    String key,
    String label,
    String hint, {
    int maxLines = 1,
    int? minLines,
    bool numeric = false,
  }) => BookFormField(
    label: label,
    hintText: hint, // Подсказываем ожидаемый формат ввода.
    controller: _fields[key]!, // Запоминаем введённый текст, чтобы использовать его при сохранении.
    maxLines: maxLines, // Ограничиваем число строк текста.
    minLines: minLines, // Оставляем место для нескольких строк текста.
    keyboardType: numeric ? TextInputType.number : null, // Выбираем удобную клавиатуру; ввод с физической клавиатуры тоже работает.
  );

  /// Создаёт интерфейс этого виджета на основе текущих данных и подключает действия кнопок.
  @override
  Widget build(BuildContext context) => BlocBuilder<CatalogCubit, CatalogState>(
    buildWhen: (previous, current) => previous.savingBook != current.savingBook,
    builder: (context, state) => PopScope(
      canPop: !state
          .savingBook, // Запрещаем закрытие формы, пока сохраняется книга.
      child: Scaffold(
        backgroundColor: AppColors.background, // Выбираем цвет фона.
        appBar: AppBar(
          // Создаём верхнюю панель экрана.
          backgroundColor: AppColors.surface, // Выбираем цвет фона.
          title: Text(
            widget.book == null
                ? 'Добавить новую книгу'
                : 'Редактировать книгу',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ), // Выбираем оформление текста.
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
                .onDrag, // Разрешаем скрывать системную клавиатуру прокруткой.
            padding: const EdgeInsets.fromLTRB(
              8,
              16,
              16,
              16,
            ), // Создаём отступы внутри блока.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _field(
                  // Добавляем поле книги с общим оформлением.
                  'title',
                  'Наименование книги',
                  'Введите название книги',
                  maxLines: 5, // Ограничиваем число строк текста.
                ),
                _field(
                  'author',
                  'Автор',
                  'Введите имя автора',
                  maxLines: 2,
                ), // Добавляем поле книги с общим оформлением.
                _field(
                  // Добавляем поле книги с общим оформлением.
                  'year',
                  'Год издания',
                  'Введите год издания, например: 1950',
                  numeric: true,
                ),
                _field(
                  // Добавляем поле книги с общим оформлением.
                  'pages',
                  'Количество страниц',
                  'Введите количество страниц, например: 350',
                  numeric: true,
                ),
                _field(
                  // Добавляем поле книги с общим оформлением.
                  'publisher',
                  'Издательство',
                  'Введите название издательства',
                ),
                _field(
                  'isbn',
                  'ISBN',
                  'Например: 978-5-17-123456-7',
                ), // Добавляем поле книги с общим оформлением.
                _field(
                  // Добавляем поле книги с общим оформлением.
                  'dimensions',
                  'Размеры книги',
                  'Например: 20 × 13 × 3 см',
                ),
                const Text('Жанр книги', style: AppStyles.fieldLabel),
                const SizedBox(
                  height: 8,
                ), // Оставляем промежуток между соседними элементами.
                Wrap(
                  // Создаём перенос плашек на новую строку.
                  spacing: 8, // Задаём промежутки между элементами.
                  runSpacing: 8, // Задаём промежутки между рядами плашек.
                  children: [
                    for (final genre
                        in BookGenre.values) // Проверяем записи по одной.
                      FilterChip(
                        // Создаём выбор жанра.
                        label: Text(genre.formLabel),
                        selected: _genres.contains(
                          genre,
                        ), // Показываем выбранное состояние.
                        backgroundColor: Colors.white, // Выбираем цвет фона.
                        selectedColor: AppColors.accent,
                        checkmarkColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          // Сохраняем форму кнопки или карточки.
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Делаем углы закруглёнными.
                          side: const BorderSide(color: Colors.black),
                        ),
                        onSelected: (selected) => setState(() {
                          // Обновляем поля и кнопки на этом экране.
                          selected
                              ? _genres.add(genre)
                              : _genres.remove(
                                  genre,
                                ); // Убираем ненужные записи из списка.
                        }),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ), // Оставляем промежуток между соседними элементами.
                const Text(
                  'Возрастное ограничение',
                  style: AppStyles.fieldLabel, // Выбираем оформление текста.
                ),
                const SizedBox(
                  height: 8,
                ), // Оставляем промежуток между соседними элементами.
                DropdownButtonFormField<int>(
                  // Создаём выпадающий список.
                  initialValue: _ageRating, // Восстанавливаем начальное значение элемента.
                  decoration: InputDecoration(
                    // Оформляем фон и рамку.
                    filled: true, // Закрашиваем фон поля ввода.
                    fillColor: Colors.white, // Выбираем цвет поля ввода.
                    border: OutlineInputBorder(
                      // Настраиваем рамку элемента.
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Делаем углы закруглёнными.
                    ),
                  ),
                  items: [
                    for (final age in [
                      0,
                      6,
                      12,
                      16,
                      18,
                    ]) // Проверяем записи по одной.
                      DropdownMenuItem(value: age, child: Text('$age+')),
                  ],
                  onChanged: (value) {
                    // Обрабатываем изменение поля.
                    if (value != null) setState(() => _ageRating = value);
                  },
                ),
                const SizedBox(
                  height: 20,
                ), // Оставляем промежуток между соседними элементами.
                _field(
                  // Добавляем поле книги с общим оформлением.
                  'authorCountry',
                  'Страна автора',
                  'Введите наименование страны автора',
                ),
                _field(
                  // Добавляем поле книги с общим оформлением.
                  'description',
                  'Подробное описание книги',
                  'Введите подробную информацию о книге',
                  maxLines: 10, // Ограничиваем число строк текста.
                  minLines: 5, // Оставляем место для нескольких строк текста.
                ),
                const Text('Обложка книги', style: AppStyles.fieldLabel),
                const SizedBox(
                  height: 20,
                ), // Оставляем промежуток между соседними элементами.
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: bookCoverWidth, // Задаём ширину элемента.
                    height: bookCoverHeight, // Задаём высоту элемента.
                    decoration: BoxDecoration(
                      // Оформляем фон и рамку.
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Делаем углы закруглёнными.
                      border: Border.all(), // Настраиваем рамку элемента.
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Делаем углы закруглёнными.
                      child: _selectedImage != null
                          ? Image.memory(
                              _selectedImage!,
                              width: bookCoverWidth,
                              height: bookCoverHeight,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stack) => const Center(
                                child: Text('Не удалось показать фото'),
                              ),
                            )
                          : _imagePath.isEmpty
                          ? const Column(
                              // Располагаем содержимое сверху вниз.
                              mainAxisAlignment: MainAxisAlignment.center, // Задаём выравнивание вдоль основной оси.
                              children: [
                                Icon(
                                  // Создаём иконку.
                                  Icons.add_photo_alternate_outlined,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10), // Оставляем промежуток между соседними элементами.
                                Text(
                                  'Выбрать обложку',
                                  style: TextStyle(
                                    // Выбираем оформление текста.
                                    color: Colors.grey,
                                    fontSize: 13, // Выбираем размер текста.
                                  ),
                                ),
                              ],
                            )
                          : BookImage(
                              path: _imagePath,
                            ), // Создаём картинку обложки.
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ), // Оставляем промежуток между соседними элементами.
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(
                    _selectedImage == null
                        ? 'Открыть галерею'
                        : 'Изменить фото',
                  ),
                ),
                if (_selectedImage != null) ...[
                  const Text(
                    'Фото из галереи — только предпросмотр. Для сохранения '
                    'выберите готовую обложку или ссылку на изображение.',
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedImage = null),
                    child: const Text('Убрать фото'),
                  ),
                ],
                TextButton.icon(
                  // Создаём кнопку с надписью.
                  onPressed: _chooseCover,
                  icon: const Icon(Icons.link),
                  label: Text(
                    _imagePath.isEmpty ? 'Выбрать обложку' : 'Изменить обложку',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ), // Оставляем промежуток между соседними элементами.
                Row(
                  // Создаём горизонтальный ряд.
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52, // Задаём высоту элемента.
                        child: ElevatedButton(
                          onPressed: state.savingBook ? null : _save,
                          style: ElevatedButton.styleFrom(
                            // Выбираем оформление текста.
                            backgroundColor:
                                AppColors.surface, // Выбираем цвет фона.
                            foregroundColor:
                                Colors.black, // Задаём цвет текста и иконок.
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ), // Создаём отступы внутри блока.
                            shape: RoundedRectangleBorder(
                              // Сохраняем форму кнопки или карточки.
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Делаем углы закруглёнными.
                              side: const BorderSide(color: Colors.black),
                            ),
                          ),
                          child: Text(
                            state.savingBook
                                ? 'Сохранение…'
                                : widget.book == null
                                ? 'Добавить книгу'
                                : 'Сохранить изменения',
                            textAlign:
                                TextAlign.center, // Задаём выравнивание текста.
                            style: const TextStyle(
                              // Выбираем оформление текста.
                              fontSize: 14, // Выбираем размер текста.
                              fontWeight:
                                  FontWeight.bold, // Выбираем толщину букв.
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ), // Оставляем промежуток между соседними элементами.
                    Expanded(
                      child: SizedBox(
                        height: 52, // Задаём высоту элемента.
                        child: OutlinedButton(
                          onPressed: state.savingBook
                              ? null
                              : () => Navigator.pop(context), // Закрываем текущий экран и возвращаемся назад.
                          style: OutlinedButton.styleFrom(
                            // Выбираем оформление текста.
                            foregroundColor:
                                Colors.black, // Задаём цвет текста и иконок.
                            backgroundColor:
                                Colors.white, // Выбираем цвет фона.
                            shape: RoundedRectangleBorder(
                              // Сохраняем форму кнопки или карточки.
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Делаем углы закруглёнными.
                              side: const BorderSide(color: Colors.black),
                            ),
                          ),
                          child: Text(
                            widget.book == null ? 'Отмена' : 'Отменить',
                            style: const TextStyle(
                              // Выбираем оформление текста.
                              fontSize: 14, // Выбираем размер текста.
                              fontWeight:
                                  FontWeight.bold, // Выбираем толщину букв.
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ), // Оставляем промежуток между соседними элементами.
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
