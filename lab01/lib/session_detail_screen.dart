import 'dart:async';

import 'package:flutter/material.dart';

import 'empty_state.dart';
import 'profile.dart';
import 'routes.dart';
import 'session.dart';
import 'utils/format.dart';

class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({super.key, required this.args});

  final SessionDetailArgs args;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late Session _session = widget.args.session;
  late Countdown _countdown = _session.countdown;
  Timer? _timer;

  bool get _joined => _session.contains(widget.args.profile.name);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _countdown = _session.countdown);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _toggleJoin() async {
    final name = widget.args.profile.name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set your name in Profile to join.'),
          action: SnackBarAction(
            label: 'Go to profile',
            onPressed: widget.args.onSwitchToProfileTab,
          ),
        ),
      );
      return;
    }

    final joining = !_joined;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(joining ? 'Join this circle?' : 'Leave this circle?'),
        content: Text(
          joining
              ? 'You will show up in the attendee list for everyone to see.'
              : 'You will be removed from the attendee list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(joining ? 'Join' : 'Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final updatedAttendees = joining
        ? [..._session.attendees, name]
        : _session.attendees
              .where((a) => a.trim().toLowerCase() != name.toLowerCase())
              .toList();
    final updated = _session.copyWith(attendees: updatedAttendees);
    setState(() {
      _session = updated;
      _countdown = updated.countdown;
    });
    widget.args.onUpdate(updated);
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).pushNamed<Session>(
      Routes.form,
      arguments: SessionFormArgs(initial: _session),
    );
    if (updated == null || !mounted) return;
    setState(() {
      _session = updated;
      _countdown = updated.countdown;
    });
    widget.args.onUpdate(updated);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this confession?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.args.onDelete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final places = _session.places;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_session.category.label),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _edit();
                if (value == 'delete') _delete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'About'),
              Tab(text: 'Names (${_session.attendees.length})'),
            ],
          ),
        ),
        body: Column(
          children: [
            _Header(
              session: _session,
              countdown: _countdown,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                _session.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(session: _session),
                  _NamesTab(session: _session, profile: widget.args.profile),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: (_session.isFull && !_joined) ? null : _toggleJoin,
            child: Text(
              _joined ? 'Leave' : 'Join (${places.taken}/${_session.capacity})',
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.session,
    required this.countdown,
  });

  final Session session;
  final Countdown countdown;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/${session.category.name}.png',
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Chip(label: Text(_countdownLabel(countdown))),
        ),
      ],
    );
  }
}

String _countdownLabel(Countdown countdown) {
  return switch (countdown) {
    Upcoming(remaining: final remaining) =>
      'Starts in ${_formatDuration(remaining)}',
    Started(elapsed: final elapsed) =>
      'Started ${_formatDuration(elapsed)} ago',
    Ended() => 'Ended',
  };
}

String _formatDuration(Duration duration) {
  if (duration.inDays >= 1) return '${duration.inDays}d';
  if (duration.inHours >= 1) return '${duration.inHours}h';
  return '${duration.inMinutes}m';
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final places = session.places;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(formatDateTime(session.scheduledAt)),
        ),
        ListTile(
          leading: Icon(session.liveDemo ? Icons.link : Icons.place),
          title: Text(session.venue),
        ),
        ListTile(
          leading: const Icon(Icons.groups),
          title: Text(
            '${places.taken} / ${session.capacity} seats taken · ${places.free} free',
          ),
        ),
        if (session.description != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(session.description!),
          ),
        ],
      ],
    );
  }
}

class _NamesTab extends StatelessWidget {
  const _NamesTab({required this.session, required this.profile});

  final Session session;
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final attendees = session.attendees;
    if (attendees.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'Nobody has joined this circle yet.',
      );
    }

    final name = profile.name.trim().toLowerCase();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attendees.length,
      itemBuilder: (context, index) {
        final attendee = attendees[index];
        final isYou = name.isNotEmpty && attendee.trim().toLowerCase() == name;
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(attendee),
          trailing: isYou ? const Icon(Icons.star) : null,
          selected: isYou,
        );
      },
    );
  }
}
