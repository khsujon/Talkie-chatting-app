import 'package:googleapis_auth/auth_io.dart';
import 'dart:io'; // For file handling (if you load the service account JSON from a file)

class GetServerKey {
  Future<String> getServerKeyToken() async {
    // Define the required OAuth scopes
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    // Load the service account credentials from a JSON file or map
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        //your server key
      }),
      scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    // Return the obtained token
    return accessServerKey;
  }
}
