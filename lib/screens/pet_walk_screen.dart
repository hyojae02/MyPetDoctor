import 'package:flutter/material.dart';
import 'dart:async';
import '../models/pet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PetWalkScreen extends StatefulWidget {
  final Pet pet;

  const PetWalkScreen({Key? key, required this.pet}) : super(key: key);

  @override
  State<PetWalkScreen> createState() => _PetWalkScreenState();
}

class _PetWalkScreenState extends State<PetWalkScreen> {
  bool _isTimerRunning = false;
  int _seconds = 0;
  Timer? _timer;

  double get _recommendedWalkTime {
    final weight = widget.pet.weight;

    // 소형견: ~7kg, 중형견: ~15kg, 대형견: 15kg~
    if (weight <= 7) {
      return 0.1; // 소형견 50분
    } else if (weight <= 15) {
      return 60; // 중형견 60분
    } else {
      return 120; // 대형견 1시간
    }
  }

  String get _timerText {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String get _dogSizeCategory {
    final weight = widget.pet.weight;
    if (weight <= 7) {
      return "Small";
    } else if (weight <= 15) {
      return "Medium";
    } else {
      return "Large";
    }
  }

  void _updateWalkTime() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setInt('walkSeconds_${widget.pet.id}_$today', _seconds);
  }

  void _startTimer() {
    if (_timer != null) return;

    setState(() {
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        _updateWalkTime(); // 매 초마다 걸은 시간 업데이트
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isTimerRunning = false;
    });
    _updateWalkTime(); // 일시정지 시에도 시간 저장
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isTimerRunning = false;
      _seconds = 0;
    });
    _updateWalkTime(); // 리셋 시에도 시간 저장
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommendedSeconds = _recommendedWalkTime * 60;
    final progress = _seconds / recommendedSeconds;
    final hasReachedGoal = _seconds >= recommendedSeconds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Walk Timer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                elevation: 2,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 끝으로 정렬
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                        children: [
                          Text(
                            '${_recommendedWalkTime} minutes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.pet.name} (${_dogSizeCategory} size)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Current weight: ${widget.pet.weight}kg',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Icon(
                        Icons.pets_outlined, // 반려동물 관련 아이콘
                        color: Colors.brown[400], // 아이콘 색상
                        size: 60, // 아이콘 크기
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        hasReachedGoal ? Colors.green : Colors.grey[400]!,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _timerText,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        '${(_seconds ~/ 60).toString()} minutes ${(_seconds % 60).toString()} seconds',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
              if (hasReachedGoal) ...[
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
                        'Great job! Walk goal achieved! 🎉',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isTimerRunning) ...[
                    ElevatedButton.icon(
                      onPressed: _startTimer,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: _pauseTimer,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ],
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.replay),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 5,
                color: Colors.brown[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Walk Tips',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• It\'s better to walk during the morning or evening.\n'
                            '• Reduce walk time and take frequent breaks in hot weather.\n'
                            '• Make sure to give water before and after the walk.\n'
                            '• If your dog shows signs of fatigue, return home immediately.',
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