import 'package:flutter/material.dart';

import 'profile.dart';
import 'session.dart';

abstract final class Routes {
  static const shell = '/';
  static const detail = '/session';
  static const form = '/session/form';
}

class SessionDetailArgs {
  const SessionDetailArgs({
    required this.session,
    required this.profile,
    required this.onUpdate,
    required this.onDelete,
    required this.onSwitchToProfileTab,
  });

  final Session session;
  final Profile profile;
  final ValueChanged<Session> onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onSwitchToProfileTab;
}

class SessionFormArgs {
  const SessionFormArgs({this.initial});

  final Session? initial;
}
