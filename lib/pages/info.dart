import 'package:bills/backend/refresh.dart';
import 'package:bills/backend/usercall.dart';
import 'package:bills/pages/admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Info extends StatefulWidget {
  final User currentUser;
  const Info({super.key, required this.currentUser});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  CallUser check = CallUser();
  bool admin = false;

  @override
  void initState() {
    super.initState();
    _authcheck();
  }

  Future<void> _authcheck() async {
    try {
      // Fetch the bills
      bool isAdmin = await check.admin(widget.currentUser);
      if (mounted) {
        setState(() {
          admin = isAdmin; // Update the state with the fetched bills
        });
      }
    } catch (e) {
      // You can also set bills to an empty list in case of error to prevent null
      if (mounted) {
        setState(() {
          admin = false;
        });
      }
    }
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
                "INFORMATION",
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
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Refresh(
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.only(top: 74),
                child: Column(
                  spacing: 50,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 25),
                      height: 270,
                      width: 270,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(1000),
                        border: Border.all(color: Colors.red[700]!, width: 2),
                      ),
                      child: Image(image: AssetImage("assets/logo-info.png")),
                    ),
                    Center(
                      child: Text(
                        "TRANSCENDENCE 2025",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 70),
              Container(
                padding: EdgeInsets.only(left: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Text(
                      "VERSION: 12.K34.M681.K402.K155455",
                      style: TextStyle(fontSize: 17),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Developed By: T Roshan Pramod"),
                        Text("Development Support: Pratyaksh Mehrotra"),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              if (admin) ...[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                AdminPanel(currentUser: widget.currentUser),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 40,
                      right: 40,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      "Admin Panel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
