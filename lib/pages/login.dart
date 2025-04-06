import 'package:bills/backend/usercall.dart';
import 'package:bills/backend/customlogin.dart';
import 'package:bills/pages/directory.dart';
import 'package:bills/pages/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? error;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Call the AuthService to perform sign-in
    CustomLogin login = CustomLogin();
    UserCredential? userCredential = await login.signInWithUsernameAndPassword(
      username,
      password,
    );

    if (userCredential != null) {
      User customUser = userCredential.user!;

      CallUser check = CallUser();
      bool isApproved = await check.approved(customUser);

      if (!mounted) return;
      if (isApproved) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Directory(currentUser: customUser),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Approval(customUser: customUser),
          ),
        );
      }
    } else {
      setState(() {
        error = 'Sign-in failed. Please check your Email and Password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        title: Center(
          child: Text(
            "LOGIN",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          padding: EdgeInsets.only(right: 35, left: 35, top: 120),
          color: Colors.grey[900],
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ListView(
              children: [
                SizedBox(height: 80),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(label: Text("Username")),
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(label: Text("Password")),
                      style: TextStyle(color: Colors.white),
                      obscureText: true,
                    ),
                    if (error != null) ...[
                      Text(
                        error!,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    Container(padding: EdgeInsets.all(10)),
                    Column(
                      spacing: 20,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "If you don't have an account, ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Register(),
                                  ),
                                );
                              },
                              child: Text(
                                "register",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
                              _signIn();
                            },
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Approval extends StatefulWidget {
  final User customUser;
  const Approval({super.key, required this.customUser});

  @override
  State<Approval> createState() => _ApprovalState();
}

class _ApprovalState extends State<Approval> {
  void retry() async {
    CallUser check = CallUser();

    bool isApproved = await check.approved(widget.customUser);

    if (isApproved) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Directory(currentUser: widget.customUser),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        title: Center(
          child: Text(
            "APPROVAL",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          color: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 30,
            children: [
              Column(
                children: [
                  Center(
                    child: Text(
                      "Your account has been created",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Text(
                      "Waiting for Admin Approval",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  retry();
                },
                child: Container(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Retry",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.refresh, color: Colors.white, size: 17),
                    ],
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
