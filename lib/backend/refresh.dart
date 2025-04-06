import 'package:bills/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

typedef InfoCallback =
    void Function(String? name, List<dynamic>? bills, double? amount);

class Refresh extends StatefulWidget {
  final Widget child;
  const Refresh({super.key, required this.child});

  @override
  State<Refresh> createState() => RefreshState();
}

class RefreshState extends State<Refresh> {
  @override
  void initState() {
    super.initState();
    // Call the async method in a separate function
    _refresh();
  }

  Future<void> _refresh() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (!mounted) return;
      if (user == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: _refresh, child: widget.child);
  }
}
