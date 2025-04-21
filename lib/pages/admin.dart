import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:bills/backend/driveapi.dart';
import 'package:bills/backend/refresh.dart';
import 'package:bills/pages/directory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class AdminPanel extends StatefulWidget {
  final User currentUser;
  const AdminPanel({super.key, required this.currentUser});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "ADMIN PANEL",
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;

              Map<String, double> cate = {
                'Logistics': 0,
                'Hospitality': 0,
                'Tech and Media': 0,
                'Decor': 0,
                'Events': 0,
                'Ceremonies': 0,
                'Registrations': 0,
                'Security': 0,
                'Marketing': 0,
              };

              getTotal() {
                for (int i = 0; i < users.length; i += 1) {
                  final user = users[i].data() as Map<String, dynamic>;
                  for (Map<String, dynamic> bill in user['bills']) {
                    String? category = bill['category'];
                    if (category != null && cate.containsKey(category)) {
                      double current = cate[category] ?? 0;
                      cate[category] = current + (bill['amount'] ?? 0);
                    }
                  }
                }

                // You only need to call setState once after the loop
                setState(() {});
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 20,
                    ),
                    child: Container(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.black,
                      ),
                      child: TextButton(
                        onPressed: () {
                          getTotal();
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => TotalAmount(catlist: cate),
                            ),
                          );
                        },
                        child: Text(
                          "View Grand Total",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user =
                            users[index].data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => UserInfo(
                                      userdata: user,
                                      currentUser: widget.currentUser,
                                    ),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(user['name'] ?? 'WHO IS THIS?'),
                            subtitle: Text(user['username'] ?? 'WHO IS THIS?'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 7,
                              children: [
                                user['isApproved'] == true
                                    ? Text(
                                      "Approved",
                                      style: TextStyle(color: Colors.white),
                                    )
                                    : TextButton(
                                      onPressed: () async {
                                        final docId = users[index].id;
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(docId)
                                            .update({'isApproved': true});
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 7,
                                          horizontal: 17,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          "Approve",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                user['isAdmin'] == true
                                    ? Icon(Icons.verified, color: Colors.green)
                                    : Icon(Icons.person),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class UserInfo extends StatefulWidget {
  final Map<String, dynamic> userdata;
  final User currentUser;
  const UserInfo({
    super.key,
    required this.userdata,
    required this.currentUser,
  });

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  void initState() {
    super.initState();
    _getBills();
  }

  DriveApi api = DriveApi();

  double amount = 0;
  int totalBills = 0;

  void _getBills() {
    for (Map<String, dynamic> bill in widget.userdata['bills']) {
      amount += bill['amount'];
      totalBills += 1;
    }
  }

  Future<bool> deleteUserFolder(String folderId) async {
    final driveApi = await api.getDriveApi(); // from your DriveApi class
    if (driveApi == null) {
      return false;
    }

    try {
      await driveApi.files.delete(folderId);
      return true;
    } catch (e) {
      setState(() {
        error = e.toString();
        showerror = true;
      });
      return false;
    }
  }

  Future<bool> deleteUserCollection(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      setState(() {
        error = e.toString();
        showerror = true;
      });
      return false;
    }
  }

  Future<void> deleteUser() async {
    final docId = widget.userdata['uid'];
    final folderId = widget.userdata['folderid'];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      bool folderDeleted = await deleteUserFolder(folderId);
      bool firestoreDeleted = await deleteUserCollection(docId);

      if (!folderDeleted || !firestoreDeleted) {
        setState(() {
          error = 'Something went wrong while deleting user data.';
          showerror = true;
        });
      }
      if (!mounted) return;
    } catch (e) {
      setState(() {
        error = e.toString();
        showerror = true;
      });
    } finally {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  String? error;
  bool showerror = false;

  void hide() {
    setState(() {
      showerror = false;
    });
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
                "User Information",
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
          FocusManager.instance.primaryFocus?.unfocus();
          hide();
        },
        child: Refresh(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Container(
                    alignment: Alignment.topLeft,
                    width: MediaQuery.of(context).size.width * 0.95,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 15,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name: ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              widget.userdata['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Username: ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              widget.userdata['username'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email ID: ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                widget.userdata['email'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Amount : ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              "₹${amount.toString()}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total bills : ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              totalBills.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.userdata['bills'].isNotEmpty) ...[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ViewBills(
                              bills: widget.userdata['bills'],
                              name: widget.userdata['name'],
                              folderid: widget.userdata['folderid'],
                              uid: widget.userdata['uid'],
                              currentUser: widget.currentUser,
                            ),
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
                      "View Bills",
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
              if (!widget.userdata['isAdmin']) ...[
                TextButton(
                  onPressed: () async {
                    final docId = widget.userdata['uid'];
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(docId)
                          .update({'isAdmin': true});
                    } catch (e) {
                      setState(() {
                        error = e.toString();
                      });
                    } finally {
                      setState(() {
                        error = null;
                      });
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    }
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
                      "Make Admin",
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
              if (widget.userdata['isAdmin']) ...[
                TextButton(
                  onPressed: () async {
                    final docId = widget.userdata['uid'];
                    User user = FirebaseAuth.instance.currentUser!;
                    String uid = user.uid;
                    final data =
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(uid)
                            .get();
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(docId)
                          .update({'isAdmin': false});
                    } catch (e) {
                      setState(() {
                        error = e.toString();
                      });
                    } finally {
                      setState(() {
                        error = null;
                      });
                      if (mounted) {
                        if (data['username'] == widget.userdata['username']) {
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => Directory(
                                    currentUser: widget.currentUser,
                                  ),
                            ),
                          );
                        } else {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      }
                    }
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
                      "Remove Admin",
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
              if (widget.userdata['isApproved']) ...[
                TextButton(
                  onPressed: () async {
                    final docId = widget.userdata['uid'];
                    User user = FirebaseAuth.instance.currentUser!;
                    String uid = user.uid;
                    final data =
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(uid)
                            .get();
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(docId)
                          .update({'isApproved': false});
                    } catch (e) {
                      setState(() {
                        error = e.toString();
                      });
                    } finally {
                      setState(() {
                        error = null;
                      });
                      if (mounted) {
                        if (data['username'] == widget.userdata['username']) {
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => Directory(
                                    currentUser: widget.currentUser,
                                  ),
                            ),
                          );
                        } else {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      }
                    }
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
                      "Disapprove",
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
              TextButton(
                onPressed: () {
                  deleteUser();
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
                    "Delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
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
            ],
          ),
        ),
      ),
    );
  }
}

class TotalAmount extends StatefulWidget {
  final Map<String, double> catlist;
  const TotalAmount({super.key, required this.catlist});

  @override
  State<TotalAmount> createState() => _TotalAmountState();
}

class _TotalAmountState extends State<TotalAmount> {
  double amount = 0;

  void getamount() {
    widget.catlist.forEach((key, value) {
      amount += value;
    });
  }

  @override
  void initState() {
    super.initState();
    getamount();
  }

  @override
  Widget build(BuildContext context) {
    final cateEntries = widget.catlist.entries.toList();
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
                "GRAND TOTAL",
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
      body: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: cateEntries.length,
                  itemBuilder: (context, index) {
                    final entry = cateEntries[index];
                    return ListTile(
                      visualDensity: VisualDensity(vertical: -4),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        entry.key,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      subtitle: Text("₹${entry.value.toString()}"),
                    );
                  },
                ),
                SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Grand Total",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "₹${amount.toString()}",
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ViewBills extends StatefulWidget {
  final List bills;
  final String name;
  final String folderid;
  final String uid;
  final User currentUser;
  const ViewBills({
    super.key,
    required this.bills,
    required this.name,
    required this.folderid,
    required this.uid,
    required this.currentUser,
  });

  @override
  State<ViewBills> createState() => _ViewBillsState();
}

class _ViewBillsState extends State<ViewBills> {
  DriveApi api = DriveApi();
  String? error;
  bool showerror = false;

  String name(String input) {
    int index = input.indexOf('_');
    if (index == -1) return input; // No underscore found
    return input.substring(0, index);
  }

  Future<List<drive.File>> listFilesInFolder(
    auth.AuthClient client,
    String folderId,
  ) async {
    var driveApi = drive.DriveApi(client);

    // List files in the folder by its ID
    var fileList = await driveApi.files.list(
      q: "'$folderId' in parents",
      $fields: "files(id, name)",
    );

    return fileList.files ?? [];
  }

  Future<void> deleteFileByName(
    auth.AuthClient client,
    String folderId,
    String fileName,
  ) async {
    var driveApi = drive.DriveApi(client);

    // List files to find the file by name
    var files = await listFilesInFolder(client, folderId);

    // Find the file by its name
    for (var file in files) {
      if (file.name != null &&
          (file.name == "$fileName..jpg" ||
              file.name == "$fileName..png" ||
              file.name == "$fileName.png" ||
              file.name == "$fileName.jpg" ||
              file.name == "$fileName..jpeg" ||
              file.name == "$fileName.jpeg")) {
        // Delete the file by its ID
        await driveApi.files.delete(file.id!);
        break;
      } else {
        setState(() {
          error = "Unable to find or delete file";
          showerror = true;
        });
      }
    }
  }

  Future<void> deleteFileFromFolder(String fileName) async {
    var client = await api.getAuthenticatedClient(); // Get authenticated client

    try {
      await deleteFileByName(client, widget.folderid, fileName);
    } catch (e) {
      setState(() {
        error = e.toString();
        showerror = true;
      });
    }
  }

  Future<void> deleteBillByName(String name) async {
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid);

    try {
      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        List<dynamic> bills = docSnapshot.data()?['bills'] ?? [];
        // Find and remove the bill with the matching billName
        bills.removeWhere((bill) => bill is Map && bill['billname'] == name);

        await userDocRef.update({'bills': bills});
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        showerror = true;
      });
    }
  }

  void hide() {
    setState(() {
      showerror = false;
      error = null;
    });
  }

  Future<void> deleteBill(String name) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await deleteBillByName(name);
      await deleteFileFromFolder(name);
      if (!mounted) return;
    } catch (e) {
      setState(() {
        error = e.toString();
        showerror = true;
      });
    } finally {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminPanel(currentUser: widget.currentUser),
        ),
      );
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
                "${widget.name}'s Bills",
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
          hide();
        },
        child: Center(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: showerror ? 60 : 40,
                child: Text(
                  (showerror) ? error! : "",
                  style: TextStyle(color: Colors.red[600]),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.74,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.bills.length,
                  itemBuilder: (context, index) {
                    final bill = widget.bills[index];
                    return ListTile(
                      title: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "NAME: ${name(bill['billname'])}",
                                  overflow: TextOverflow.visible,
                                  maxLines: null,
                                ),
                                Text(
                                  "AMOUNT: ${bill['amount']}",
                                  overflow: TextOverflow.visible,
                                  maxLines: null,
                                ),
                                Text(
                                  "DATE ISSUED: ${bill['issuedOn']}",
                                  overflow: TextOverflow.visible,
                                  maxLines: null,
                                ),
                                Text(
                                  "CATEGORY: ${bill['category']}",
                                  overflow: TextOverflow.visible,
                                  maxLines: null,
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                deleteBill(bill['billname']);
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
