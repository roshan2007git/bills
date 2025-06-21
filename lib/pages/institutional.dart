import 'package:bills/backend/refresh.dart';
import 'package:bills/pages/editInsti.dart';
import 'package:bills/pages/editTeacher.dart';
import 'package:bills/pages/registrations.dart';
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
                        return const Center(
                          child: Text('Something went wrong'),
                        );
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
                                                  currentUser:
                                                      widget.currentUser,
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
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
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
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                              if (data['present'] == null ||
                                                  !data['present']) ...[
                                                GestureDetector(
                                                  onTap: () async {
                                                    // Set present to true
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                          'instiRegistrations',
                                                        )
                                                        .doc(doc.id)
                                                        .update({
                                                          'present': true,
                                                        });
                                                  },
                                                  child: Container(
                                                    height: 34,
                                                    width: 34,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                ),
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
  final String uid;
  const TeamInfo({super.key, required this.currentUser, required this.uid});

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

  late Future<DocumentSnapshot<Map<String, dynamic>>> _future;
  @override
  void initState() {
    super.initState();
    _future =
        FirebaseFirestore.instance
            .collection('instiRegistrations')
            .doc(widget.uid.substring(4)) // remove T25N prefix
            .get();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text(
              "Error loading data",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final data = snapshot.data!.data()!;

        // Now you can use 'data' below like before
        final events = data['events'] as List<dynamic>? ?? [];
        final teacher = data['teacher'] ?? {};
        final teacherName = teacher['name'] ?? 'Unknown';
        final total = data['totalParticipants'] ?? 'Unknown';

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.grey[900],
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed:
                    () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Institutional(
                                currentUser: widget.currentUser,
                              ),
                        ),
                      ),
                    },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              backgroundColor: Colors.grey[900],
              centerTitle: true,
              title: Text(
                widget.uid,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                SizedBox(
                  height: 55,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (data['present'] != null && data['present']) ...[
                        TextButton(
                          onPressed: () async {
                            // Set present to false
                            await FirebaseFirestore.instance
                                .collection('instiRegistrations')
                                .doc(widget.uid.substring(4))
                                .update({'present': false});
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => Institutional(
                                      currentUser: widget.currentUser,
                                    ),
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
                          GestureDetector(
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('User document not found'),
                                    ),
                                  );
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
                                          (context) => EditTeacher(
                                            data: data['teacher'],
                                            uid: widget.uid.substring(4),
                                            currentUser: widget.currentUser,
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
                                  SnackBar(
                                    content: Text(
                                      'Error checking permission: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: ListTile(
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
                          events.isEmpty
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
                                      return name.contains(
                                        searchQuery.toLowerCase(),
                                      );
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
                                      filteredEvents[index]
                                          as Map<String, dynamic>;
                                  final name = event['name'] ?? 'Unnamed Event';
                                  String eventName = name;
                                  if (name.toLowerCase() == 'stratagem') {
                                    final category = event['category'] ?? '';
                                    eventName = '$name $category';
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ParticipantInfo(
                                                currentUser: widget.currentUser,
                                                data: filteredEvents[index],
                                                event: eventName.toUpperCase(),
                                                uid: widget.uid,
                                                eventidx: index,
                                                fullData: data,
                                              ),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      title: Text(
                                        eventName
                                            .replaceAll("-", " ")
                                            .replaceAll("_", " "),
                                        style: TextStyle(color: Colors.white),
                                      ),
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
                            data['paymentDetails'] as Map<String, dynamic>?,
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ParticipantInfo extends StatefulWidget {
  final User currentUser;
  final Map<String, dynamic> data;
  final String event;
  final String uid;
  final int eventidx;
  final Map<String, dynamic> fullData;
  const ParticipantInfo({
    super.key,
    required this.currentUser,
    required this.data,
    required this.event,
    required this.uid,
    required this.eventidx,
    required this.fullData,
  });

  @override
  State<ParticipantInfo> createState() => _ParticipantInfoState();
}

class _ParticipantInfoState extends State<ParticipantInfo> {
  @override
  Widget build(BuildContext context) {
    final teammates = widget.data['participants'] ?? [];

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
                      (context) => TeamInfo(
                        currentUser: widget.currentUser,
                        uid: widget.uid,
                      ),
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
                  widget.event,
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                    widget.uid,
                    index,
                    widget.eventidx,
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
    int eventindex,
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
                    (context) => EditDetailsInsti(
                      data: widget.fullData,
                      currentUser: widget.currentUser,
                      uid: widget.uid.substring(4),
                      teammateIndex: teamindex,
                      eventIndex: eventindex,
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
