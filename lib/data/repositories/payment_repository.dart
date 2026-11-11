import '../models/payment_model.dart';

abstract class PaymentRepository {
  Stream<List<PaymentModel>> streamPayments();
  Future<void> submitPayment(PaymentModel payment);
  Future<void> approvePayment(String paymentId);
  Future<void> rejectPayment(String paymentId, String reason);
}

