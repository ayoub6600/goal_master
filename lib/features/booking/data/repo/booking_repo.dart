import 'package:dartz/dartz.dart';
import 'package:goal_master/core/components/paginated_response.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/model/category_model.dart';
import 'package:goal_master/features/booking/data/model/club_responce.dart';
import 'package:goal_master/features/booking/data/model/employe/employe.dart';
import 'package:goal_master/features/booking/data/model/location_reponse.dart';
import 'package:goal_master/features/booking/data/model/service_model.dart';
import 'package:goal_master/features/booking/data/model/timeslot.dart';

abstract class BookingRepo {
  Future<Either<Failure, PaginatedResponse<Booking>>> getBooking(
    int page,
    bool now,
  );
  Future<Either<Failure, Booking>> cancelBooking(
    int id,
  );
  Future<Either<Failure, List<Location>>> listZone();
  Future<Either<Failure, List<ClubResponce>>> listClub(
    int zoneId,
  );
  //category
  Future<Either<Failure, List<CategoryModel>>> listCategory(
      {required int branchId});
  //service
  Future<Either<Failure, List<Service>>> listService(
    int categoryId,
    int branchId,
  );

  //employee
  Future<Either<Failure, List<Employee>>> listEmployee({required int branchId});
  //timeslot
  Future<Either<Failure, List<TimeslotModel>>> listTimeslot({
    required int branchId,
    required int employeeId,
    required int serviceId,
    required String date,
  });
}
