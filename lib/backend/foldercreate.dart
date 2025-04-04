import 'package:googleapis/drive/v3.dart' as drive;
import 'driveapi.dart';

class CreateFolder {
  Future<String?> getorcreateUserFolder(String userId) async {
    DriveApi api = DriveApi();

    try {
      final driveApi = await api.getDriveApi();
      if (driveApi == null) {
        return "Authentication failed";
      }

      // The ID of the shared folder where all user folders should be created
      String sharedFolderId = "1YBjZr-y3AVvHIw-xVKr717ajFYgEDyd2";

      // Check if the folder already exists
      var query =
          "name='$userId' and '$sharedFolderId' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false";
      var response = await driveApi.files.list(q: query);

      if (response.files!.isNotEmpty) {
        return response.files!.first.id; // Folder already exists, return ID
      }

      // Create a new folder for the user
      var folder =
          drive.File()
            ..name = userId
            ..mimeType = "application/vnd.google-apps.folder"
            ..parents = [sharedFolderId];

      var createdFolder = await driveApi.files.create(folder);
      return createdFolder.id; // Return the new folder ID
    } catch (e) {
      return null;
    }
  }
}
