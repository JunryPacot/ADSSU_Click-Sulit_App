import '../models/request_model.dart';

abstract class RequestRepository {
  Stream<List<RequestModel>> streamUserRequests(String userId);
  Future<void> createRequest(RequestModel request);
  Future<void> updateRequestStatus(String requestId, String status);
  Future<void> completeTransaction(String requestId);
}

