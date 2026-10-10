import 'package:flutter/material.dart';

import 'session.dart';
import 'utils/format.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Session session;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = categoryColor(context, session.category);
    final places = session.places;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(session.category.icon, color: color),
                  ),
                  if (session.isFull)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: _Badge(
                        text: 'FULL',
                        color: scheme.error,
                        textColor: scheme.onError,
                      ),
                    )
                  else if (places.free <= 5)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: _Badge(
                        text: '${places.free} left',
                        color: scheme.tertiary,
                        textColor: scheme.onTertiary,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDateTime(session.scheduledAt)} · ${session.venue}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  session.favourite ? Icons.favorite : Icons.favorite_border,
                ),
                color: session.favourite ? scheme.error : null,
                onPressed: onToggleFavourite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
    required this.textColor,
  });

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: textColor),
      ),
    );
  }
}
