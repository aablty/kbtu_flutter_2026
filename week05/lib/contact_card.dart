import 'package:flutter/material.dart';

import 'contacts.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  const ContactCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        // 164 px
        child: Row(
          children: [
            CircleAvatar(child: Text(contact.initial)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: textTheme.titleMedium),
                  Text(contact.email, style: textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
