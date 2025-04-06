import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

class EmailService {
  static int generateRandomOTP() {
    Random random = Random();
    return 100000 + random.nextInt(900000); // Ensures a 6-digit number
  }

  static Future<dynamic> sendEmail(String email) async {
    String username = "transcendence@sjbhs.edu.in";
    String password = "uzrs romk brhx lwcf";

    final smtpServer = gmail(username, password);
    int otp = generateRandomOTP();

    final message =
        Message()
          ..from = Address(username, "Transcendence Bills")
          ..recipients.add(email)
          ..subject = "Verify your Email"
          ..text =
              "The OTP for your account in the Transcendence billing app is, $otp";

    try {
      await send(message, smtpServer);
      return otp;
    } catch (e) {
      return e.toString();
    }
  }
}
