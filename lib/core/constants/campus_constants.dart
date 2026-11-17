class CampusConstants {
  CampusConstants._();

  static const String appTitle = 'ADSSU Click & Sulit';
  static const String appTagline = 'Click, Shop, Sulit!';
  static const String appDescription =
      'A Campus-Based Circular Economy and Peer-to-Peer Exchange Platform for Agusan del Sur State University';

  // Email Validation Rule
  static final RegExp emailRegex = RegExp(
    r'^[^@\s]+@adssu\.edu\.ph$',
    caseSensitive: false,
  );
  static final RegExp institutionalEmailRegex = emailRegex;

  static const String demoOtp = '123456';
  static const String demoStudentEmail = 'student@adssu.edu.ph';
  static const String demoAdminEmail = 'admin@adssu.edu.ph';
  static const String adminPassword = '5555jpacotgwapo';

  // Mailer & Email Dispatcher Configuration
  static const String smtpHost = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const String senderEmail = 'adssuclickandsulit@gmail.com';
  static const String senderName = 'ADSSU Click & Sulit Verification';
  
  // Gmail App Password (16 characters from https://myaccount.google.com/apppasswords)
  static String gmailAppPassword = 'zsslrpuuakvcinfx';

  // Google Apps Script or REST Webhook URL (works for Web and Mobile)
  static String emailWebhookUrl = '';

  // GCash Configuration
  static const String gcashNumber = '09706790894';
  static const String gcashDisplayNumber = '0970-679-0894';
  static const String gcashAccountName = 'ADSSU Click & Sulit';

  // Colleges (Exact names)
  static const List<String> colleges = [
    'College of Agriculture (CA)',
    'College of Arts and Sciences (CAS)',
    'College of Computing and Information Sciences (CCIS)',
    'College of Engineering and Industrial Technology (CEIT)',
    'College of Teacher Education (CTE)',
  ];

  // Meet-up Buildings (Constant list in exact specified order)
  static const List<String> meetUpBuildings = [
    'CA Building',
    'CAS Building',
    'CTE Building',
    'CEIT Building (note: CCIS and CEIT share this building)',
    'ICT Building',
    'Library',
    'ADSSU RIDE Building',
    'Multi-Purpose Building (MPB)',
    'Soil Laboratory / Agricultural Research Buildings',
    'ADSSU Socio-Cultural Center',
  ];

  // Categories
  static const List<String> categories = [
    'Books',
    'Uniforms',
    'Gadgets',
    'School Supplies',
    'Other Reusable Goods',
  ];

  // Item Types
  static const String typeSell = 'SELL';
  static const String typeExchange = 'EXCHANGE';
  static const String typeDonate = 'DONATE';

  // Fees and Membership
  static const double sellerMembershipFee = 50.0;
  static const double commissionRate = 0.03; // 3% commission on sales
  static const double sellerEarningsRate = 0.97; // 97% goes to seller

  // Boost Plans
  static const List<BoostPlan> boostPlans = [
    BoostPlan(name: '1 Day', price: 10.0, durationDays: 1),
    BoostPlan(name: '3 Days', price: 25.0, durationDays: 3),
    BoostPlan(name: '1 Week', price: 50.0, durationDays: 7),
  ];
}

class BoostPlan {
  final String name;
  final double price;
  final int durationDays;

  const BoostPlan({
    required this.name,
    required this.price,
    required this.durationDays,
  });
}

