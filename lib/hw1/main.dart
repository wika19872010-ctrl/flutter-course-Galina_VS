/// ЛР 1 — шесть независимых виджетов.
//
// Как сдавать: скопируйте этот файл целиком себе в main.dart, допишите
// шесть функций ниже вместо TODO, запустите — все шесть элементов должны
// появиться на экране. Пришлите готовый файл на проверку.
//
// Основной виджет трогать не нужно. Редактируйте там, где написано TODO.

import 'package:flutter/material.dart';

void main() {
  runApp(const Lab1App());
}

class Lab1App extends StatelessWidget {
  const Lab1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ЛР 1')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task 1:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task1(),
              const SizedBox(height: 4),
              Divider(),
              const SizedBox(height: 4),
              Text(
                'Task 2:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task2(),

              const SizedBox(height: 4),
              Divider(),
              const SizedBox(height: 4),
              Text(
                'Task 3:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task3(),
              const SizedBox(height: 4),
              Divider(),
              const SizedBox(height: 4),
              Text(
                'Task 4:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task4(),
              const SizedBox(height: 4),
              Divider(),
              const SizedBox(height: 4),
              Text(
                'Task 5:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task5(),
              const SizedBox(height: 4),
              Divider(),
              const SizedBox(height: 4),
              Text(
                'Task 6:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task6(),
            ],
          ),
        ),
      ),
    );
  }
}

// 1. Заголовок — Text, крупный жирный текст чёрного цвета, обрезается в одну строку, если не помещается.
Widget task1() {
  return const Text(
    'Заголовок — Text, крупный жирный текст чёрного цвета, обрезается в одну строку, если не помещается',
    style: TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

// Также реализуйте подложку из тёмно-серого контейнера с закруглениями, чтобы текст было видно
Widget task2() {
  // TODO: замените Placeholder на ...
  return Container(
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 45, 44, 44),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      'Подпись — Text, небольшой нежирный курсивный текст белого цвета, обрезается в две строки',
      style: TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontStyle: FontStyle.italic,
      ),
      maxLines: 2,
    ),
  );
}

// 3. Иконка — любая Icon на ваш вкус,
// с применением цвета и размером.
Widget task3() {
  // TODO: замените Placeholder на...
  return const Icon(
    Icons.flutter_dash,
    color: Color.fromARGB(255, 19, 149, 17),
    size: 50,
  );
}

// 4. Кнопка с иконкой избранного — большая иконка сердца красного цвета без фона.
// При нажатии пишет в консоль "Вы добавили в избранное"
Widget task4() {
  // TODO: замените Placeholder на ...
  return IconButton(
    onPressed: () {
      print('Вы добавили в избранное');
    },
    icon: const Icon(Icons.favorite),
    color: Colors.red,
    iconSize: 60,
  );
}

// 5. Кнопка «Подробнее» — кнопка с текстом и обводкой, при нажатии пишет в консоль "Узнать детали"
Widget task5() {
  // TODO: замените Placeholder на ...
  return ElevatedButton(
    onPressed: () {
      print('Узнать детали');
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 177, 175, 175),
      elevation: 5,
      side: BorderSide(color: Colors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    child: const Text(
      'Подробнее',
      style: TextStyle(color: Colors.blueAccent, fontSize: 24),
    ),
  );
}

// 6. Изображение в стиле Polaroid—  выберите любое из каталога по ссылке
// https://picsum.photos/ (необходим vpn), либо используйте https://docs.flutter.dev/assets/images/dash/dash-fainting.gif
// Добавьте чёрную обводку, а внутри белую рамку в стиле фотографии Polaroid (https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAeKRHzUEOMCX836O6p8R5-XBkrSlf8C4go4C7f1q8ClnmlFaV9emSrUFL&s=10)
// Для реализации используйте Container
Widget task6() {
  // TODO: замените Placeholder на Container()
  return Container(
    width: 100,
    height: 150,
    padding: const EdgeInsets.fromLTRB(5, 5, 5, 30),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(width: 1, color: Colors.black),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4)),
      ],
    ),
    child: Image.network(
      'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif',
      width: 88,
      fit: BoxFit.fill,
    ),
  );
}
