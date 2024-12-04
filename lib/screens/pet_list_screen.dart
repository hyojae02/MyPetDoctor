import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../widgets/pet_list_item.dart';
import '../services/database_helper.dart';  // DatabaseHelper import 추가
import 'pet_profile_form.dart';

// StatelessWidget에서 StatefulWidget으로 변경
class PetListScreen extends StatefulWidget {
  const PetListScreen({Key? key}) : super(key: key);

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 반려동물'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // 새 반려동물 추가 후 화면 갱신을 위해 await 추가
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PetProfileForm()),
              );
              setState(() {}); // 화면 갱신
            },
          ),
        ],
      ),
      body: const PetList(),
    );
  }
}

// StatelessWidget에서 StatefulWidget으로 변경
class PetList extends StatefulWidget {
  const PetList({Key? key}) : super(key: key);

  @override
  State<PetList> createState() => _PetListState();
}

class _PetListState extends State<PetList> {
  late Future<List<Pet>> _petsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPets();
  }

  void _refreshPets() {
    setState(() {
      _petsFuture = DatabaseHelper.instance.getAllPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pet>>(
      future: _petsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final pets = snapshot.data ?? [];

        if (pets.isEmpty) {
          return const Center(
            child: Text(
              '반려동물을 추가해주세요!',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: pets.length,
          itemBuilder: (context, index) {
            return PetListItem(
              key: Key(pets[index].id),
              pet: pets[index],
              onEdit: () async {
                // 반려동물 정보 수정 후 화면 갱신
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PetProfileForm(pet: pets[index]),
                  ),
                );
                _refreshPets();
              },
              onDelete: () async {
                // 반려동물 삭제 기능 추가
                await DatabaseHelper.instance.deletePet(pets[index].id);
                _refreshPets();
              },
            );
          },
        );
      },
    );
  }
}