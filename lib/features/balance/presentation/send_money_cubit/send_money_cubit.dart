import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show TextEditingController;
import 'package:goal_master/features/balance/data/repo/balance_repo.dart';

part 'send_money_state.dart';

class SendMoneyCubit extends Cubit<SendMoneyState> {
  SendMoneyCubit(this.balanceRep) : super(const SendMoneyState()) {
    // اسمع لأي تغيير في الحقول وحدّث الـ state علشان الزر يتفعّل/يتعطّل لحظيًا
    amountController.addListener(_onFieldsChanged);
    receiverIdController.addListener(_onFieldsChanged);
  }

  final BalanceRepo balanceRep;

  // Controllers (بتستخدمهم في الواجهة)
  final TextEditingController amountController = TextEditingController();
  final TextEditingController receiverIdController = TextEditingController();

  void _onFieldsChanged() {
    emit(state.copyWith(
      amount: amountController.text,
      receiver: receiverIdController.text,
      status: SendMoneyStatus.idle,
      errorMessage: null,
    ));
  }

  Future<void> submit() async {
    final amount = state.amount.trim();
    final receiver = state.receiver.trim();
    final parsed = double.tryParse(amount);

    // فاليديشِن سريع
    if (receiver.isEmpty || parsed == null || parsed <= 0) {
      emit(state.copyWith(
        status: SendMoneyStatus.error,
        errorMessage: receiver.isEmpty
            ? "من فضلك أدخل رقم المستلم"
            : "من فضلك أدخل مبلغًا صحيحًا أكبر من 0",
      ));
      // نرجع للحالة الهادية بعد إشعار الخطأ (علشان UI ما يفضلش على error)
      emit(state.copyWith(status: SendMoneyStatus.idle));
      return;
    }

    emit(state.copyWith(status: SendMoneyStatus.loading, errorMessage: null));

    final result = await balanceRep.sendMoney(
      amount: amount,
      receiverId: receiver,
    );

    result.fold(
      (l) => emit(state.copyWith(
        status: SendMoneyStatus.error,
        errorMessage: l.errMessage,
      )),
      (r) => emit(state.copyWith(status: SendMoneyStatus.success)),
    );
  }

  void reset() {
    amountController.clear();
    receiverIdController.clear();
    emit(const SendMoneyState());
  }

  @override
  Future<void> close() {
    amountController.dispose();
    receiverIdController.dispose();
    return super.close();
  }
}
