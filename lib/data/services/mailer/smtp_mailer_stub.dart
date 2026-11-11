import 'package:flutter/foundation.dart';

Future<bool> sendSmtpEmail({
  required String recipient,
  required String subject,
  required String htmlContent,
  required String textContent,
}) async {
  debugPrint('[SMTP Mailer] Raw socket SMTP is not supported on Web. Use HTTP Webhook / Apps Script.');
  return false;
}

