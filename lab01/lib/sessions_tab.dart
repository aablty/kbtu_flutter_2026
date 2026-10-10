import 'package:flutter/material.dart';

import 'empty_state.dart';
import 'session.dart';
import 'session_card.dart';

class SessionsTab extends StatefulWidget {
  const SessionsTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<Session> onToggleFavourite;

  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<SessionsTab> {
  final _searchController = TextEditingController();
  BugType? _categoryFilter;
  bool _showPast = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.sessions.where((session) {
      if (_categoryFilter != null && session.category != _categoryFilter) {
        return false;
      }
      if (!_showPast && session.isPast) return false;
      if (query.isNotEmpty && !session.title.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    });
    final sorted = List.of(filtered)
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search confessions',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(_searchController.clear),
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _categoryFilter == null,
                  onSelected: (_) => setState(() => _categoryFilter = null),
                ),
                const SizedBox(width: 8),
                for (final category in BugType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.label),
                      avatar: Icon(category.icon, size: 18),
                      selected: _categoryFilter == category,
                      onSelected: (_) =>
                          setState(() => _categoryFilter = category),
                    ),
                  ),
                FilterChip(
                  label: const Text('Show past'),
                  selected: _showPast,
                  onSelected: (value) => setState(() => _showPast = value),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: sorted.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off,
                  message: 'No confessions match your filters.',
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 600) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 360,
                              mainAxisExtent: 110,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: sorted.length,
                        itemBuilder: (context, index) =>
                            _buildCard(sorted[index]),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: sorted.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _buildCard(sorted[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCard(Session session) => SessionCard(
    session: session,
    onTap: () => widget.onOpen(session),
    onToggleFavourite: () => widget.onToggleFavourite(session),
  );
}
