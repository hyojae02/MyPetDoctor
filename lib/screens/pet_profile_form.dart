import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class PetProfileForm extends StatefulWidget {
  final Pet? pet;

  const PetProfileForm({Key? key, this.pet}) : super(key: key);

  @override
  _PetProfileFormState createState() => _PetProfileFormState();
}

class _PetProfileFormState extends State<PetProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _allergiesController;
  late TextEditingController _specialNotesController;
  String _selectedGender = '남';
  bool _isNeutered = false;

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    _nameController = TextEditingController(text: pet?.name);
    _ageController = TextEditingController(text: pet?.age.toString());
    _breedController = TextEditingController(text: pet?.breed);
    _weightController = TextEditingController(text: pet?.weight.toString());
    _allergiesController = TextEditingController(text: pet?.allergies);
    _specialNotesController = TextEditingController(text: pet?.specialNotes);
    if (pet != null) {
      _selectedGender = pet.gender;
      _isNeutered = pet.isNeutered;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet == null ? '새로운 반려동물 등록' : '프로필 수정'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: '나이'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '나이를 입력해주세요';
                  }
                  if (int.tryParse(value) == null) {
                    return '올바른 숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(labelText: '품종'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '품종을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(labelText: '성별'),
                items: ['남', '여'].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('중성화 여부'),
                value: _isNeutered,
                onChanged: (value) {
                  setState(() {
                    _isNeutered = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: '체중 (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '체중을 입력해주세요';
                  }
                  if (double.tryParse(value) == null) {
                    return '올바른 숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _allergiesController,
                decoration: InputDecoration(labelText: '알레르기'),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _specialNotesController,
                decoration: InputDecoration(labelText: '특이사항'),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('저장하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: Implement image picking functionality
        },
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
          ),
          child: Icon(
            Icons.camera_alt,
            size: 40,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final pet = Pet(
          id: widget.pet?.id ?? const Uuid().v4(),
          name: _nameController.text,
          age: int.parse(_ageController.text),
          breed: _breedController.text,
          gender: _selectedGender,
          isNeutered: _isNeutered,
          weight: double.parse(_weightController.text),
          allergies: _allergiesController.text,
          specialNotes: _specialNotesController.text,
          imageUrl: widget.pet?.imageUrl,
        );

        if (widget.pet == null) {
          await DatabaseHelper.instance.insertPet(pet);
        } else {
          await DatabaseHelper.instance.updatePet(pet);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('저장되었습니다')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _specialNotesController.dispose();
    super.dispose();
  }
}