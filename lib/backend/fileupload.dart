import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as p;
import 'driveapi.dart';

class FileUpload {
  DriveApi api = DriveApi();
  String getFileExtension(File file) {
    return p.extension(file.path); // Returns ".jpg", ".png", etc.
  }

  Future<String?> uploadfile(
    String email,
    String date,
    String name,
    double amount,
    File image,
    String category,
  ) async {
    try {
      final driveApi = await api.getDriveApi();
      if (driveApi == null) {
        return "Authentication failed";
      }

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;
        Map<String, dynamic> userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        List parts = [
          name.replaceAll(" ", "_"),
          date,
          amount.toString(),
          category.substring(0, 3),
        ];
        String billname = parts.join("_");
        String ext = getFileExtension(image);
        String? folderId = userData['folderid'];
        String newfilename = "$billname.$ext";

        // Rename the file before uploading

        try {
          if (folderId == null) {
            return "Unable to create or find folder";
          }
          var media = drive.Media(image.openRead(), image.lengthSync());
          var driveFile =
              drive.File()
                ..name = newfilename
                ..parents = [folderId];

          await driveApi.files.create(driveFile, uploadMedia: media);
        } catch (e) {
          return e.toString();
        }

        FirebaseFirestore.instance.collection('users').doc(docId).update({
          'bills': FieldValue.arrayUnion([
            {
              "billname": billname,
              'amount': amount,
              'issuedOn': date,
              'category': category,
            },
          ]),
        });
        return null;
      } else {
        return "Unable to upload";
      }
    } catch (e) {
      return e.toString();
    }
  }
}
