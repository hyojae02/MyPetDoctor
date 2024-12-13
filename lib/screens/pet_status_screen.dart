import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetStatusScreen extends StatelessWidget {
  final Pet pet;

  const PetStatusScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: pet.imageUrl != null ? NetworkImage(pet.imageUrl!) : null,
              child: pet.imageUrl == null ? Text(pet.name[0]) : null,
            ),
            SizedBox(width: 8),
            Text(pet.name),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 물/사료 기록 카드들
            Row(
              children: [
                Expanded(child: _buildWaterCard()),
                SizedBox(width: 16),
                Expanded(child: _buildFoodCard()),
              ],
            ),

            SizedBox(height: 16),

            // 하단 카드 3개를 세로로 배치
            _buildStandardCard('물', '아이의 하루 물 권장량을 달성해주세요', Icons.water_drop),
            SizedBox(height: 16),
            _buildStandardCard('사료', '아이의 하루 사료 권장량을 달성해주세요', Icons.food_bank),
            SizedBox(height: 16),
            _buildStandardCard('산책', '아이의 하루 산책 권장량을 달성해주세요', Icons.pets),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard(String title, String description, IconData icon) {
    return Card(
      child: Container(
        width: double.infinity,
        height: 120,
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
            Icon(icon, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterCard() {
    return Card(
      child: Container(
        height: 120,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('근처 동물병원', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Icon(Icons.local_hospital, size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard() {
    return Card(
      child: Container(
        height: 120,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('건강 체크', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Icon(Icons.medical_services, size: 40),
          ],
        ),
      ),
    );
  }
}