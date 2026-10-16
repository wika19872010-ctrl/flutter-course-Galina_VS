import 'package:flutter/material.dart';

import '../widgets/book_card.dart';

import '../../domain/entities/book.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<int> _likedIds = {};
  bool _showOnlyLiked = false;
  String _searchQuery = '';
  void _toggleLike(int id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  void _toggleFilter() {
    setState(() {
      _showOnlyLiked = !_showOnlyLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleBooks = books.where((book) {
      final matchesSearch = book.title.toLowerCase().contains(
        _searchQuery.toLowerCase().trim(),
      );

      final matchesLiked = !_showOnlyLiked || _likedIds.contains(book.id);

      return matchesSearch && matchesLiked;
    }).toList();
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 224, 239),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 165, 193, 241),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Каталог книг',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              'В избранном: ${_likedIds.length}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleFilter,
            tooltip: _showOnlyLiked
                ? 'Показать все книги'
                : 'Показать только избранные',

            icon: Icon(_showOnlyLiked ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: Column(
        children: [
          // Строка поиска
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
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
            child: visibleBooks.isEmpty
                ? Center(child: Text('Ничего не нашлось'))
                : ListView.builder(
                    itemCount: visibleBooks.length,
                    itemBuilder: (context, index) {
                      final book = visibleBooks[index];

                      return BookCard(
                        book: book,
                        isLiked: _likedIds.contains(book.id),
                        onLikeTap: () => _toggleLike(book.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

const List<Book> books = [
  Book(
    id: 1,
    title: 'Я стал отбросом графской семьи. Том 1 (Я стал графским ублюдком). Новелла',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2025,
    image: 'assets/tom1.png',
    description: 'Корея',
  ),
  Book(
    id: 2,
    title: 'Я стал отбросом графской семьи. Том 1 (Я стал графским ублюдком). Новелла + официальный мерч',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2025,
    image: 'assets/tom1+.png',
    description: 'Корея',
  ),
  Book(
    id: 3,
    title: 'Я стал отбросом графской семьи. Том 2 (Я стал графским ублюдком). Новелла',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2025,
    image: 'assets/tom2.png',
    description: 'Корея',
  ),
  Book(
    id: 4,
    title: 'Я стал отбросом графской семьи. Том 2 (Я стал графским ублюдком). Новелла + официальный мерч',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2025,
    image: 'assets/tom2+.png',
    description: 'Корея',
  ),
  Book(
    id: 5,
    title: 'Я стал отбросом графской семьи. Том 3 (Я стал графским ублюдком). Новелла',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2025,
    image: 'assets/tom3.png',
    description: 'Корея',
  ),
  Book(
    id: 6,
    title: 'Я стал отбросом графской семьи. Том 3 (Я стал графским ублюдком). Новелла + официальный мерч',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2025,
    image: 'assets/tom3+.png',
    description: 'Корея',
  ),
  Book(
    id: 7,
    title: 'Я стал отбросом графской семьи. Том 4 (Я стал графским ублюдком). Новелла',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2026,
    image: 'assets/tom4.png',
    description: 'Корея',
  ),
  Book(
    id: 8,
    title: 'Я стал отбросом графской семьи. Том 4 (Я стал графским ублюдком). Новелла + официальный мерч',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2026,
    image: 'assets/tom4+.png',
    description: 'Корея',
  ),
  Book(
    id: 9,
    title: 'Я стал отбросом графской семьи. Том 5 (Я стал графским ублюдком). Новелла',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2026,
    image: 'assets/tom5.png',
    description: 'Корея',
  ),
  Book(
    id: 10,
    title: 'Я стал отбросом графской семьи. Том 5 (Я стал графским ублюдком). Новелла + официальный мерч',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2026,
    image: 'assets/tom5+.png',
    description: 'Корея',
  ),
  Book(
    id: 11,
    title: 'Я стал отбросом графской семьи. Том 6 (Я стал графским ублюдком). Новелла',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2026,
    image: 'assets/tom6.png',
    description: 'Корея',
  ),
  Book(
    id: 12,
    title: 'Я стал отбросом графской семьи. Том 6 (Я стал графским ублюдком). Новелла + официальный мерч',
    author: 'Ю Рё Хан',
    genres: [
      BookGenre.fantasy,
      BookGenre.novella,
      BookGenre.noRomance,
      BookGenre.friendship,
    ],
    year: 2026,
    image: 'assets/tom6+.png',
    description: 'Корея',
  ),
];
