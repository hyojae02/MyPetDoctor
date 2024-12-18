import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';

class PetFoodScreen extends StatefulWidget {
  final Pet pet;

  const PetFoodScreen({Key? key, required this.pet}) : super(key: key);

  @override
  _PetFoodScreenState createState() => _PetFoodScreenState();
}

class _PetFoodScreenState extends State<PetFoodScreen> {
  int _feedCount = 0;
  late String _today;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('yyyy.MM.dd');

  bool _isButton1Clicked = false;
  bool _isButton2Clicked = false;
  bool _isButton3Clicked = false;

  @override
  void initState() {
    super.initState();
    _today = _dateFormat.format(DateTime.now());
    _loadFeedCount();
  }

  // Calculate RER (Resting Energy Requirement)
  double get _rer => widget.pet.weight * 30 + 70;

  // Calculate DER (Daily Energy Requirement)
  double get _der {
    final multiplier = widget.pet.isNeutered
        ? (widget.pet.age > 7 ? 1.2 : 1.6)
        : (widget.pet.age > 7 ? 1.4 : 1.8);
    return _rer * multiplier;
  }

  // Amount per feed (kcal)
  int get _amountPerFeed => (_der / 3).round();

  Future<void> _loadFeedCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('lastFeedDate_${widget.pet.id}');
    final savedCount = prefs.getInt('feedCount_${widget.pet.id}') ?? 0;

    setState(() {
      if (savedDate == _today) {
        _feedCount = savedCount;
        _isButton1Clicked = _feedCount > 0;
        _isButton2Clicked = _feedCount > 1;
        _isButton3Clicked = _feedCount > 2;
      } else {
        _feedCount = 0;
        _isButton1Clicked = false;
        _isButton2Clicked = false;
        _isButton3Clicked = false;
      }
    });
  }

  Future<void> _saveFeedCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('feedCount_${widget.pet.id}', _feedCount);
    await prefs.setString('lastFeedDate_${widget.pet.id}', _today);
  }

  void _onButtonPressed(int buttonNumber) async {
    if (_feedCount >= 3) return;

    setState(() {
      if (buttonNumber == 1 && !_isButton1Clicked) {
        _isButton1Clicked = true;
        _feedCount++;
      } else if (buttonNumber == 2 && !_isButton2Clicked) {
        _isButton2Clicked = true;
        _feedCount++;
      } else if (buttonNumber == 3 && !_isButton3Clicked) {
        _isButton3Clicked = true;
        _feedCount++;
      }
    });

    await _saveFeedCount();
  }

  String _getAgeStatus() {
    if (widget.pet.age > 7) return "Senior";
    if (widget.pet.age < 1) return "Puppy";
    return "Adult";
  }

  @override
  Widget build(BuildContext context) {
    final hasReachedLimit = _feedCount >= 3;
    final displayDate = _displayFormat.format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayDate,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 끝으로 배치
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_der.round()} kcal',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.pet.name} (${_getAgeStatus()}, ${widget.pet.isNeutered ? "Neutered" : "Not Neutered"})',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Weight: ${widget.pet.weight}kg',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Amount Per Feed: ${_amountPerFeed} kcal',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.food_bank_outlined, // Flutter 기본 아이콘
                      color: Colors.orange[700], // 아이콘 색상
                      size: 60, // 아이콘 크기
                    ),
                  ],
                ),
              ),
            ),


            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: _feedCount / 3,
              minHeight: 20,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                hasReachedLimit ? Colors.green : Colors.grey[400]!,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Current Feed Count: $_feedCount times',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 30),

            Center(
              child: Column(
                children: [
                  for (int i = 1; i <= 3; i++) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      onPressed: [
                        _isButton1Clicked,
                        _isButton2Clicked,
                        _isButton3Clicked
                      ][i - 1] ||
                          hasReachedLimit
                          ? null
                          : () => _onButtonPressed(i),
                      child: Text('$i${["st", "nd", "rd"][i - 1]} Feed'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            if (hasReachedLimit) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Daily feeding completed! 🎉',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            Card(
              elevation: 5,
              color: Colors.orangeAccent,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Feeding Tips',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Always store food in a fresh place\n'
                          '• Clean the food bowl daily\n'
                          '• After exercise or walks, wait for about 30 minutes before feeding',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
