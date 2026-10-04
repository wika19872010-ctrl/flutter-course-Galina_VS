import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 219, 123, 99),
          title: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsetsGeometry.fromLTRB(16, 20, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Необычные цветы мира',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      color: Color(0xFF1A1A1A),
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    'Каталог',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 241, 184, 170),
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Container(
                        width: double.infinity,
                        height: 235,
                        padding: EdgeInsetsGeometry.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 237, 150, 129),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(width: 1 / 2),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: Container(
                                width: 125,
                                height: 183,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/loza.png',
                                      width: 125,
                                      height: 183,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 5,
                                      bottom: 5,
                                      child: Text(
                                        'Н',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.fromLTRB(
                                10,
                                40,
                                10,
                                10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Нефритовая Лоза',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text('(Strongylodon Macrobotrys)'),
                                  Wrap(
                                    spacing: 2,
                                    runSpacing: 5,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Text('Филиппины'),
                                      ),

                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Text('Редкий'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(child: SizedBox(height: 10)),
                      Container(
                        width: double.infinity,
                        height: 235,
                        padding: EdgeInsetsGeometry.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 237, 150, 129),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(width: 1 / 2),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: Container(
                                width: 125,
                                height: 183,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/passiflora.png',
                                      width: 125,
                                      height: 183,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 5,
                                      bottom: 5,
                                      child: Text(
                                        'П',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              Icons.favorite,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                            Icon(
                                              Icons.favorite,
                                              color: Colors.white,
                                              size: 26,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.fromLTRB(
                                10,
                                40,
                                10,
                                10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Пассифлора',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text('(Passiflora incarnata)'),
                                  Wrap(
                                    spacing: 2,
                                    runSpacing: 5,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Text('Индия'),
                                      ),

                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Text('Япония'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(child: SizedBox(height: 10)),
                      Container(
                        width: double.infinity,
                        height: 235,
                        padding: EdgeInsetsGeometry.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 237, 150, 129),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(width: 1 / 2),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: Container(
                                width: 125,
                                height: 183,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/yutan.png',
                                      width: 125,
                                      height: 183,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 5,
                                      bottom: 5,
                                      child: Text(
                                        'Ю',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsGeometry.fromLTRB(
                                  10,
                                  40,
                                  10,
                                  10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ютан Полуо',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      '(Неопределенное Научное Имя)',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Wrap(
                                      spacing: 2,
                                      runSpacing: 5,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text('Россия'),
                                        ),

                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text('Азия'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(child: SizedBox(height: 10)),
                      Container(
                        width: double.infinity,
                        height: 235,
                        padding: EdgeInsetsGeometry.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 237, 150, 129),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(width: 1 / 2),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: Container(
                                width: 125,
                                height: 183,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/tacca.png',
                                      width: 125,
                                      height: 183,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 5,
                                      bottom: 5,
                                      child: Text(
                                        'Ц',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              Icons.favorite,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                            Icon(
                                              Icons.favorite,
                                              color: Colors.white,
                                              size: 26,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsGeometry.fromLTRB(
                                  10,
                                  40,
                                  10,
                                  10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Цветок черной летучей мыши',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text('(Tacca Chantrieri)'),
                                    Wrap(
                                      spacing: 2,
                                      runSpacing: 5,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text('Юго-Восточная Азия'),
                                        ),

                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text('Россия'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(child: SizedBox(height: 10)),
                      Container(
                        width: double.infinity,
                        height: 235,
                        padding: EdgeInsetsGeometry.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 237, 150, 129),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(width: 1 / 2),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: Container(
                                width: 125,
                                height: 183,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/Lotus berthelotii.png',
                                      width: 125,
                                      height: 183,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 5,
                                      bottom: 5,
                                      child: Text(
                                        'К',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsGeometry.fromLTRB(
                                  10,
                                  40,
                                  10,
                                  10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Клюв попугая',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text('(Lotus berthelotii)'),
                                    Wrap(
                                      spacing: 2,
                                      runSpacing: 5,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text('Канарские острова'),
                                        ),

                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text(
                                            'Коралловые драгоценные камни',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(child: SizedBox(height: 10)),
                      Container(
                        width: double.infinity,
                        height: 235,
                        padding: EdgeInsetsGeometry.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 237, 150, 129),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(width: 1 / 2),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: Container(
                                width: 125,
                                height: 183,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/Lithops Comptonii.png',
                                      width: 125,
                                      height: 183,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 5,
                                      bottom: 5,
                                      child: Text(
                                        'Л',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              Icons.favorite,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                            Icon(
                                              Icons.favorite,
                                              color: Colors.white,
                                              size: 26,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsGeometry.fromLTRB(
                                  10,
                                  40,
                                  10,
                                  10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Литопс Вебери',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text('(Lithops Comptonii)'),
                                    Wrap(
                                      spacing: 2,
                                      runSpacing: 5,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text('Южная Африка'),
                                        ),

                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text('Живые Камни'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(child: SizedBox(height: 10)),
                      Container(
                        width: double.infinity,
                        height: 235,
                        padding: EdgeInsetsGeometry.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 237, 150, 129),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(width: 1 / 2),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: Container(
                                width: 125,
                                height: 183,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/Victoria cruziana.png',
                                      width: 125,
                                      height: 183,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 5,
                                      bottom: 5,
                                      child: Text(
                                        'Л',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsGeometry.fromLTRB(
                                  10,
                                  40,
                                  10,
                                  10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Гигантская водяная лилия',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      '(Чудовище из глубин)',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Wrap(
                                      spacing: 2,
                                      runSpacing: 5,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text('Пантанал'),
                                        ),

                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text('Бразилия'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(child: SizedBox(height: 10)),
                      Container(
                        width: double.infinity,
                        height: 235,
                        padding: EdgeInsetsGeometry.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 237, 150, 129),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(width: 1 / 2),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: Container(
                                width: 125,
                                height: 183,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/Antirrhinum majus.png',
                                      width: 125,
                                      height: 183,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      left: 5,
                                      bottom: 5,
                                      child: Text(
                                        'С',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            241,
                                            184,
                                            170,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              Icons.favorite,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                            Icon(
                                              Icons.favorite,
                                              color: Colors.white,
                                              size: 26,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsGeometry.fromLTRB(
                                  10,
                                  40,
                                  10,
                                  10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Скорлупа дракона',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text('(Antirrhinum majus)'),
                                    Wrap(
                                      spacing: 2,
                                      runSpacing: 5,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text(
                                            'Западное Средиземноморье',
                                          ),
                                        ),

                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              241,
                                              184,
                                              170,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text('Россия'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(child: SizedBox(height: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
