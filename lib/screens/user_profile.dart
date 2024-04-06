import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic>? _userData;

  void _fetchUserData() async {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();
    setState(() {
      _userData = userData.data();
    });
    if (_userData == null) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('User Not Found'),
            content: Text(
                'Data not found with email: ${FirebaseAuth.instance.currentUser!.email}, Please login again.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  FirebaseAuth.instance.signOut();
                },
                child: const Text('Okay'),
              )
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal, Colors.blue],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 48,
                      child: Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About me',
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(height: 16),
                          _userData != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(context, Icons.person, 'Name',
                                        _userData!['user_name']),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(context, Icons.email, 'Email',
                                        _userData!['user_email']),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: _showChangePasswordDialog,
                                      child: const Text('Change Password'),
                                    ),
                                  ],
                                )
                              : const CircularProgressIndicator(), // Show loading indicator if data is being fetched
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    FirebaseAuth.instance
        .sendPasswordResetEmail(email: _userData!['user_email']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Change Password email send to your email id'),
                // Add more widgets here if needed
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Add your logic to change the password here
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                FirebaseAuth.instance.signOut();
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildInfoRow(
    BuildContext context, IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    ],
  );
}
