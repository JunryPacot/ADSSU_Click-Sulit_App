import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../../core/constants/campus_constants.dart';

Future<bool> sendSmtpEmail({
  required String recipient,
  required String subject,
  required String htmlContent,
  required String textContent,
}) async {
  final appPassword = CampusConstants.gmailAppPassword.trim();
  final senderEmail = CampusConstants.senderEmail.trim();

  if (appPassword.isEmpty) {
    debugPrint('[SMTP Mailer IO] No Gmail App Password configured in CampusConstants.gmailAppPassword.');
    return false;
  }

  try {
    debugPrint('[SMTP Mailer IO] Sending SMTP email via smtp.gmail.com to $recipient from $senderEmail...');
    final smtpServer = gmail(senderEmail, appPassword);
    final message = Message()
      ..from = Address(senderEmail, CampusConstants.senderName)
      ..recipients.add(recipient)
      ..subject = subject
      ..text = textContent
      ..html = htmlContent;

    final sendReport = await send(message, smtpServer);
    debugPrint('[SMTP Mailer IO] Email successfully sent! Report: $sendReport');
    return true;
  } catch (e) {
    debugPrint('[SMTP Mailer IO] SMTP send error: $e');
    return false;
  }
}

