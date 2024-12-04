// main.dart

import 'package:flutter/material.dart';
import 'screens/pet_list_screen.dart';

void main() {
  runApp(const MyPetApp());
}

class MyPetApp extends StatelessWidget {
  const MyPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '반려동물 관리',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,  // Material 3 디자인 사용
      ),
      home: const PetListScreen(),  // 시작 화면을 PetListScreen으로 설정
    );
  }
}