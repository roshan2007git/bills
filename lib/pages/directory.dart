import 'package:bills/backend/usercall.dart';
import 'package:bills/pages/info.dart';
import 'package:bills/pages/login.dart';
import 'package:bills/pages/upload.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bills/backend/refresh.dart';

const List names = ['John', 'Jacob', 'Aron', 'Amy', 'Brad', 'Ben'];

class Directory extends StatefulWidget {
  final User currentUser;
  const Directory({super.key, required this.currentUser});

  @override
  State<Directory> createState() => _DirectoryState();
}

class _DirectoryState extends State<Directory> {
  String? name;
  List? bills;
  double? amount;
  CallUser val = CallUser();

  Future<void> _fetchName() async {
    String fetchedName = await val.name(widget.currentUser);
    if (mounted) {
      setState(() {
        name = fetchedName; // Update the state with the fetched name
      });
    }
  }

  Future<void> _fetchamount() async {
    try {
      // Fetch the bills
      double fetchedamount = await val.amount(widget.currentUser);
      if (mounted) {
        setState(() {
          amount = fetchedamount; // Update the state with the fetched bills
        });
      }
    } catch (e) {
      // You can also set bills to an empty list in case of error to prevent null
      if (mounted) {
        setState(() {
          amount = 0;
        });
      }
    }
  }

  Future<void> _fetchbills() async {
    try {
      // Fetch the bills
      List fetchedBills = await val.bills(widget.currentUser);
      if (mounted) {
        setState(() {
          bills = fetchedBills; // Update the state with the fetched bills
        });
      }
    } catch (e) {
      // You can also set bills to an empty list in case of error to prevent null
      if (mounted) {
        setState(() {
          bills = [];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Call the async method in a separate function
    _fetchName();
    _fetchbills();
    _fetchamount();
  }

  String? error;
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      ); // This logs the user out
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> _refresh() async {
    await _fetchName();
    await _fetchamount();
    await _fetchbills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      bottomNavigationBar: Container(
        color: Colors.grey[900],
        width: MediaQuery.of(context).size.width,
        height: 120,
        padding: EdgeInsets.only(bottom: 27),
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Info()),
                      );
                    },
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 5,
                      bottom: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    child: Text(
                      "Total Amount: ₹$amount",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                height: 60,
                width: 60,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                Upload(currentUser: widget.currentUser),
                      ),
                    );
                  },
                  icon: Icon(Icons.add, size: 40),
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        title: Container(
          padding: EdgeInsets.only(left: 30, top: 7),
          child: Text(
            "$name's bills",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
        actions: [
          Container(
            padding: EdgeInsets.only(right: 20),
            color: Colors.transparent,
            child: IconButton(
              onPressed: () {
                signOut();
              },
              icon: Icon(Icons.logout, size: 25),
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Refresh(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: Container(
              color: Colors.grey[900],
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(
                top: 40,
                bottom: 40,
                right: 25,
                left: 25,
              ),
              child: Column(
                spacing: 14,
                children: [
                  Text(
                    "Files Uploaded",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: ListView.builder(
                      itemCount: bills?.isNotEmpty ?? false ? bills!.length : 1,
                      itemBuilder:
                          (context, index) => ListTile(
                            visualDensity: VisualDensity(vertical: -4),
                            contentPadding: EdgeInsets.zero,
                            minVerticalPadding: 0,
                            dense: true,
                            title:
                                bills?.isNotEmpty ?? false
                                    ? Text(
                                      "— ${bills![index]['billname']}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    )
                                    : Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(top: 35),
                                      child: Text(
                                        "No bills Uploaded",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                          ),
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
