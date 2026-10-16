import 'package:flutter/material.dart';

import '../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool isLiked;
  final VoidCallback onLikeTap;

  const BookCard({
    super.key,
    required this.book,
    required this.isLiked,
    required this.onLikeTap,
  });

  // Функция переводит жанр на русский язык

  String getGenreName(BookGenre genre) {
    switch (genre) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 165, 193, 241),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        //карточка
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          //обложка с сердечком
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    book.image,
                    width: 125,
                    height: 183,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 243, 133, 100),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      '18+',
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
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: onLikeTap,
                      constraints: BoxConstraints(),
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : const Color.fromARGB(255, 97, 96, 96),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 5,

                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${book.author},${book.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 32, 24, 135),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final genre in book.genres)
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
                            getGenreName(genre),
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                        ),
                      if (book.description != null)
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
                            book.description!,
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
