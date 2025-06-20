import 'package:bills/backend/refresh.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Institutional extends StatefulWidget {
  final User currentUser;
  const Institutional({super.key, required this.currentUser});

  @override
  State<Institutional> createState() => _InstitutionalState();
}

class _InstitutionalState extends State<Institutional> {
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
                "INSTITUTIONAL",
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
                          .collection('instiRegistrations')
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
                          final institutionName =
                              (data['institutionName'] ?? '')
                                  .toString()
                                  .toLowerCase();
                          return uid.contains(searchQuery.toLowerCase()) ||
                              institutionName.contains(
                                searchQuery.toLowerCase(),
                              );
                        }).toList();

                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.74,
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
                                  final institutionName =
                                      data['institutionName'] ?? '';
                                  String name = institutionName;
                                  String uid = doc.id;
                                  name = name
                                      .replaceAll('_', ' ')
                                      .replaceAll('-', ' ');
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => TeamInfo(
                                                currentUser: widget.currentUser,
                                                data:
                                                    doc.data()
                                                        as Map<String, dynamic>,
                                                uid: "T25N$uid",
                                              ),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      title: Text(
                                        "T25N$uid",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        name,
                                        style: TextStyle(color: Colors.white70),
                                      ),
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

class TeamInfo extends StatefulWidget {
  final User currentUser;
  final Map<String, dynamic> data;
  final String uid;
  const TeamInfo({
    super.key,
    required this.currentUser,
    required this.data,
    required this.uid,
  });

  @override
  State<TeamInfo> createState() => _TeamInfoState();
}

class _TeamInfoState extends State<TeamInfo> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';
  List<Widget> _buildKeyValueTiles(Map<String, dynamic>? data) {
    if (data == null) {
      return [Text("No data found", style: TextStyle(color: Colors.white70))];
    }

    return data.entries.map((entry) {
      String value = entry.value.toString();
      if (value.length > 30) {
        value = '${value.substring(0, 30)}...';
      }
      return ListTile(
        title: Text(value, style: TextStyle(color: Colors.white)),
        subtitle: Text(
          entry.key.replaceAll("_", " "),
          style: TextStyle(color: Colors.white70),
        ),
      );
    }).toList();
  }

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
    final events = widget.data['events'] as List<dynamic>?;
    final teacher = widget.data['teacher'] ?? {};
    final teacherName = teacher['name'] ?? 'Unknown';
    final total = widget.data['totalParticipants'] ?? 'Unknown';
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
                widget.uid,
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        total.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Total Participants",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        teacherName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Teacher Incharge",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        "Events",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // 🔸 Events List
                    events == null || events.isEmpty
                        ? Center(
                          child: Text(
                            "No Events Found",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount:
                              events.where((event) {
                                final name =
                                    (event['name'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                return name.contains(searchQuery.toLowerCase());
                              }).length,
                          itemBuilder: (context, index) {
                            final filteredEvents =
                                events.where((event) {
                                  final name =
                                      (event['name'] ?? '')
                                          .toString()
                                          .toLowerCase();
                                  return name.contains(
                                    searchQuery.toLowerCase(),
                                  );
                                }).toList();

                            final event =
                                filteredEvents[index] as Map<String, dynamic>;
                            final name = event['name'] ?? 'Unnamed Event';
                            String eventName = name;
                            if (name.toLowerCase() == 'stratagem') {
                              final category = event['category'] ?? '';
                              eventName = '$name $category';
                            }
                            return ListTile(
                              title: Text(
                                eventName
                                    .replaceAll("-", " ")
                                    .replaceAll("_", " "),
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),

                    // 🔸 Payment Details
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        "Payment Details",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._buildKeyValueTiles(
                      widget.data['paymentDetails'] as Map<String, dynamic>?,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
