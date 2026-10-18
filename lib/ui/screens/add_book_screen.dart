//это отдельный экран для добавления новой книги
import 'package:flutter/material.dart';

import '../../domain/entities/book.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_constants.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController =
      TextEditingController(); //позволяет работать с текстом
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // _picker — открывает галерею, _selectedImage — хранит выбранную фотографию
  File? _selectedImage; // File? означает, что фотография может отсутствовать
  final Set<BookGenre> _selectedGenres = {};
  int _selectedAgeRating = 0;
  bool _isSaving = false; // true — книга сохраняется на сервере, false — сохранение не выполняется

  @override
  void dispose() {
    //метод dispose() освобождает ресурсы контроллера, который больше не нужен.
    _titleController.dispose();
    _authorController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Widget _buildGenreChip(BookGenre genre, String label) {
    //метод для интерактивных кнопок выбора жанра
    final bool isSelected = _selectedGenres.contains(genre);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      backgroundColor: Colors.white,
      selectedColor: const Color.fromARGB(255, 146, 176, 227),
      checkmarkColor: Colors.black,
      showCheckmark: true,
      labelStyle: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black, width: 1),
      ),
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _selectedGenres.add(genre);
          } else {
            _selectedGenres.remove(genre);
          }
        });
      },
    );
  }

  Future<void> _saveBook() async {
    // Получаем название книги и удаляем лишние пробелы
    final String title = _titleController.text.trim();
    // Проверяем, заполнено ли название
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название книги')));
      return; // Прекращаем сохранение
    }
    // Не разрешаем повторное сохранение
    if (_isSaving) return;
    // Сообщаем Flutter, что началось сохранение
    setState(() {
      _isSaving = true;
    });
    try {
      // Подготавливаем данные для отправки на сервер
      final Map<String, dynamic> bookData = {
        'title': title,
        'author': _authorController.text.trim(),
        'year': int.tryParse(_yearController.text.trim()) ?? 0,
        'genres': _selectedGenres.map((genre) => genre.name).toList(),
        'ageRating': _selectedAgeRating,
        'description': _descriptionController.text.trim(),
        'image': '',
      };
      // Отправляем POST-запрос
      final response = await http
          .post(
            Uri.parse(booksUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(bookData),
          )
          .timeout(const Duration(seconds: 15));
      // Код 201 означает, что книга успешно создана
      if (response.statusCode == 201) {
        final Book newBook = Book.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        if (!mounted) return;
        // Возвращаем новую книгу на экран каталога
        Navigator.pop(context, newBook);
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось добавить книгу: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    //метод для выбора изображения из галереии
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (!mounted || image == null) return;
      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось выбрать изображение: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 224, 239),
      appBar: AppBar(
        title: Text(
          'Добавить новую книгу',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 165, 193, 241),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(8, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Наименование книги',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              TextField(
                //поле для ввода текста
                controller: _titleController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Введите название книги',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Автор',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              TextField(
                //поле для ввода текста
                controller: _authorController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Введите имя автора',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Год издания',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              TextField(
                //поле для ввода текста
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Введите год издания, например: 1950',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Жанр книги',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildGenreChip(BookGenre.fantasy, 'Фэнтези'),
                  _buildGenreChip(BookGenre.friendship, 'Дружба'),
                  _buildGenreChip(BookGenre.noRomance, 'Нет романтики'),
                  _buildGenreChip(BookGenre.novella, 'Новелла'),
                ],
              ),
              SizedBox(height: 20),

              Text(
                'Возрастное ограничение',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _selectedAgeRating,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 0, child: Text('0+')),
                  DropdownMenuItem(value: 6, child: Text('6+')),
                  DropdownMenuItem(value: 12, child: Text('12+')),
                  DropdownMenuItem(value: 16, child: Text('16+')),
                  DropdownMenuItem(value: 18, child: Text('18+')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAgeRating = value;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              Text(
                'Страна автора',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              TextField(
                //поле для ввода текста
                controller: _descriptionController,

                decoration: InputDecoration(
                  hintText: 'Введите наименование страны автора',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Обложка книги',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Выбрать обложку',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  width: 150,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo_library_outlined),
                      label: Text(
                        _selectedImage == null
                            ? 'Открыть галерею'
                            : 'Изменить обложку',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  // Кнопка добавления книги
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : _saveBook, //сохранение книги
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            165,
                            193,
                            241,
                          ),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Добавить книгу',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Кнопка отмены
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        //Кнопка отмены
                        onPressed: () {
                          Navigator.pop(context); //закрывает текущий экран и возвращает на предыдущий
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        child: Text(
                          'Отмена',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
