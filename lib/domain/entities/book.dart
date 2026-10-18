// Модель книги — описывает, какие данные содержит каждая книга
class Book {
  final int id;
  final String title;
  final String author;
  final List<BookGenre> genres;
  final int year;
  final String image;
  final String? description;
  final int ageRating; // возрастное ограничение книги

  // Конструктор — создаёт объект Book с указанными данными
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genres,
    required this.year,
    required this.image,
    this.description,
    required this.ageRating,
  });
  // преобразует JSON с сервера в объект Book

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: int.parse(json['id'].toString()), //Преобразует id из JSON в целое число (int)
      title: json['title'] as String,//Получает название книги из JSON и проверяет тип String
      author: json['author'] as String,
      genres: (json['genres'] as List) //расценивает строку как список
          .map((genre) => BookGenre.values.byName(genre as String)) //перибирает данные сравнивая с enum
          .toList(), //превращает в список
      year: (json['year'] as num).toInt(), // конвертирует в целые числа (int)
      image: json['image'] as String, 
      description: json['description'] as String?, // Получает описание из JSON, за счет знака ? допускает String или null
      ageRating: (json['ageRating'] as num).toInt(),// получаем ограничение в числах
    );
  }

  // преобразует объект Book в JSON для отправки на сервер

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'genres': genres.map((genre) => genre.name).toList(), //map преобразует список в строку (так принимает JSON)
      'year': year,
      'image': image,
      'description': description ?? '',
      'ageRating': ageRating,
    };
  }
}

enum BookGenre { fantasy, novella, noRomance, friendship }
