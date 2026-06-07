import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../services/payment_service.dart';
import 'auth_provider.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) => PaymentService());

final subscriptionProvider = FutureProvider<Subscription?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(paymentServiceProvider).getActiveSubscription(user.id);
});

final hasSubscriptionProvider = FutureProvider<bool>((ref) async {
  final sub = await ref.watch(subscriptionProvider.future);
  return sub?.isActive ?? false;
});
