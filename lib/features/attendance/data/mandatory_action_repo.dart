import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/attendance/data/mandatory_action.dart';

/// Reads and answers the questions the backend is holding open.
///
/// Kept deliberately thin: the gate's correctness comes from the server being
/// asked again after every answer, not from anything cached here.
abstract class MandatoryActionRepo {
  Future<Either<Failure, List<MandatoryAction>>> pending();

  Future<Either<Failure, List<MandatoryAction>>> answer({
    required int confirmationId,
    required bool attended,
    String type = MandatoryAction.kAttendanceConfirmation,
  });
}

class MandatoryActionRepoImpl implements MandatoryActionRepo {
  MandatoryActionRepoImpl(this.consumer);

  final ApiConsumer consumer;

  @override
  Future<Either<Failure, List<MandatoryAction>>> pending() {
    return consumer.handleRequestCustom(
      () => consumer.get(EndPoints.mandatoryActions),
      (res) async => _parse(res),
    );
  }

  @override
  Future<Either<Failure, List<MandatoryAction>>> answer({
    required int confirmationId,
    required bool attended,
    String type = MandatoryAction.kAttendanceConfirmation,
  }) {
    return consumer.handleRequestCustom(
      () => consumer.post(EndPoints.attendanceConfirmation, data: {
        'confirmation_id': confirmationId,
        'attended': attended ? 1 : 0,
        'type': type,
      }),
      // The answer response carries what is LEFT, so the caller never has to
      // guess whether the queue is empty — a wrong guess would either strand
      // the customer or let them through with a question still open.
      (res) async {
        final data = res['data'];
        if (data is Map && data['next'] is Map<String, dynamic>) {
          return [MandatoryAction.fromJson(Map<String, dynamic>.from(data['next']))];
        }
        return <MandatoryAction>[];
      },
    );
  }

  List<MandatoryAction> _parse(dynamic res) {
    final data = res is Map ? res['data'] : null;
    final raw = data is Map ? data['mandatory_actions'] : null;
    if (raw is! List) return <MandatoryAction>[];

    return raw
        .whereType<Map>()
        .map((e) => MandatoryAction.fromJson(Map<String, dynamic>.from(e)))
        .where((a) => a.id > 0)
        .toList();
  }
}
