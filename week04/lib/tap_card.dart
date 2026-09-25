import 'package:flutter/material.dart';

class TapCard extends StatefulWidget {
  const TapCard({super.key});

  @override
  State<TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<TapCard> {
  int _taps = 0;

  void _incrementTaps() => setState(() => _taps++);

  void _resetTaps() => setState(() => _taps = 0);

  Future<bool?> _showResetDialog(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reset the count?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Reset'),
        ),
      ],
    ),
  );

  void onTap() => _incrementTaps();

  void onLongPress() => _showResetDialog(context).then((reset) {
    if (reset ?? false) _resetTaps();
  });

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ListTile(
        title: const Text('Tap this card'),
        trailing: Text('$_taps'),
      ),
    ),
  );
}
