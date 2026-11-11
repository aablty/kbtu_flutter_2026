import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../settings/settings_model.dart';
import 'user.dart';
import 'user_list.dart';
import 'users_model.dart';
import 'widgets/city_filter.dart';
import 'widgets/empty_users_view.dart';
import 'widgets/users_error_view.dart';
import 'widgets/users_header.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final settings = context.watch<SettingsModel>();
    final city = settings.city;
    final cities = model.items.map((user) => user.address.city).toSet().toList()
      ..sort();
    final visibleUsers = city == null
        ? model.items
        : model.items.where((user) => user.address.city == city).toList();

    return Scaffold(
      appBar: UsersHeader(
        onCreate: () => Navigator.of(context).pushNamed('/create'),
        onSettings: () => Navigator.of(context).pushNamed('/settings'),
      ),
      body: Column(
        children: [
          CityFilter(
            cities: cities,
            value: city,
            onChanged: (value) =>
                unawaited(context.read<SettingsModel>().setCity(value)),
          ),
          Expanded(child: _buildBody(model, visibleUsers)),
        ],
      ),
    );
  }

  Widget _buildBody(UsersModel model, List<User> users) {
    if (model.loading && model.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.error case final error?) {
      return switch (error) {
        NoConnectionException() => UsersErrorView(
          title: 'No connection',
          message: 'Check your network and try again.',
          onRetry: model.load,
        ),
        NotFoundException() || UnauthorizedException() => UsersErrorView(
          title: 'Request was not allowed',
          message: 'The server did not return the requested users.',
          onRetry: model.load,
        ),
        ServerException(:final status) => UsersErrorView(
          title: 'Server error',
          message: 'The server returned status $status.',
          onRetry: model.load,
        ),
        BadResponseException() => const UsersErrorView(
          title: 'Invalid response',
          message: 'The server returned data we could not read.',
        ),
      };
    }

    if (users.isEmpty) return const EmptyUsersView();

    return RefreshIndicator(
      onRefresh: model.load,
      child: UserList(users: users, fromCache: model.fromCache),
    );
  }
}
