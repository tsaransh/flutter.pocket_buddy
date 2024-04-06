import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pocketbuddy/screens/user_profile.dart';

enum SampleItem {
  profile,
  logout,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final _popMenuKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Buddy'),
        actions: [
          PopupMenuButton<SampleItem>(
            icon: const Icon(Icons.person),
            onSelected: (SampleItem item) {
              // Handle menu item selection here
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<SampleItem>>[
                PopupMenuItem<SampleItem>(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const UserProfile(),
                        ),
                      );
                    },
                    key: _popMenuKey,
                    mouseCursor: MouseCursor.defer,
                    value: SampleItem.profile,
                    child: const ListTile(
                      leading: Icon(Icons.person_3),
                      title: Text('Profile'),
                    )),
                PopupMenuItem<SampleItem>(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                    },
                    value: SampleItem.logout,
                    child: const ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    )),
              ];
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
