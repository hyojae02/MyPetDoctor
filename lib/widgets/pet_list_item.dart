import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../screens/pet_status_screen.dart';
import 'dart:io';

class PetListItem extends StatelessWidget {
  final Pet pet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PetListItem({
    super.key,
    required this.pet,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        tileColor: Colors.white,
        leading: CircleAvatar(
          backgroundColor: Colors.purple[100],
          backgroundImage: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
              ? FileImage(File(pet.imageUrl!))
              : null,
          child: (pet.imageUrl == null || pet.imageUrl!.isEmpty)
              ? const Icon(Icons.pets, color: Colors.white)
              : null,
        ),
        title: Text(pet.name),
        subtitle: Text('${pet.breed}, ${pet.age}세'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('반려동물 삭제'),
                    content: Text('${pet.name}을(를) 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetStatusScreen(pet: pet),
            ),
          );
          if (result == true) {
            onEdit(); // PetStatusScreen에서 수정이 있었다면 리스트 새로고침
          }
        },
      ),
    );
  }
}