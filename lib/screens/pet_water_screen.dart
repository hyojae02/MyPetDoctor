import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetWaterScreen extends StatefulWidget {
  final Pet pet;

  const PetWaterScreen({Key? key, required this.pet}) : super(key: key);

  @override
  _PetWaterScreenState createState() => _PetWaterScreenState();
}

class _PetWaterScreenState extends State<PetWaterScreen> {
  int _totalClicks = 0;
  late String _today;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayFormat = DateFormat('yyyy. MM. dd');

  bool _isButton1Clicked = false;
  bool _isButton2Clicked = false;
  bool _isButton3Clicked = false;

  @override
  void initState() {
    super.initState();
    _today = _dateFormat.format(DateTime.now());
    _loadWaterCount();
  }

  Future<void> _loadWaterCount() async {
    setState(() {
      _totalClicks = 0;
      _isButton1Clicked = false;
      _isButton2Clicked = false;
      _isButton3Clicked = false;
    });
  }

  double get _progress => _totalClicks / 3;

  // Recommended water intake per day (ml)
  int get _recommendedWaterIntake {
    return (widget.pet.weight * 45).round();
  }

  // Amount per drink (ml)
  int get _amountPerDrink {
    return (_recommendedWaterIntake / 3).round();
  }

  int get _waterIntake => (_totalClicks * _amountPerDrink);

  void _onButtonPressed(int buttonNumber) async {
    if (_totalClicks >= 3) return;

    setState(() {
      if (buttonNumber == 1 && !_isButton1Clicked) {
        _isButton1Clicked = true;
        _totalClicks++;
      } else if (buttonNumber == 2 && !_isButton2Clicked) {
        _isButton2Clicked = true;
        _totalClicks++;
      } else if (buttonNumber == 3 && !_isButton3Clicked) {
        _isButton3Clicked = true;
        _totalClicks++;
      }
    });

    // Water 완료 상태 저장
    if (_totalClicks >= 3) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isWaterComplete_${widget.pet.id}_$_today', true);
      await prefs.setString('lastWaterComplete_${widget.pet.id}_date', _today);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasReachedLimit = _totalClicks >= 3;
    String displayDate = _displayFormat.format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake Record'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Date
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

              // Daily Intake Info
              Card(
                elevation: 2,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_recommendedWaterIntake}ml',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '(${widget.pet.name}\'s weight: ${widget.pet.weight}kg)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Amount per Drink: ${_amountPerDrink}ml',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.water_drop_outlined, // Flutter water drop icon
                        color: Colors.blue,
                        size: 60, // Adjust size as needed
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Progress Bar
              LinearProgressIndicator(
                value: _progress,
                minHeight: 20,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  hasReachedLimit ? Colors.green : Colors.grey[400]!,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Current Water Intake: ${_waterIntake}ml',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),

              // Water Intake Buttons
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      onPressed: _isButton1Clicked || hasReachedLimit
                          ? null
                          : () => _onButtonPressed(1),
                      child: Text('1st Drink'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      onPressed: _isButton2Clicked || hasReachedLimit
                          ? null
                          : () => _onButtonPressed(2),
                      child: Text('2nd Drink'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      onPressed: _isButton3Clicked || hasReachedLimit
                          ? null
                          : () => _onButtonPressed(3),
                      child: Text('3rd Drink'),
                    ),
                  ],
                ),
              ),

              // Completion Message
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
                        'Daily water intake completed! 🎉',
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

              // Water Tips
              Card(
                elevation: 5,
                color: Colors.blueAccent,
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
                            'Water Tips',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                            '• Clean the water bowl daily\n'
                            '• Change water at least twice a day\n'
                            '• Place water bowls in multiple locations\n'
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}