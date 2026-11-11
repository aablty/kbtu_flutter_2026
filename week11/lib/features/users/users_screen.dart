import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user_list.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: _buildBody(model),
    );
  }

  Widget _buildBody(UsersModel model) {
    if (model.loading && model.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.error case final error?) {
      return switch (error) {
        NoConnectionException() => _ErrorView(
          title: 'No connection',
          message: 'Check your network and try again.',
          onRetry: model.load,
        ),
        NotFoundException() || UnauthorizedException() => _ErrorView(
          title: 'Request was not allowed',
          message: 'The server did not return the requested users.',
          onRetry: model.load,
        ),
        ServerException(:final status) => _ErrorView(
          title: 'Server error',
          message: 'The server returned status $status.',
          onRetry: model.load,
        ),
        BadResponseException() => const _ErrorView(
          title: 'Invalid response',
          message: 'The server returned data we could not read.',
        ),
      };
    }

    return RefreshIndicator(
      onRefresh: model.load,
      child: UserList(users: model.items),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.title, required this.message, this.onRetry});

  final String title;
  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    ),
  );
}
