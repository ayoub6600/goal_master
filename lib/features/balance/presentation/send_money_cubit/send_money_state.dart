part of 'send_money_cubit.dart';

enum SendMoneyStatus { idle, loading, success, error }

class SendMoneyState extends Equatable {
  final String receiver; // رقم المستلم
  final String amount; // المبلغ كنص
  final String password; // كلمة مرور الحساب، مطلوبة لكل تحويل
  final SendMoneyStatus status; // حالة التنفيذ
  final String? errorMessage; // رسالة الخطأ (لو فيه)

  const SendMoneyState({
    this.receiver = '',
    this.amount = '',
    this.password = '',
    this.status = SendMoneyStatus.idle,
    this.errorMessage,
  });

  bool get isReceiverValid => receiver.trim().isNotEmpty;
  bool get isAmountValid {
    final v = double.tryParse(amount.trim());
    return v != null && v > 0;
  }

  // ده اللي بتستخدمه في SendMoneyView لتعطيل/تمكين الزر
  bool get isFormValid =>
      isReceiverValid && isAmountValid && password.isNotEmpty;

  SendMoneyState copyWith({
    String? receiver,
    String? amount,
    String? password,
    SendMoneyStatus? status,
    String? errorMessage,
  }) {
    return SendMoneyState(
      receiver: receiver ?? this.receiver,
      amount: amount ?? this.amount,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [receiver, amount, password, status, errorMessage];
}
