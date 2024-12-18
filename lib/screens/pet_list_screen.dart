import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../widgets/pet_list_item.dart';
import '../services/database_helper.dart';
import 'pet_profile_form.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({Key? key}) : super(key: key);

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  final GlobalKey<_PetListState> _petListKey = GlobalKey<_PetListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PetProfileForm()),
              );
              if (result == true) {
                _petListKey.currentState?.refreshPets(); // PetList 새로고침
              }
            },
          ),
        ],
      ),
      body: PetList(key: _petListKey),
      backgroundColor: Colors.white,
    );
  }
}

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
    refreshPets();
  }

  void refreshPets() {  // _refreshPets를 refreshPets로 변경
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
              'Add Your Pet!',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: pets.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: PetListItem(
                key: Key(pets[index].id),
                pet: pets[index],
                onEdit: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PetProfileForm(pet: pets[index]),
                    ),
                  );
                  if (result == true) {
                    refreshPets();  // _refreshPets를 refreshPets로 변경
                  }
                },
                onDelete: () async {
                  await DatabaseHelper.instance.deletePet(pets[index].id);
                  refreshPets();  // _refreshPets를 refreshPets로 변경
                },
              ),
            );
          },
        );
      },
    );
  }
}