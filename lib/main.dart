import 'package:flutter/material.dart';

import 'data.dart';
import 'profile_header.dart';

void main() => runApp(
  MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Center(
              child: ProfileHeader(name: myName, university: myUniversity),
            ),
          ],
        ),
      ),
    ),
  ),
);
