sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class PaymentException extends AppException {
  const PaymentException(super.message);
}

class ConversationException extends AppException {
  const ConversationException(super.message);
}

class SubscriptionRequiredException extends AppException {
  const SubscriptionRequiredException() : super('Subscription required');
}
