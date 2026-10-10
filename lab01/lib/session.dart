import 'package:flutter/material.dart';

enum BugType {
  overflow(label: 'Overflow', icon: Icons.unfold_more),
  nullSafety(label: 'Null Safety', icon: Icons.block),
  asyncHell(label: 'Async Hell', icon: Icons.hourglass_bottom),
  stateManagement(label: 'State Management', icon: Icons.refresh),
  buildError(label: 'Build Error', icon: Icons.error_outline),
  memoryLeak(label: 'Memory Leak', icon: Icons.water_drop);

  const BugType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

Color categoryColor(BuildContext context, BugType category) {
  final scheme = Theme.of(context).colorScheme;
  return switch (category) {
    BugType.overflow => scheme.error,
    BugType.nullSafety => scheme.primary,
    BugType.asyncHell => scheme.tertiary,
    BugType.stateManagement => scheme.secondary,
    BugType.buildError => scheme.errorContainer,
    BugType.memoryLeak => scheme.tertiaryContainer,
  };
}

sealed class Countdown {
  const Countdown();
}

class Upcoming extends Countdown {
  const Upcoming(this.remaining);
  final Duration remaining;
}

class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

class Ended extends Countdown {
  const Ended();
}

const _stillRunningWindow = Duration(hours: 1);

Countdown countdownFor(DateTime scheduledAt, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = scheduledAt.difference(current);
  if (!diff.isNegative) return Upcoming(diff);
  final elapsed = -diff;
  if (elapsed <= _stillRunningWindow) return Started(elapsed);
  return const Ended();
}

class Session {
  const Session({
    required this.title,
    required this.category,
    required this.scheduledAt,
    required this.capacity,
    List<String> attendees = const [],
    required this.liveDemo,
    required this.venue,
    this.description,
    this.favourite = false,
  })
  // ignore: prefer_initializing_formals
  : _attendees = attendees;

  final String title;
  final BugType category;
  final DateTime scheduledAt;
  final int capacity;
  final List<String> _attendees;
  final bool liveDemo;
  final String venue;
  final String? description;
  final bool favourite;

  List<String> get attendees => List.unmodifiable(_attendees);

  factory Session.empty() => Session(
    title: '',
    category: BugType.overflow,
    scheduledAt: DateTime.now().add(const Duration(days: 1)),
    capacity: 10,
    liveDemo: false,
    venue: '',
  );

  ({int taken, int free}) get places =>
      (taken: _attendees.length, free: capacity - _attendees.length);

  bool get isFull => places.free <= 0;

  bool get isPast => scheduledAt.isBefore(DateTime.now());

  Countdown get countdown => countdownFor(scheduledAt);

  bool contains(String name) {
    final needle = name.trim().toLowerCase();
    if (needle.isEmpty) return false;
    return _attendees.any((a) => a.trim().toLowerCase() == needle);
  }

  Session copyWith({
    String? title,
    BugType? category,
    DateTime? scheduledAt,
    int? capacity,
    List<String>? attendees,
    bool? liveDemo,
    String? venue,
    String? description,
    bool? favourite,
  }) => Session(
    title: title ?? this.title,
    category: category ?? this.category,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    capacity: capacity ?? this.capacity,
    attendees: attendees ?? _attendees,
    liveDemo: liveDemo ?? this.liveDemo,
    venue: venue ?? this.venue,
    description: description ?? this.description,
    favourite: favourite ?? this.favourite,
  );
}

List<Session> buildSeedSessions() {
  final now = DateTime.now();
  DateTime inDays(int days) => DateTime(now.year, now.month, now.day, 18).add(
    Duration(days: days),
  );

  return [
    Session(
      title:
          'Null Safety Said I Was Safe, But My App Violently Disagreed.',
      category: BugType.nullSafety,
      scheduledAt: inDays(3),
      capacity: 20,
      attendees: List.generate(8, (i) => 'Attendee ${i + 1}'),
      liveDemo: false,
      venue: 'Room 204',
      description:
          'We all swore the compiler had our backs. It did not. Bring tissues.',
    ),
    Session(
      title: 'RenderFlex Overflowed by 42 Pixels: A Memoir',
      category: BugType.overflow,
      scheduledAt: inDays(5),
      capacity: 15,
      attendees: List.generate(15, (i) => 'Attendee ${i + 1}'),
      liveDemo: false,
      venue: 'Room 110',
      description: 'Yellow and black stripes are not a design choice.',
    ),
    Session(
      title: 'The Night I Forgot `mounted`',
      category: BugType.asyncHell,
      scheduledAt: inDays(-4),
      capacity: 25,
      attendees: List.generate(19, (i) => 'Attendee ${i + 1}'),
      liveDemo: false,
      venue: 'Room 301',
      description: 'setState() was called after the widget was gone.',
    ),
    Session(
      title: 'Live: Watching My App Rebuild the Entire Tree',
      category: BugType.stateManagement,
      scheduledAt: inDays(1),
      capacity: 30,
      attendees: List.generate(11, (i) => 'Attendee ${i + 1}'),
      liveDemo: true,
      venue: 'https://github.com/widget-anonymous/rebuild-everything',
      description: 'We will rebuild the whole tree together, live.',
    ),
    Session(
      title: 'Confessions of a Man Who `catch`es Everything',
      category: BugType.buildError,
      scheduledAt: inDays(7),
      capacity: 10,
      attendees: List.generate(4, (i) => 'Attendee ${i + 1}'),
      liveDemo: false,
      venue: 'Room 110',
    ),
    Session(
      title: 'My Memory Leak Has a Name and I Call Him Steve',
      category: BugType.memoryLeak,
      scheduledAt: inDays(2),
      capacity: 12,
      attendees: List.generate(12, (i) => 'Attendee ${i + 1}'),
      liveDemo: false,
      venue: 'Room 204',
      favourite: true,
      description: 'Steve has been running since the first beta.',
    ),
    Session(
      title: "I Still Don't Know What a BuildContext Is",
      category: BugType.nullSafety,
      scheduledAt: inDays(10),
      capacity: 18,
      attendees: List.generate(2, (i) => 'Attendee ${i + 1}'),
      liveDemo: false,
      venue: 'Room 301',
    ),
    Session(
      title: 'Async Gap Support Circle: Week 12',
      category: BugType.asyncHell,
      scheduledAt: inDays(-10),
      capacity: 20,
      attendees: List.generate(6, (i) => 'Attendee ${i + 1}'),
      liveDemo: false,
      venue: 'Room 204',
    ),
    Session(
      title: 'Yellow and Black Stripes, Forever',
      category: BugType.overflow,
      scheduledAt: inDays(6),
      capacity: 14,
      attendees: List.generate(10, (i) => 'Attendee ${i + 1}'),
      liveDemo: false,
      venue: 'Room 110',
      favourite: true,
    ),
    Session(
      title: 'setState() After Dispose: A Eulogy',
      category: BugType.stateManagement,
      scheduledAt: inDays(4),
      capacity: 16,
      attendees: List.generate(1, (i) => 'Attendee ${i + 1}'),
      liveDemo: false,
      venue: 'Room 301',
    ),
    Session(
      title: 'The Dropdown That Judged My Life Choices',
      category: BugType.buildError,
      scheduledAt: inDays(8),
      capacity: 22,
      attendees: List.generate(17, (i) => 'Attendee ${i + 1}'),
      liveDemo: false,
      venue: 'Room 110',
    ),
    Session(
      title: 'Leak Week: Day 3 of Profiling My Own Regret',
      category: BugType.memoryLeak,
      scheduledAt: inDays(-1),
      capacity: 10,
      attendees: List.generate(3, (i) => 'Attendee ${i + 1}'),
      liveDemo: false,
      venue: 'Room 204',
    ),
  ];
}
