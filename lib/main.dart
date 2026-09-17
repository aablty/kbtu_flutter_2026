import 'package:flutter/material.dart';

import 'data.dart';
import 'profile_header.dart';
import 'info_row.dart';

void main() => runApp(
  MaterialApp(
    theme: ThemeData(
      fontFamily: 'Montserrat',
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: ProfileHeader(name: myName, university: myUniversity),
            ),
            Padding(padding: EdgeInsets.only(top: 16)),
            ...facts.map(
              (fact) => InfoRow(label: fact.label, value: fact.value),
            ),
          ],
        ),
      ),
    ),
  ),
);
