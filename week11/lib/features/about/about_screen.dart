import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/env.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  String get mode => kReleaseMode
      ? 'release'
      : kProfileMode
      ? 'profile'
      : 'debug';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<PackageInfo>(
        future: _info,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final info = snapshot.data;
          if (info == null) return const Center(child: Text('No build info'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: Text(
                  '${info.version} (${info.buildNumber}) · $mode · ${Env.name} · ${Env.host}',
                ),
              ),
              ListTile(
                title: const Text('License notices'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(context: context),
              ),
            ],
          );
        },
      ),
    );
  }
}
