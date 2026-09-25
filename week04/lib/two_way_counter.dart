import 'package:flutter/material.dart';

class TwoWayCounter extends StatefulWidget {
  const TwoWayCounter({super.key});

  @override
  State<TwoWayCounter> createState() => _TwoWayCounterState();
}

class _TwoWayCounterState extends State<TwoWayCounter> {
  int _counter = 0;
  bool _saving = false;

  void _increment() => setState(() => _counter++);

  void _decrement() => setState(() => _counter--);

  void _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        spacing: 32,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: _counter <= 0 ? null : _decrement,
            child: const Text('-'),
          ),
          Text('$_counter', style: const TextStyle(fontSize: 24)),
          FilledButton(onPressed: _increment, child: const Text('+')),
        ],
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        style: const ButtonStyle(),
        child: _saving ? const CircularProgressIndicator() : const Text('Save'),
      ),
    ],
  );
}
