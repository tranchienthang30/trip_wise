import '../models/payment_success.dart';
import 'api_client.dart';

class PaymentsApi {
  Future<PaymentSuccess> fetchPaymentSuccess({
    String? bookingId,
    String? paymentId,
  }) async {
    final path = bookingId == null || bookingId.isEmpty
        ? '/payments/success'
        : '/payments/success/$bookingId';
    final response = await ApiClient.instance.dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {
        if (paymentId != null && paymentId.isNotEmpty) 'paymentId': paymentId,
      },
    );

    final data = response.data;
    if (data == null) {
      throw StateError('Empty response from $path');
    }

    return PaymentSuccess.fromJson(data);
  }
}
