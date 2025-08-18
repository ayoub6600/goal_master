part of 'send_money_cubit.dart';

enum SendMoneyStatus { idle, loading, success, error }

class SendMoneyState extends Equatable {
  final String receiver; // رقم المستلم
  final String amount; // المبلغ كنص
  final SendMoneyStatus status; // حالة التنفيذ
  final String? errorMessage; // رسالة الخطأ (لو فيه)

  const SendMoneyState({
    this.receiver = '',
    this.amount = '',
    this.status = SendMoneyStatus.idle,
    this.errorMessage,
  });

  bool get isReceiverValid => receiver.trim().isNotEmpty;
  bool get isAmountValid {
    final v = double.tryParse(amount.trim());
    return v != null && v > 0;
  }

  // ده اللي بتستخدمه في SendMoneyView لتعطيل/تمكين الزر
  bool get isFormValid => isReceiverValid && isAmountValid;

  SendMoneyState copyWith({
    String? receiver,
    String? amount,
    SendMoneyStatus? status,
    String? errorMessage,
  }) {
    return SendMoneyState(
      receiver: receiver ?? this.receiver,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [receiver, amount, status, errorMessage];
}
