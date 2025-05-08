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
  String? passwordError;
  String? usernameError;
  bool showerror = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    showerror = false;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _hide() {
    setState(() {
      showerror = false;
    });
  }

  Future<void> _signIn() async {
    String? username = _usernameController.text;
    String? password = _passwordController.text;

    if (username == "" && password != "") {
      setState(() {
        usernameError = "Username Required";
        passwordError = "";
      });
    } else if (password == "" && username != "") {
      setState(() {
        passwordError = "Password Required";
        usernameError = "";
      });
    } else if (password == "" && username == "") {
      setState(() {
        passwordError = "Password Required";
        usernameError = "Username Required";
      });
    } else {
      setState(() {
        usernameError = "";
        passwordError = "";
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      CustomLogin login = CustomLogin();

      UserCredential? uc;

      try {
        UserCredential? userCredential = await login
            .signInWithUsernameAndPassword(username, password);
        uc = userCredential;
      } catch (e) {
        if (mounted) Navigator.pop(context);
        setState(() {
          error = e.toString();
          showerror = true;
        });
      } finally {
        if (uc != null) {
          User customUser = uc.user!;
          bool approved = false;
          CallUser check = CallUser();
          try {
            bool isApproved = await check.approved(customUser);
            approved = isApproved;
          } catch (e) {
            if (mounted) Navigator.pop(context);
            setState(() {
              error = e.toString();
              showerror = true;
            });
          } finally {
            if (mounted) {
              if (approved) {
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
              if (mounted) Navigator.pop(context);
              setState(() {
                error = 'An Error occurred';
                showerror = true;
              });
            }
          }
        } else {
          if (mounted) Navigator.pop(context);
          setState(() {
            error = 'Sign-in failed. Please check your Username and Password.';
            showerror = true;
          });
        }
      }
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
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          _hide();
        },
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
                      decoration: InputDecoration(
                        label: Text("Username"),
                        errorText: usernameError,
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (_) {
                        _hide();
                      },
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        label: Text("Password"),
                        errorText: passwordError,
                      ),
                      style: TextStyle(color: Colors.white),
                      obscureText: true,
                      onChanged: (_) {
                        _hide();
                      },
                    ),
                    if (error != null && showerror == true) ...[
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
  String? error;
  bool showerror = false;

  void check() => setState(() {
    showerror = false;
  });

  void retry() async {
    setState(() {
      showerror = false;
    });
    CallUser check = CallUser();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool isApproved = await check.approved(widget.customUser);
      if (isApproved) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Directory(currentUser: widget.customUser),
          ),
        );
      } else {
        if (mounted) Navigator.pop(context);
        setState(() {
          error = "Still Waiting for Approval";
          showerror = true;
        });
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() {
        error = e.toString();
        showerror = true;
      });
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
        onTap: () {
          check();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 70),
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
              if (error != null && showerror == true) ...[
                Text(
                  error!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text(
                  "Go back",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
