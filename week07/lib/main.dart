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
  final _dateOfBirth = TextEditingController();
  String? _group;
  DateTime? _birth;
  bool _agreed = false;

  final FocusNode _emailFocus = FocusNode();

  int passwordLength = 0;

  void _signUp() {
    if (!_agreed) return;
    if (_formKey.currentState?.validate() != true) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _dateOfBirth]) {
      c.dispose();
    }
    _emailFocus.dispose();
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
              focusNode: _emailFocus,
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
            DropdownButtonFormField<String>(
              validator: (g) => g == null ? 'Choose a group' : null,
              initialValue: _group,
              items: [
                for (final g in groups) DropdownMenuItem(value: g, child: Text(g)),
              ],
              onChanged: (v) => setState(() => _group = v),
              decoration: InputDecoration(
                label: const Text('Group'),
                hintText: 'Select your group',
              ),
            ),
            TextFormField(
              readOnly: true,
              validator: (_) => _birth == null ? 'Choose a date of birth' : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date == null) return;
                if (!mounted) return;
                setState(() {
                  _birth = date;
                  _dateOfBirth.text =
                      '${date.day.toString().padLeft(2, '0')}.'
                      '${date.month.toString().padLeft(2, '0')}.${date.year}';
                });
              },
              controller: _dateOfBirth,
              decoration: InputDecoration(
                label: const Text('Date of birth'),
                suffixIcon: Icon(Icons.calendar_month),
              ),
            ),
            CheckboxListTile(
              title: const Text('I agree to the rules'),
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
            ),
            SizedBox(height: 24),
            FilledButton(
              onPressed: _agreed ? _signUp : null,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    ),
  );
}
