import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/subscription.dart';

class PaymentService {
  final _client = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<Map<String, dynamic>> initiatePayment({
    required String userId,
    required String userName,
    required String userEmail,
    required String? userPhone,
  }) async {
    try {
      final paymentId = _uuid.v4();

      await _client.from('payments').insert({
        'id': paymentId,
        'user_id': userId,
        'amount_bdt': AppConstants.acceleratorPriceBDT,
        'status': 'pending',
      });

      final response = await _client.functions.invoke(
        'initiate-payment',
        body: {
          'paymentId': paymentId,
          'userId': userId,
          'amountPaisa': AppConstants.acceleratorPriceBDT * 100,
          'customerName': userName,
          'customerEmail': userEmail,
          'customerPhone': userPhone ?? '',
        },
      );

      if (response.data == null) throw PaymentException('Payment initiation failed');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw PaymentException(e.toString());
    }
  }

  Future<Subscription?> getActiveSubscription(String userId) async {
    try {
      final data = await _client
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      return Subscription.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasActiveSubscription(String userId) async {
    final sub = await getActiveSubscription(userId);
    return sub?.isActive ?? false;
  }

  Future<void> checkPaymentStatus(String paymentId) async {
    final data = await _client
        .from('payments')
        .select('status')
        .eq('id', paymentId)
        .single();

    if (data['status'] != 'success') {
      throw PaymentException('Payment not completed');
    }
  }
}
