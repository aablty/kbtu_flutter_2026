import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchCard extends StatefulWidget {
  const StopwatchCard({super.key});

  @override
  State<StopwatchCard> createState() => _StopwatchCardState();
}

class _StopwatchCardState extends State<StopwatchCard> {
  int _seconds = 0;
  Timer? _timer;

  String _formatTime(int seconds) {
    String mm = (seconds ~/ 60).toString().padLeft(2, '0');
    String ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void _startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _seconds++),
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _timer = null);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _seconds = 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        _formatTime(_seconds),
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 32,
        children: [
          OutlinedButton(
            onPressed: _seconds == 0 ? null : _resetTimer,
            child: const Text('Reset'),
          ),
          FilledButton(
            onPressed: _timer == null ? _startTimer : _stopTimer,
            child: _timer == null ? const Text('Start') : const Text('Stop'),
          ),
        ],
      ),
    ],
  );
}
