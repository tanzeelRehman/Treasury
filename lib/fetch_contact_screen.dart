// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class FetchContactScreen extends StatefulWidget {
  const FetchContactScreen({super.key});

  @override
  State<FetchContactScreen> createState() => _FetchContactScreenState();
}

class _FetchContactScreenState extends State<FetchContactScreen> {
  @override
  void initState() {
    fetchContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: const Text('Fetch screen'))),
    );
  }

  List<CustomContact> contactList = [];

  Future<void> fetchContacts() async {
    contactList.clear();
    final Iterable<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    for (var contact in contacts) {
      final contactEmails = contact.emails;
      final contactPhones = contact.phones;
      String emailString = '';
      String phoneString = '';
      if (contactEmails != null && contactEmails.isNotEmpty) {
        if (contactEmails.first.value != null &&
            contactEmails.first.value!.isNotEmpty) {
          emailString = contactEmails.first.value!;
        }
      }
      if (contactPhones != null && contactPhones.isNotEmpty) {
        if (contactPhones.first.value != null &&
            contactPhones.first.value!.isNotEmpty) {
          phoneString = contactPhones.first.value!;
        }
      }

      contactList.add(CustomContact(
          displayName: contact.displayName ?? 'Unknown',
          phone: phoneString,
          email: emailString));
    }
  }
}

class CustomContact {
  String displayName;
  String phone;
  String email;
  CustomContact({
    required this.displayName,
    required this.phone,
    required this.email,
  });

  @override
  String toString() =>
      'CustomContact(displayName: $displayName, phone: $phone, email: $email)';

  @override
  bool operator ==(covariant CustomContact other) {
    if (identical(this, other)) return true;

    return other.displayName == displayName &&
        other.phone == phone &&
        other.email == email;
  }

  @override
  int get hashCode => displayName.hashCode ^ phone.hashCode ^ email.hashCode;
}
