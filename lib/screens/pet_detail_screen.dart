import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pet.imageUrl != null)
              Center(
                child: Image.network(
                  pet.imageUrl!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: '기본 정보',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이름: ${pet.name}'),
                  Text('나이: ${pet.age}세'),
                  Text('품종: ${pet.breed}'),
                  Text('성별: ${pet.gender}'),
                  Text('중성화 여부: ${pet.isNeutered ? "예" : "아니오"}'),
                  Text('체중: ${pet.weight}kg'),
                ],
              ),
            ),
            if (pet.allergies != null && pet.allergies!.isNotEmpty)
              _buildInfoCard(
                title: '알레르기',
                content: Text(pet.allergies!),
              ),
            if (pet.specialNotes != null && pet.specialNotes!.isNotEmpty)
              _buildInfoCard(
                title: '특이사항',
                content: Text(pet.specialNotes!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Widget content,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }
}