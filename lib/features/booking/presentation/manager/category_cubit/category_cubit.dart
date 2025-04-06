import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/booking/data/model/category_model.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this.bookingRepo) : super(CategoryInitial());
  final BookingRepo bookingRepo;

  Future<void> listCategory({required int branchId}) async {
    emit(CategoryLoading());
    final result = await bookingRepo.listCategory(branchId: branchId);
    result.fold((failure) => emit(CategoryFailure(message: failure.errMessage)),
        (category) {
      emit(CategorySuccess(categories: category));
    });
  }
}
