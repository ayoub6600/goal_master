import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'time_state.dart';

class TimeCubit extends Cubit<TimeState> {
  TimeCubit() : super(TimeInitial());
}
