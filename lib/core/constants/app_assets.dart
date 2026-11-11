class AppAssets {
  AppAssets._();

  static const String logo = 'assets/images/logo.png';

  // Payment QR Codes
  static const String gcashQr50 = 'assets/images/gcash_membership_qr.png';
  static const String instapayQr10 = 'assets/images/instapay_booster_10.png';
  static const String instapayQr25 = 'assets/images/instapay_booster_25.png';

  /// Returns the correct QR code asset path for the given price.
  static String qrForAmount(double amount) {
    if (amount <= 10) return instapayQr10;
    if (amount <= 25) return instapayQr25;
    return gcashQr50;
  }

  /// Returns the payment provider label for the given price.
  static String providerForAmount(double amount) {
    if (amount <= 25) return 'InstaPay';
    return 'GCash';
  }
}

