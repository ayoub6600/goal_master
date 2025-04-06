import 'package:equatable/equatable.dart';

sealed class BookingToggleState extends Equatable {
  const BookingToggleState();

  @override
  List<Object> get props => [];
}

final class BookingDoctors extends BookingToggleState {}

final class BookingArticles extends BookingToggleState {}
