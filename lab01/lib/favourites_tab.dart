import 'package:flutter/material.dart';

import 'empty_state.dart';
import 'session.dart';
import 'session_card.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<Session> onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final favourites = sessions.where((session) => session.favourite).toList();

    if (favourites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        message:
            'No favourites yet. Tap the heart on a confession to save it here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favourites.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final session = favourites[index];
        return SessionCard(
          session: session,
          onTap: () => onOpen(session),
          onToggleFavourite: () => onToggleFavourite(session),
        );
      },
    );
  }
}
