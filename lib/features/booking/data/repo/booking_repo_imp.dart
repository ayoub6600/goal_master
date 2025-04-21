import 'package:dartz/dartz.dart';
import 'package:goal_master/core/components/paginated_response.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/model/cancel_booking_response.dart';
import 'package:goal_master/features/booking/data/model/category_model.dart';
import 'package:goal_master/features/booking/data/model/club_responce.dart';
import 'package:goal_master/features/booking/data/model/employe/employe.dart';
import 'package:goal_master/features/booking/data/model/location_reponse.dart';
import 'package:goal_master/features/booking/data/model/service_model.dart';
import 'package:goal_master/features/booking/data/model/timeslot.dart';
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
  Future<Either<Failure, CancelBookingResponse>> cancelBooking(int id) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.cancelBooking,
        data: {
          'id': id,
        },
      ),
      (data) => CancelBookingResponse.fromJson(data),
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
          'zone': zoneId,
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

  @override
  Future<Either<Failure, List<Service>>> listService(
      int categoryId, int branchId) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.listService,
        data: {
          'category': categoryId,
          'branch': branchId,
        },
      ),
      (data) {
        List<Service> services = (data['data'] as List<dynamic>)
            .map((item) => Service.fromJson(item as Map<String, dynamic>))
            .toList();
        return services;
      },
    );
  }

  @override
  Future<Either<Failure, List<Employee>>> listEmployee(
      {required int branchId}) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.listEmployee,
        data: {
          'branch': branchId,
        },
      ),
      (data) {
        List<Employee> employees = (data['data'] as List<dynamic>)
            .map((item) => Employee.fromJson(item as Map<String, dynamic>))
            .toList();
        return employees;
      },
    );
  }

  @override
  Future<Either<Failure, List<TimeslotModel>>> listTimeslot(
      {required int branchId,
      required int employeeId,
      required int serviceId,
      required String date}) {
    return apiConsumer.handleRequest(
        () => apiConsumer.post(
              EndPoints.listTimeslot,
              data: {
                'branch_id': branchId,
                'employee_id': employeeId,
                'service_id': serviceId,
                'date': date,
              },
            ), (data) {
      List<TimeslotModel> timeslots = (data['data'] as List<dynamic>)
          .map((item) => TimeslotModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return timeslots;
    });
  }

  @override
  Future<Either<Failure, String>> addBooking(
      {required int branchId,
      required int employeeId,
      required int serviceId,
      required int paymentType,
      required String date,
      required String startTime,
      required String endTime,
      required String fullName,
      required String phone,
      required String state}) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.addBooking,
        data: {
          'branch_id': branchId,
          'employee_id': employeeId,
          'service_id': serviceId,
          'payment_type': paymentType,
          'service_date': date,
          'start_time': startTime,
          'end_time': endTime,
          'full_name': fullName,
          'phone_no': phone,
          'state': "1",
        },
      ),
      (data) {
        if (paymentType == 1) {
          return data['data'];
        }

        // Extract returnUrl if available
        final returnUrl = data['data']?['returnUrl'];
        if (returnUrl != null && returnUrl is String) {
          return returnUrl;
        }

        // fallback: return something useful (e.g., success message or booking ID)
        return data['data'].toString();
      },
    );
  }
}
