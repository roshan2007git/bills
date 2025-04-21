import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;

class DriveApi {
  Future<drive.DriveApi?> getDriveApi() async {
    try {
      final serviceAccount = await rootBundle.loadString(
        "assets/bills-456018-f23ceb558311.json",
      );

      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);
      final client = await clientViaServiceAccount(credentials, [
        drive.DriveApi.driveScope,
      ]);

      return drive.DriveApi(client);
    } catch (e) {
      return null;
    }
  }
}
