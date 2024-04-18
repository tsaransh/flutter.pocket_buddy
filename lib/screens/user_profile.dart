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

  bool _isLoading = false;

  void _fetchUserData() async {
    setState(() {
      _isLoading =
          true; // Add a new state variable _isLoading and initialize it as false
    });

    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .get();

      if (userData.exists) {
        setState(() {
          _userData = userData.data();
          _isLoading =
              false; // Set _isLoading to false when data fetching is completed
        });
      } else {
        setState(() {
          _isLoading =
              false; // Set _isLoading to false if user data doesn't exist
        });

        showDialog(
          // ignore: use_build_context_synchronously
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
                    FirebaseAuth.instance.signOut();
                  },
                  child: const Text('Okay'),
                )
              ],
            );
          },
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false; // Set _isLoading to false if an error occurs
      });
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 62,
                      foregroundImage:
                          AssetImage('assets/images/default_profile.png'),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).colorScheme.background,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'About me.',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(context, Icons.person, 'Name',
                                _userData!['user_name']),
                            const SizedBox(height: 16),
                            _buildInfoRow(context, Icons.email, 'Email',
                                _userData!['user_email']),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              style: const ButtonStyle(
                                iconColor:
                                    MaterialStatePropertyAll(Colors.white),
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.teal),
                                padding: MaterialStatePropertyAll(
                                  EdgeInsets.all(8),
                                ),
                              ),
                              onPressed: _showChangePasswordDialog,
                              icon: const Icon(Icons.lock),
                              label: const Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
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
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    ],
  );
}
