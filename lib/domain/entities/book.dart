class Book {
  final int id;
  final String title;
  final String author;
  final List<BookGenre>genres;
  final int year;
  final String image;
  final String? description;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genres,
    required this.year,
    required this.image,
    this.description,
  });
}

enum BookGenre { fantasy, novella, noRomance,  friendship}
