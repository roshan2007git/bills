import 'package:bills/pages/registrations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messages extends StatefulWidget {
  final User currrentUser;
  const Messages({super.key, required this.currrentUser});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        Registrations(currentUser: widget.currrentUser),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        title: const Text(
          "MESSAGES",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: const [SizedBox(width: 55)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase().trim();
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by name or email...",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[850],
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final filteredDocs =
                    docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['name'] ?? '').toString().toLowerCase();
                      final email =
                          (data['email'] ?? '').toString().toLowerCase();
                      return name.contains(searchQuery) ||
                          email.contains(searchQuery);
                    }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages found",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final name = data['name'] ?? 'No Name';
                    final email = data['email'] ?? 'No Email';

                    return ListTile(
                      title: Text(
                        name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageDetailPage(data: data),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MessageDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const MessageDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'No Name';
    final email = data['email'] ?? 'No Email';
    final number = data['number'] ?? 'No Number';
    final message = data['message'] ?? 'No Message';
    final timestamp = data['timestamp'] ?? 'No Timestamp';

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          centerTitle: true,
          title: const Text(
            "Message Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDetail("Name", name),
                buildDetail("Email", email, selectable: true),
                buildDetail("Phone Number", number, selectable: true),
                buildDetail("Message", message),
                buildDetail("Timestamp", timestamp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDetail(String title, String value, {bool selectable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          selectable
              ? SelectableText(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              )
              : Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
        ],
      ),
    );
  }
}
