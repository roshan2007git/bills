import 'package:bills/backend/refresh.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Individual extends StatefulWidget {
  final User currentUser;
  const Individual({super.key, required this.currentUser});

  @override
  State<Individual> createState() => _IndividualState();
}

class _IndividualState extends State<Individual> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

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
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                "INDIVIDUAL",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [SizedBox(width: 55)],
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard only when tapped outside
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔍 Search Box (stays persistent)
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
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[850],
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  searchFocusNode
                      .unfocus(); // Dismiss keyboard when Done is pressed
                },
              ),
            ),

            // 📡 Firestore StreamBuilder (below search bar)
            Expanded(
              child: Refresh(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('indiRegistrations')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    // Filter results based on search query
                    final filteredDocs =
                        docs.where((doc) {
                          final uid = "t25n${doc.id.toLowerCase()}";
                          final data = doc.data() as Map<String, dynamic>;
                          final eventName = data['event']['name']
                              .toString()
                              .toLowerCase()
                              .replaceAll('_', ' ')
                              .replaceAll('-', ' ');
                          return uid.contains(searchQuery) ||
                              eventName.contains(searchQuery);
                        }).toList();

                    return Expanded(
                      child:
                          filteredDocs.isEmpty
                              ? Center(
                                child: Text(
                                  "No Registration Found",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                              : ListView.builder(
                                itemCount: filteredDocs.length,
                                itemBuilder: (context, index) {
                                  final doc = filteredDocs[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final event = data['event'];
                                  String name = '';
                                  if (event['name'] == 'stratagem' ||
                                      event['name'] == '221b') {
                                    name =
                                        "${event['name']}-${event['category']}";
                                  } else {
                                    name = event['name'];
                                  }
                                  String uid = doc.id;
                                  name = name
                                      .replaceAll('_', ' ')
                                      .replaceAll('-', ' ');
                                  return ListTile(
                                    title: Text(
                                      "T25N$uid",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      name,
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  );
                                },
                              ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
