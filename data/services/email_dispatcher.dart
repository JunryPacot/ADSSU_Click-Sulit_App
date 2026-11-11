import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/campus_constants.dart';
import 'mailer/smtp_mailer.dart';

class EmailDispatcher {
  EmailDispatcher._();

  /// Dispatches the real 6-digit OTP code to the recipient's email address.
  /// Uses direct Gmail SMTP (on Mobile/Desktop) or HTTPS Webhook (on Web/Mobile).
  static Future<bool> sendOtpEmail({
    required String recipient,
    required String code,
  }) async {
    final cleanRecipient = recipient.trim().toLowerCase();
    final subject = 'Your ADSSU Click & Sulit Verification Code: $code';

    final textContent = '''
Hello ADSSUnian!

Your confidential 6-digit verification code is: $code

This verification code is valid for 15 minutes.
For your security and privacy, never share this code with anyone. ADSSU staff will never ask for your verification code.

If you did not request this verification, please disregard this email.

--
ADSSU Click & Sulit
Agusan del Sur State University
Campus Circular Economy & Peer-to-Peer Exchange
''';

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ADSSU Click & Sulit Verification Code</title>
</head>
<body style="margin: 0; padding: 0; background-color: #F8F9FA; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color: #F8F9FA; padding: 30px 15px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" style="max-width: 520px; background-color: #FFFFFF; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 16px rgba(0,0,0,0.06); border: 1px solid #E2E8F0;" cellspacing="0" cellpadding="0">
          <!-- Header Banner -->
          <tr>
            <td style="background-color: #0E4D2B; padding: 28px 24px; text-align: center;">
              <h1 style="color: #FFFFFF; margin: 0; font-size: 22px; font-weight: 700; letter-spacing: 0.5px;">
                ADSSU Click & Sulit
              </h1>
              <p style="color: #E2F0D9; margin: 6px 0 0 0; font-size: 13px; font-weight: 400;">
                Agusan del Sur State University Student Exchange
              </p>
            </td>
          </tr>
          
          <!-- Body Content -->
          <tr>
            <td style="padding: 32px 28px;">
              <h2 style="color: #1F2A22; font-size: 18px; margin: 0 0 12px 0; font-weight: 600;">
                Email Verification Code
              </h2>
              <p style="color: #4A5568; font-size: 14px; line-height: 1.6; margin: 0 0 24px 0;">
                Hello ADSSUnian! To ensure account security and verify that you are the rightful owner of this email address, please use the 6-digit one-time passcode below:
              </p>

              <!-- OTP Code Display Card -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin: 20px 0;">
                <tr>
                  <td align="center">
                    <div style="background-color: #E8F5E9; border: 2px dashed #2E7D4F; border-radius: 12px; padding: 18px 24px; display: inline-block;">
                      <span style="font-family: 'Courier New', Courier, monospace; font-size: 34px; font-weight: 800; letter-spacing: 8px; color: #0E4D2B;">
                        $code
                      </span>
                    </div>
                  </td>
                </tr>
              </table>

              <!-- Notice and Expiry -->
              <p style="color: #718096; font-size: 12px; line-height: 1.5; margin: 16px 0 0 0; text-align: center;">
                &#9201; This code expires in <strong>15 minutes</strong>.<br>
                Please do not share this passcode with anyone.
              </p>

              <hr style="border: none; border-top: 1px solid #E2E8F0; margin: 24px 0;">

              <p style="color: #A0AEC0; font-size: 11px; line-height: 1.5; margin: 0;">
                <strong>Privacy Notice:</strong> This email was dispatched to <em>$cleanRecipient</em> as part of account verification on ADSSU Click & Sulit. If you did not make this request, you can safely ignore this email.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color: #F7FAFC; padding: 16px 24px; text-align: center; border-top: 1px solid #E2E8F0;">
              <p style="color: #718096; font-size: 11px; margin: 0;">
                &copy; ${DateTime.now().year} Agusan del Sur State University &bull; Click & Sulit Platform
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';

    bool isDelivered = false;

    // 1. Try direct Gmail SMTP (works on Android APK / Desktop)
    if (!kIsWeb) {
      try {
        isDelivered = await sendSmtpEmail(
          recipient: cleanRecipient,
          subject: subject,
          htmlContent: htmlContent,
          textContent: textContent,
        );
      } catch (e) {
        debugPrint('[EmailDispatcher] SMTP attempt error: $e');
      }
    }

    // 2. If not delivered yet (or running on Web), try HTTPS Webhook (e.g. Google Apps Script)
    if (!isDelivered && CampusConstants.emailWebhookUrl.trim().isNotEmpty) {
      try {
        debugPrint('[EmailDispatcher] Sending via HTTPS Webhook to ${CampusConstants.emailWebhookUrl}...');
        final res = await http.post(
          Uri.parse(CampusConstants.emailWebhookUrl.trim()),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'to': cleanRecipient,
            'subject': subject,
            'html': htmlContent,
            'text': textContent,
            'code': code,
          }),
        );
        if (res.statusCode >= 200 && res.statusCode < 300) {
          debugPrint('[EmailDispatcher] Webhook delivered successfully! Status: ${res.statusCode}');
          isDelivered = true;
        } else {
          debugPrint('[EmailDispatcher] Webhook returned status: ${res.statusCode} ${res.body}');
        }
      } catch (e) {
        debugPrint('[EmailDispatcher] Webhook post error: $e');
      }
    }

    return isDelivered;
  }
}

