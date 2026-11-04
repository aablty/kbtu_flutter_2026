import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _mode = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Countdown')),
    body: Column(
      children: [
        const SizedBox(height: 16),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('StreamBuilder')),
            ButtonSegment(value: 1, label: Text('Subscription')),
          ],
          selected: {_mode},
          onSelectionChanged: (selection) {
            setState(() => _mode = selection.first);
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: IndexedStack(
            index: _mode,
            children: const [
              _StreamBuilderCountdown(),
              _SubscriptionCountdown(),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StreamBuilderCountdown extends StatefulWidget {
  const _StreamBuilderCountdown();

  @override
  State<_StreamBuilderCountdown> createState() =>
      _StreamBuilderCountdownState();
}

class _StreamBuilderCountdownState extends State<_StreamBuilderCountdown> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
    stream: _stream,
    builder: (context, snapshot) => Center(
      child: Text(
        '${snapshot.data ?? 10}',
        style: Theme.of(context).textTheme.displayLarge,
      ),
    ),
  );
}

class _SubscriptionCountdown extends StatefulWidget {
  const _SubscriptionCountdown();

  @override
  State<_SubscriptionCountdown> createState() => _SubscriptionCountdownState();
}

class _SubscriptionCountdownState extends State<_SubscriptionCountdown> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((value) {
      if (!mounted) return;
      setState(() => _left = value);
    });
  }

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Text('$_left', style: Theme.of(context).textTheme.displayLarge),
  );
}
