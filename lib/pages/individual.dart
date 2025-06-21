import 'package:bills/backend/refresh.dart';
import 'package:bills/pages/editIndi.dart';
import 'package:bills/pages/registrations.dart';
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
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                          Registrations(currentUser: widget.currentUser),
                ),
              );
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

              Expanded(
                child: Refresh(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('indiRegistrations')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Something went wrong'),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      final filteredDocs =
                          docs.where((doc) {
                            final uid = "t25n${doc.id.toLowerCase()}";
                            final data = doc.data() as Map<String, dynamic>;
                            final eventName =
                                data['event']['name'].toString().toLowerCase();
                            final email =
                                data['email'].toString().toLowerCase();
                            return uid.contains(searchQuery) ||
                                eventName.contains(searchQuery) ||
                                email.contains(searchQuery);
                          }).toList();

                      if (filteredDocs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No Registration Found",
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final event = data['event'];
                          String name = '';
                          if (event['name'] == 'stratagem' ||
                              event['name'] == '221b') {
                            name = "${event['name']}-${event['category']}";
                          } else {
                            name = event['name'];
                          }
                          String uid = doc.id;
                          name = name.replaceAll('_', ' ').replaceAll('-', ' ');
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => TeamInfo(
                                        currentUser: widget.currentUser,
                                        data: data,
                                        uid: "T25N$uid",
                                        event: name,
                                      ),
                                ),
                              );
                            },
                            child: ListTile(
                              title: Text(
                                "T25N$uid - $name",
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                data['email'],
                                style: TextStyle(color: Colors.white70),
                              ),
                              trailing: SizedBox(
                                height: 34,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (data['present'] != null &&
                                        data['present']) ...[
                                      Text(
                                        "Present",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                    if (data['present'] == null ||
                                        !data['present']) ...[
                                      GestureDetector(
                                        onTap: () async {
                                          // Set present to true
                                          await FirebaseFirestore.instance
                                              .collection('indiRegistrations')
                                              .doc(doc.id)
                                              .update({'present': true});
                                        },
                                        child: Container(
                                          height: 34,
                                          width: 34,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(Icons.check),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamInfo extends StatefulWidget {
  final User currentUser;
  final Map<String, dynamic> data;
  final String uid;
  final String event;

  const TeamInfo({
    super.key,
    required this.currentUser,
    required this.data,
    required this.uid,
    required this.event,
  });

  @override
  State<TeamInfo> createState() => _TeamInfoState();
}

class _TeamInfoState extends State<TeamInfo> {
  @override
  Widget build(BuildContext context) {
    final name = widget.data['fName'] ?? 'N/A';
    final number = widget.data['phoneNumber'] ?? 'N/A';
    final email = widget.data['email'] ?? 'N/A';
    final dob = widget.data['dateOfBirth'] ?? 'N/A';
    final teammates = widget.data['event']['teammates'] ?? [];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (conetext) => Individual(currentUser: widget.currentUser),
                ),
              );
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
          actions: [
            SizedBox(
              height: 55,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.data['present'] != null &&
                      widget.data['present']) ...[
                    TextButton(
                      onPressed: () async {
                        // Set present to false
                        await FirebaseFirestore.instance
                            .collection('indiRegistrations')
                            .doc(widget.uid.substring(4))
                            .update({'present': false});
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    Individual(currentUser: widget.currentUser),
                          ),
                        );
                      },
                      child: Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    "Event: ${widget.event.toUpperCase()}",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              // Captain Card
              _buildPersonCard(
                name,
                number,
                email,
                dob,
                widget.uid.substring(4),
                null,
              ),
              // Teammates (if any)
              if (teammates is List && teammates.isNotEmpty)
                ...teammates.asMap().entries.map<Widget>((entry) {
                  final index = entry.key;
                  final teammate = entry.value;

                  final tName = teammate['name'] ?? 'N/A';
                  final tNumber = teammate['phoneNumber'] ?? 'N/A';
                  final tEmail = teammate['email'] ?? 'N/A';
                  final tDob = teammate['dateOfBirth'] ?? 'N/A';

                  return _buildPersonCard(
                    tName,
                    tNumber,
                    tEmail,
                    tDob,
                    widget.uid.substring(4),
                    index, // you now have the index!
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonCard(
    String name,
    String number,
    String email,
    String dob,
    String uid,
    int? teamindex,
  ) {
    return GestureDetector(
      onTap: () async {
        try {
          // Get current user's document from Firestore
          final userDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.currentUser.uid)
                  .get();

          if (!userDoc.exists) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('User document not found')));
            return;
          }

          final userData = userDoc.data()!;
          final isEditable = userData['edit'] == true;

          if (isEditable) {
            if (!mounted) return;
            // Allow navigation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => EditDetailsIndi(
                      data: widget.data,
                      currentUser: widget.currentUser,
                      uid: widget.uid.substring(4),
                      teammateIndex: teamindex,
                      eventbackup: widget.event,
                    ),
              ),
            );
          } else {
            // Prevent navigation and show message
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'You are not authorized to make changes to this file',
                ),
              ),
            );
          }
          if (!mounted) return;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error checking permission: $e')),
          );
        }
      },

      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $name", style: TextStyle(color: Colors.white)),
            Text("Phone: $number", style: TextStyle(color: Colors.white)),
            Text("Email: $email", style: TextStyle(color: Colors.white)),
            Text("DOB: $dob", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
