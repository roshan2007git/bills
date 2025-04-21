import 'dart:io';
import 'package:bills/backend/fileupload.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bills/backend/refresh.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  const Upload({super.key, required this.currentUser});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  String? errorName;
  String? errorAmount;
  String? errorDate;
  String? errorUpload;
  String? category;

  List<String> items = [
    'Logistics',
    'Hospitality',
    'Tech and Media',
    'Decor',
    'Events',
    'Ceremonies',
    'Registrations',
    'Security',
    'Marketing',
  ];

  void _errors() {
    if (_dateController.text.isEmpty) {
      setState(() {
        errorDate = "Date Required";
      });
    } else {
      setState(() {
        errorDate = null;
      });
    }

    if (_nameController.text.isEmpty) {
      setState(() {
        errorName = "name Required";
      });
    } else {
      setState(() {
        errorName = null;
      });
    }

    if (_amountController.text.isEmpty) {
      setState(() {
        errorAmount = "Date Required";
      });
    } else {
      setState(() {
        errorAmount = null;
      });
    }

    if (image == null) {
      setState(() {
        errorUpload = "Image Required";
      });
    } else {
      setState(() {
        errorUpload = null;
      });
    }
  }

  bool check() {
    _errors();
    if (errorAmount == null &&
        errorName == null &&
        errorDate == null &&
        errorUpload == null) {
      return true;
    } else {
      return false;
    }
  }

  String folderID =
      "https://drive.google.com/drive/folders/1YBjZr-y3AVvHIw-xVKr717ajFYgEDyd2";

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    email = widget.currentUser.email;
    _nameController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _nameController.dispose();
    _amountController.dispose();
  }

  Future<void> _imagePicker() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final uploadedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      setState(() {
        image = File(uploadedImage!.path);
      });
    } catch (e) {
      setState(() {
        if (mounted) Navigator.of(context).pop();
        error = e.toString();
      });
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  File? image;
  String? error;

  Future<void> _datepicker() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2026),
    );
    if (date != null) {
      setState(() {
        _dateController.text = date.toString().split(" ")[0];
      });
    }
  }

  String? email;

  FileUpload upload = FileUpload();

  Future<void> _upload(String date, String name, double amount) async {
    bool c = check();
    if (email == null || c == false) {
      return;
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        await upload.uploadfile(email!, date, name, amount, image!, category!);
      } catch (e) {
        setState(() {
          error = e.toString();
        });
      } finally {
        if (mounted && error == null) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _nameController.text = "";
      _amountController.text = "";
      _dateController.text = "";
      image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Upload Bill",
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
      body: Refresh(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Container(
              padding: EdgeInsets.only(top: 40, right: 35, left: 35),
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
                        GestureDetector(
                          onTap: () {
                            _imagePicker();
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              child: Center(
                                child:
                                    image != null
                                        ? Image.file(image!)
                                        : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          spacing: 4,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              "UPLOAD",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          ),
                        ),
                        if (errorUpload != null) ...[
                          Text(
                            errorUpload!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ],
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            label: Text("Name"),
                            errorText: errorName,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        TextField(
                          controller: _amountController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$'),
                            ),
                          ],
                          decoration: InputDecoration(
                            label: Text("Amount"),
                            prefixIcon: Icon(Icons.currency_rupee),
                            errorText: errorAmount,
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        TextField(
                          controller: _dateController,
                          onTap: () {
                            _datepicker();
                          },
                          decoration: InputDecoration(
                            label: Text("Date Issued"),
                            prefixIcon: Icon(Icons.calendar_today),
                            errorText: errorDate,
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: DropdownButton<String>(
                              value: category,
                              hint: Text(
                                "Category",
                                style: TextStyle(color: Colors.white70),
                              ),
                              icon: Icon(Icons.arrow_drop_down),
                              isExpanded:
                                  true, // 👈 Important! Makes the button fill the width
                              elevation: 16,
                              onChanged: (String? newValue) {
                                setState(() {
                                  category = newValue;
                                });
                              },
                              items:
                                  items.map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                        if (error != null) ...[
                          Text(
                            error!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        Container(padding: EdgeInsets.all(4)),
                        Column(
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
                                  check()
                                      ? _upload(
                                        _dateController.text,
                                        _nameController.text,
                                        double.parse(_amountController.text),
                                      )
                                      : _errors();
                                },
                                child: Text(
                                  "UPLOAD",
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
        ),
      ),
    );
  }
}
