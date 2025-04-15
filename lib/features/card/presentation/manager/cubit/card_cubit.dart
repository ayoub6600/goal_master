import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:goal_master/features/card/data/repo/card_repo.dart';

part 'card_state.dart';

class CardCubit extends Cubit<CardState> {
  CardCubit(this._repo) : super(CardInitial());
  final CardRepo _repo;
  final codeController =
      TextEditingController(); // تغيير اسم المتغير ليكون أكثر وضوحًا

  Future<void> addCard() async {
    String code = codeController.text
        .trim(); // استخدم text.trim() مباشرة لتفادي استخدام code.text مرتين
    if (code.isEmpty) {
      // عرض رسالة في حال كان الحقل فارغًا
      emit(CardFailure('ادخل رقم الكارت'));
      return;
    }

    emit(CardLoading());
    final result = await _repo.addCard(code); // إرسال الكود إلى الـ repo
    result.fold(
      (l) => emit(CardFailure(l.errMessage)), // في حال فشل الإضافة
      (r) => emit(CardSuccess(r)), // في حال نجاح الإضافة
    );
  }
}
