import 'package:bills/backend/refresh.dart';
import 'package:bills/backend/reginfo.dart';
import 'package:bills/pages/directory.dart';
import 'package:bills/pages/individual.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Registrations extends StatefulWidget {
  final User currentUser;
  const Registrations({super.key, required this.currentUser});

  @override
  State<Registrations> createState() => _RegistrationsState();
}

class _RegistrationsState extends State<Registrations> {
  int total = 0;
  int totalinsti = 0;
  Map<String, int> events = {};

  RegInfo inf = RegInfo();

  @override
  void initState() {
    super.initState();
    loadTotalAmount();
    getEventData();
    loadTotalInsti();
  }

  Future<void> loadTotalAmount() async {
    total = await inf.fetchTotal();
    setState(() {}); // update UI after fetch
  }

  Future<void> loadTotalInsti() async {
    totalinsti = await inf.fetchTotalinsti();
    setState(() {}); // update UI after fetch
  }

  Future<void> getEventData() async {
    events = await inf.fetchEventTotal();
    setState(() {}); // update UI after fetch
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
                      (context) => Directory(currentUser: widget.currentUser),
                ),
              );
            },
            icon: Icon(Icons.home),
            color: Colors.white,
          ),
          backgroundColor: Colors.grey[900],
          centerTitle: true,
          title: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "REGISTRATIONS",
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
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Refresh(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                spacing: 15,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.black,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    Individual(currentUser: widget.currentUser),
                          ),
                        );
                      },
                      child: Text(
                        "Individual",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.black,
                    ),
                    child: TextButton(
                      onPressed: () {
                        //
                      },
                      child: Text(
                        "Institutional",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Total Participants: $total',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Total Institutions: $totalinsti',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.60,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children:
                          events.entries.map((entry) {
                            // Remove underscores and hyphens from the key
                            String formattedKey = entry.key
                                .replaceAll('_', ' ')
                                .replaceAll('-', ' ');
                            int value = entry.value;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                "$formattedKey : $value",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
