// ignore_for_file: use_build_context_synchronously

import 'package:bills/backend/email.dart';
import 'package:bills/backend/foldercreate.dart';
import 'package:bills/backend/log.dart';
import 'package:bills/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

String? _otp;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _cPasswordController = TextEditingController();
  String? errorEmail;
  String? errorPassword;
  String? success;
  String? error;
  String? errorUsername;
  String? errorCPassword;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _cPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cPasswordController.dispose();
  }

  Future<void> _checkDupe() async {
    try {
      // Ensure the widget is still mounted before updating state
      if (!mounted) return;

      // Run both queries in parallel to improve performance
      var results = await Future.wait([
        FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: _usernameController.text)
            .limit(1)
            .get(),
        FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _emailController.text)
            .limit(1)
            .get(),
      ]);

      QuerySnapshot querySnapshot1 = results[0];
      QuerySnapshot querySnapshot2 = results[1];

      setState(() {
        errorUsername =
            querySnapshot1.docs.isNotEmpty ? "Username already exists" : null;
        errorEmail =
            querySnapshot2.docs.isNotEmpty ? "Email already in use" : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
      });
    }
  }

  Future<String?> register(
    String email,
    String password1,
    String password2,
  ) async {
    _validateEmail(email);
    _validatePassword(password1, password2);
    await _checkDupe();

    if (errorEmail == null &&
        errorPassword == null &&
        errorUsername == null &&
        errorCPassword == null) {
      try {
        dynamic result = await EmailService.sendEmail(email);
        if (result is int) {
          _otp = result.toString();
          return "Email Successfully Sent";
        } else {
          return result;
        }
      } catch (e) {
        return e.toString();
      }
    }
    return null;
  }

  bool isValidEmail(String email) {
    String emailPattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
    return RegExp(emailPattern).hasMatch(email);
  }

  void _validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        errorEmail = 'Email is required';
      } else if (!isValidEmail(email)) {
        errorEmail = 'Enter a valid email';
      } else {
        errorEmail = null;
      }
    });
  }

  void _validatePassword(String p1, String p2) {
    setState(() {
      final hasUppercase = p1.contains(RegExp(r'[A-Z]'));
      final hasNumber = p1.contains(RegExp(r'[0-9]'));

      if (p1.isEmpty || p2.isEmpty) {
        errorPassword = "Password cannot be empty";
        errorCPassword = "Please confirm your password";
      } else if (p1.length < 8) {
        errorPassword = "Password must be at least 8 characters";
      } else if (!hasUppercase) {
        errorPassword = "Password must contain at least one uppercase letter";
      } else if (!hasNumber) {
        errorPassword = "Password must contain at least one number";
      } else if (p1 != p2) {
        errorCPassword = "The passwords don't match";
      } else {
        errorPassword = null;
      }
    });
  }

  Future<void> _handleOTP(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String? result = await register(
        _emailController.text,
        _passwordController.text,
        _cPasswordController.text,
      );

      if (result == "Email Successfully Sent") {
        // Navigate only when registration is successful
        if (context.mounted) {
          final returnedData = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => Verify(
                    email: _emailController.text,
                    password: _passwordController.text,
                    username: _usernameController.text,
                    name: _nameController.text,
                  ),
            ), // Change to your page
          );

          if (returnedData != null) {
            _nameController.text = returnedData['name'] ?? '';
            _usernameController.text = returnedData['username'] ?? '';
            _emailController.text = returnedData['email'] ?? '';
            _passwordController.text = "";
            _cPasswordController.text = "";
            if (mounted) Navigator.pop(context);
          } else {
            if (mounted) Navigator.pop(context);
            setState(() {
              error = "An Error occurred, could't retrieve data";
            });
          }
        } else {
          if (mounted) Navigator.pop(context);
          setState(() {
            error = "An ERROR has occurred, Please try again later";
          });
        }
      } else if (result != null) {
        if (mounted) Navigator.pop(context);
        setState(() {
          error = result;
        });
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            "REGISTER",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          padding: EdgeInsets.only(top: 120, right: 35, left: 35),
          color: Colors.grey[900],
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 20,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(label: Text("Name")),
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        errorText: errorUsername,
                        label: Text("Username"),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        errorText: errorEmail,
                        label: Text("Email"),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        label: Text("Password"),
                        errorText: errorPassword,
                      ),
                      style: TextStyle(color: Colors.white),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _cPasswordController,
                      decoration: InputDecoration(
                        errorText: errorCPassword,
                        label: Text("Confirm Password"),
                      ),
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
                              "If you already have an account, ",
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
                                    builder: (context) => Login(),
                                  ),
                                );
                              },
                              child: Text(
                                "login",
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
                              _handleOTP(context);
                            },
                            child: Text(
                              "REGISTER",
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

class Verify extends StatefulWidget {
  final String email;
  final String password;
  final String username;
  final String name;
  const Verify({
    super.key,
    required this.email,
    required this.password,
    required this.username,
    required this.name,
  });

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String? error;
  bool errorotp = false;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (index) => TextEditingController());
    _focusNodes = List.generate(6, (index) => FocusNode());
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
  }

  Future<void> resendOTP() async {
    String? result = await EmailService.sendEmail(widget.email);
    if (result.runtimeType == int) {
      setState(() {
        error = result;
      });
    }
  }

  String getotp() {
    String otpIn = _otpControllers.map((controller) => controller.text).join();
    return otpIn;
  }

  void errorcheck() {
    errorotp = false;
  }

  Log log = Log();

  void handleVerification() async {
    CreateFolder folder = CreateFolder();
    if (_otp == getotp()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: widget.email,
              password: widget.password,
            );
        String uid = userCredential.user!.uid;
        String? folderid = await folder.getorcreateUserFolder(widget.username);
        if (folderid == null) {
          if (mounted) Navigator.pop(context);
          setState(() {
            error = "An Error has occurred. Please try a different username";
          });
          return;
        }
        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'uid': uid,
            'email': widget.email.toLowerCase(),
            'username': widget.username,
            'name': widget.name,
            'isApproved': false,
            'createdAt': FieldValue.serverTimestamp(),
            'bills': [],
            'folderid': folderid,
            'isAdmin': false,
            'password': widget.password,
          });
          log.logdata(widget.username, 'User Created Successfully');
        } catch (e) {
          log.logdata(widget.username, 'User Creation Failed');
          if (mounted) Navigator.pop(context);
          setState(() {
            error = e.toString();
          });
        } finally {
          _otp = null;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        }
        if (!mounted) return; // Check after async operations
      } catch (e) {
        if (mounted) Navigator.pop(context);
        setState(() {
          error = e.toString();
          errorotp = true;
        });
      }
    } else {
      setState(() {
        error = "Invalid OTP";
        errorotp = true;
      });
    }
  }

  void _moveToNextField(int index) {
    if (index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
  }

  void _moveToPreviousField(int index) {
    if (index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            "VERIFICATION",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          errorcheck();
        },
        child: Container(
          padding: EdgeInsets.only(right: 35, left: 35, bottom: 150),
          color: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Text(
                "A verification code has been sent to, ${widget.email}",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 40,
                      height: 50,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        focusNode: _focusNodes[index],
                        controller: _otpControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(counterText: ""),
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            errorotp = false;
                          });
                          if (value.isNotEmpty) {
                            // Move to the next field if there's input
                            _moveToNextField(index);
                          } else if (value.isEmpty && index > 0) {
                            // Move to the previous field if backspace is pressed
                            _moveToPreviousField(index);
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
              if (error != null && errorotp == true) ...[
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
                      GestureDetector(
                        onTap: () {
                          resendOTP();
                        },
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      handleVerification();
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
                        "Verify",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, {
                        'name': widget.name,
                        'username': widget.username,
                        'email': widget.email,
                      });
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
            ],
          ),
        ),
      ),
    );
  }
}
