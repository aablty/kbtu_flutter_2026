import 'package:flutter/material.dart';
import 'package:never_overflows/contact_card.dart';
import 'package:never_overflows/contacts.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key});
  @override
  Widget build(BuildContext context) => ContactCard(contact: contacts[4]);
}
