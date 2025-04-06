import 'package:dartz/dartz.dart';
import 'package:goal_master/core/components/paginated_response.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/model/category_model.dart';
import 'package:goal_master/features/booking/data/model/club_responce.dart';
import 'package:goal_master/features/booking/data/model/location_reponse.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

class BookingRepoImp extends BookingRepo {
  final ApiConsumer apiConsumer;

  BookingRepoImp(this.apiConsumer);

  @override
  Future<Either<Failure, PaginatedResponse<Booking>>> getBooking(
      int page, bool now) async {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(
        EndPoints.bookingHistory(page),
        queryParameters: {
          'pageSize': 10,
          'page': page,
          'now': now,
        },
      ),
      (data) => PaginatedResponse<Booking>.fromJson(
        data['data'],
        (json) => Booking.fromJson(json),
      ),
    );
  }

  @override
  Future<Either<Failure, Booking>> cancelBooking(int id) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.cancelBooking,
        data: {
          'id': id,
        },
      ),
      (data) => Booking.fromJson(data['data']),
    );
  }

  @override
  Future<Either<Failure, List<Location>>> listZone() {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.listZone),
      (data) {
        // تأكد من أن data['data'] هو عبارة عن List
        List<Location> locations = (data['data'] as List<dynamic>)
            .map((item) => Location.fromJson(item as Map<String, dynamic>))
            .toList();
        return locations;
      },
    );
  }

  @override
  Future<Either<Failure, List<ClubResponce>>> listClub(int zoneId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.listClub,
        data: {
          'zone': '2',
        },
      ),
      (data) {
        print("data: ${data["id"]}");
        List<ClubResponce> clubs = (data['data'] as List<dynamic>)
            .map((item) => ClubResponce.fromJson(item as Map<String, dynamic>))
            .toList();
        return clubs;
      },
    );
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> listCategory(
      {required int branchId}) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.listCategory,
        data: {
          'branch': branchId,
        },
      ),
      (data) {
        List<CategoryModel> categories = (data['data'] as List<dynamic>)
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return categories;
      },
    );
  }
}
