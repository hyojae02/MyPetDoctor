import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/pet.dart';
import 'pet_map_screen.dart';
import 'pet_chatbot_screen.dart';
import 'pet_water_screen.dart';
import 'pet_food_screen.dart';
import 'pet_walk_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetStatusScreen extends StatefulWidget {
  final Pet pet;

  const PetStatusScreen({super.key, required this.pet});

  @override
  State<PetStatusScreen> createState() => _PetStatusScreenState();
}

class _PetStatusScreenState extends State<PetStatusScreen> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('yyyy. MM. dd');
  bool _isWaterComplete = false;
  bool _isFoodComplete = false;
  bool _isWalkComplete = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateFormat.format(DateTime.now());

    // Check Water status
    final isWaterComplete = prefs.getBool('isWaterComplete_${widget.pet.id}_$today') ?? false;

    // Check Food status
    final feedCount = prefs.getInt('feedCount_${widget.pet.id}') ?? 0;
    final lastFeedDate = prefs.getString('lastFeedDate_${widget.pet.id}');
    final isFoodComplete = feedCount >= 3 && lastFeedDate == today;

    // Check Walk status
    final walkSeconds = prefs.getInt('walkSeconds_${widget.pet.id}_$today') ?? 0;
    double recommendedWalkTime = 0;
    if (widget.pet.weight <= 7) {
      recommendedWalkTime = 0.1 * 60; // 소형견 50분
    } else if (widget.pet.weight <= 15) {
      recommendedWalkTime = 60 * 60; // 중형견 60분
    } else {
      recommendedWalkTime = 120 * 60; // 대형견 120분
    }
    final isWalkComplete = walkSeconds >= recommendedWalkTime;

    setState(() {
      _isWaterComplete = isWaterComplete;
      _isFoodComplete = isFoodComplete;
      _isWalkComplete = isWalkComplete;
    });

    // 모든 활동이 완료되었을 때 팝업 메시지 표시
    if (_isWaterComplete && _isFoodComplete && _isWalkComplete) {
      // 팝업이 이미 표시되어 있지 않은 경우에만 표시
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.celebration,
                          color: Colors.green[700],
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Congratulations! 🎉',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All daily activities completed!',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You\'re taking great care of ${widget.pet.name}!',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayDate = _displayFormat.format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple[100],
              backgroundImage: widget.pet.imageUrl != null && widget.pet.imageUrl!.isNotEmpty
                  ? FileImage(File(widget.pet.imageUrl!))
                  : null,
              child: (widget.pet.imageUrl == null || widget.pet.imageUrl!.isEmpty)
                  ? Icon(Icons.pets, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(widget.pet.name),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Today is ${displayDate}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildHospitalCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildChatCard()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStandardCard('Water', 'Please achieve recommended daily water intake', Icons.water_drop, Colors.blue[300]!),
                    const SizedBox(height: 16),
                    _buildStandardCard('Feed', 'Please achieve recommended daily feed intake', Icons.food_bank, Colors.orange[300]!),
                    const SizedBox(height: 16),
                    _buildStandardCard('Walk', 'Please achieve recommended daily walk', Icons.pets, Colors.brown[300]!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard(String title, String description, IconData icon, Color iconColor) {
    // 완료 상태에 따라 카드 색상 변경
    Color cardColor = Colors.white.withOpacity(0.9);
    Color currentIconColor = iconColor;

    if ((title == 'Water' && _isWaterComplete) ||
        (title == 'Feed' && _isFoodComplete) ||
        (title == 'Walk' && _isWalkComplete)) {
      cardColor = Colors.green[50]!;
      currentIconColor = Colors.green;
    }

    return Card(
      color: cardColor,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () async {
          if (title == 'Water') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PetWaterScreen(pet: widget.pet),
              ),
            );
            _checkStatus();
          } else if (title == 'Feed') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PetFoodScreen(pet: widget.pet),
              ),
            );
            _checkStatus();
          } else if (title == 'Walk') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PetWalkScreen(pet: widget.pet),
              ),
            );
            _checkStatus();
          }
        },
        child: Container(
          width: double.infinity,
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                icon,
                size: 30,
                color: currentIconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalCard() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PetMapScreen(),
          ),
        ),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pet Hospital',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Icon(Icons.local_hospital, size: 40, color: Colors.red[300]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatCard() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PetChatbotScreen(),
          ),
        ),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pet Chat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Icon(Icons.messenger, size: 40, color: Colors.purple[300]),
            ],
          ),
        ),
      ),
    );
  }
}