import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String university;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  @override
  Widget build(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: const AssetImage('assets/images/my_photo.jpg'),
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            Text(
              university,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(ctx).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
