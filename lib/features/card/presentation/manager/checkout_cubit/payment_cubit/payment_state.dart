// lib/payment/payment_state.dart
import 'package:equatable/equatable.dart';

enum PaymentResultStatus { completed, error, canceled }

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentReady extends PaymentState {
  final String html; // HTML المحتوى اللي هيتحمل في WebView
  const PaymentReady(this.html);
  @override
  List<Object?> get props => [html];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentResult extends PaymentState {
  final PaymentResultStatus status;
  final Map<String, dynamic>? data; // لو عايز ترجع بيانات من SDK
  const PaymentResult({required this.status, this.data});
  @override
  List<Object?> get props => [status, data];
}
