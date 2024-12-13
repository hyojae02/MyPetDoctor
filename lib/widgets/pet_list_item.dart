import 'package:flutter/material.dart';
import 'package:my_pet_doctor/screens/pet_status_screen.dart';
import '../models/pet.dart';
import '../screens/pet_detail_screen.dart';

class PetListItem extends StatelessWidget {
  final Pet pet;
  final VoidCallback onEdit;    // 수정 콜백 추가
  final VoidCallback onDelete;  // 삭제 콜백 추가

  const PetListItem({
    super.key,
    required this.pet,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: pet.imageUrl != null
              ? NetworkImage(pet.imageUrl!)
              : null,
          child: pet.imageUrl == null ? Text(pet.name[0]) : null,
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
                // 삭제 확인 다이얼로그 표시
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PetStatusScreen(pet: pet),
          ),
        ),
      ),
    );
  }
}