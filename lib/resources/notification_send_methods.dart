import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/fcm/v1.dart' as fcm;

class FirebaseService {
  final String projectId = 'jldsss-customer-app'; // Replace with your Firebase project ID

  Future<String> _getAccessToken() async {
    // print('HEREEEEEEEEEEEEEEEEEEEEEE\n: ${dotenv.env}');
    final accountCredentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": projectId,
      "private_key_id": dotenv.env['private_key_id'],
      "private_key": dotenv.env['private_key']!.replaceAll('\\n', '\n'),
      "client_email": dotenv.env['client_email'],
      "client_id": dotenv.env['client_id'],
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": dotenv.env['client_x509_cert_url']
    });

    final scopes = [fcm.FirebaseCloudMessagingApi.cloudPlatformScope];
    final client = await clientViaServiceAccount(accountCredentials, scopes);
    return client.credentials.accessToken.data;
  }

  Future<void> sendOrderPlacedNotification(
    String restaurantToken,
    String title,
    String body,
    String orderId,
  ) async {
    await _sendNotification(
      restaurantToken,
      title,
      body,
      {'type': 'customer_order', 'orderId': orderId},
    );
  }

  // Future<void> sendOfferNotification(String customerToken, String itemName, String offerDetails) async {
  //   await _sendNotification(
  //     customerToken,
  //     'New Offer!',
  //     'Special offer on $itemName: $offerDetails',
  //     {'type': 'offer', 'itemName': itemName},
  //   );
  // }

  Future<void> _sendNotification(
    String token,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    final accessToken = await _getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final message = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data,
      },
    };

    final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(message));
      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
