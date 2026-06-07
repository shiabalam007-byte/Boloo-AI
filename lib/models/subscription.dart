import 'package:flutter/foundation.dart';

enum SubscriptionStatus { pending, active, expired, cancelled }

@immutable
class Subscription {
  const Subscription({
    required this.id,
    required this.userId,
    required this.planType,
    required this.status,
    required this.amountBdt,
    this.startedAt,
    this.expiresAt,
    this.paymentId,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String planType;
  final SubscriptionStatus status;
  final int amountBdt;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final String? paymentId;
  final DateTime? createdAt;

  bool get isActive => status == SubscriptionStatus.active;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      planType: json['plan_type'] as String,
      status: _statusFromString(json['status'] as String?),
      amountBdt: json['amount_bdt'] as int? ?? 0,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      paymentId: json['payment_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  static SubscriptionStatus _statusFromString(String? s) {
    switch (s) {
      case 'active': return SubscriptionStatus.active;
      case 'expired': return SubscriptionStatus.expired;
      case 'cancelled': return SubscriptionStatus.cancelled;
      default: return SubscriptionStatus.pending;
    }
  }
}
