import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;

class DriveApi {
  Future<drive.DriveApi?> getDriveApi() async {
    try {
      final serviceAccount = await rootBundle.loadString(
        "assets/bills-app-7e033-b14fd82cc3ac.json",
      );

      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);
      final client = await clientViaServiceAccount(credentials, [
        drive.DriveApi.driveFileScope,
      ]);

      return drive.DriveApi(client);
    } catch (e) {
      return null;
    }
  }
}
