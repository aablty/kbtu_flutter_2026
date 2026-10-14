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
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final FocusNode _emailFocus = FocusNode();

  int passwordLength = 0;

  void _signUp() {
    if (_formKey.currentState?.validate() != true) return;

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
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              validator: (v) => (v ?? '').trim().length < 2
                  ? 'Name must be at least 2 characters'
                  : null,
              controller: _name,
              decoration: InputDecoration(label: const Text('Name')),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            TextFormField(
              validator: (v) => (v ?? '').trim().contains('@kbtu.kz') == false
                  ? 'Email must be a valid KBTU email'
                  : null,
              controller: _email,
              decoration: InputDecoration(
                label: const Text('Email'),
                hintText: 'name@kbtu.kz',
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            TextFormField(
              validator: (v) => (v ?? '').length < 8
                  ? 'Password must be at least 8 characters'
                  : null,
              controller: _password,
              decoration: InputDecoration(
                label: const Text('Password'),
                helperText: 'At least 8 characters',
              ),
              textInputAction: TextInputAction.next,
              obscureText: true,
              onChanged: (v) => setState(() => passwordLength = v.length),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            Text('${min(8, passwordLength).toString()} of 8'),
            TextFormField(
              validator: (v) =>
                  (v ?? '') != _password.text ? 'Passwords do not match' : null,
              controller: _confirm,
              decoration: InputDecoration(
                label: const Text('Confirm password'),
              ),
              textInputAction: TextInputAction.done,
              obscureText: true,
              onFieldSubmitted: (_) => _signUp(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            SizedBox(height: 24),
            FilledButton(onPressed: _signUp, child: const Text('Sign Up')),
          ],
        ),
      ),
    ),
  );
}
