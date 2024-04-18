import 'package:flutter/material.dart';
import 'package:pocketbuddy/model/room_details.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() {
    return _DrawerWidgetState();
  }
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final _searchRoomController = TextEditingController();
  final _groupTitleController = TextEditingController();
  final ExpenseRoom expenseRoom = ExpenseRoom(
      id: '0001',
      title: 'Saransh\'s Room',
      createdDate: DateTime.now(),
      createdBy: 'Ansh');

  @override
  void dispose() {
    _searchRoomController.dispose();
    _groupTitleController.dispose();
    super.dispose();
  }

  void _showGroupDetails() {
    if (_searchRoomController.text.isEmpty) {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Please enter the room id "),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Okay'),
                  )
                ],
              ),
            );
          });
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(expenseRoom.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("created by ${expenseRoom.createdBy}"),
                Text("on ${expenseRoom.createdDate}"),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.create),
                  label: const Text('Join'),
                )
              ],
            ),
          );
        });
  }

  void _showCreateRoom() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Create new expense room'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _groupTitleController,
                  decoration: const InputDecoration(
                    labelText: 'title of the room',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Create Room'),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Center(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchRoomController,
                  decoration: const InputDecoration(
                      labelText: 'Enter your code here...'),
                ),
              ),
              TextButton(
                onPressed: _showGroupDetails,
                child: const Icon(Icons.search),
              )
            ],
          ),
          const SizedBox(height: 36),
          ElevatedButton.icon(
            onPressed: _showCreateRoom,
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text('Create Room'),
          )
        ],
      ),
    ));
  }
}
