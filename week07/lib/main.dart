import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  int passwordLength = 0;

  void _signUp() {
    final name = _name.text;
    final email = _email.text;
    final password = _password.text;
    final confirm = _confirm.text;

    if (name.length < 2) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name is too short')));
      return;
    }

    if (!email.contains('@kbtu.kz')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email looks wrong')));
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password is too short')));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(label: const Text('Name')),
          ),
          TextField(
            controller: _email,
            decoration: InputDecoration(
              label: const Text('Email'),
              hintText: 'name@kbtu.kz',
            ),
          ),
          TextField(
            controller: _password,
            decoration: InputDecoration(
              label: const Text('Password'),
              helperText: 'At least 8 characters',
            ),
            onChanged: (v) => setState(() => passwordLength = v.length),
          ),
          Text('${min(8, passwordLength).toString()} of 8'),
          TextField(
            controller: _confirm,
            decoration: InputDecoration(label: const Text('Confirm password')),
          ),
          SizedBox(height: 16),
          FilledButton(onPressed: _signUp, child: const Text('Sign Up')),
        ],
      ),
    ),
  );
}
