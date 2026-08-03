import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:goal_master/core/databases/api/end_points.dart';

class ConnectionCubit extends Cubit<bool> {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectionCubit() : super(true) {
    _init();
  }

  Future<void> _init() async {
    await retryCheck();
    _subscription = _connectivity.onConnectivityChanged.listen(_emitFromResult);
  }

  Future<bool> retryCheck() async {
    final initial = await _connectivity.checkConnectivity();
    return _emitFromResult(initial);
  }

  Future<bool> _emitFromResult(List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.none)) {
      emit(false);
      return false;
    }

    final connected = await _hasInternetAccess();
    emit(connected);
    return connected;
  }

  Future<bool> _hasInternetAccess() async {
    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 3);

    try {
      final request = await httpClient.getUrl(
        Uri.parse('${EndPoints.baserUrl}${EndPoints.banner}'),
      );
      final response = await request.close();
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      try {
        final result = await InternetAddress.lookup('example.com');
        return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      } finally {
        httpClient.close(force: true);
      }
    } finally {
      httpClient.close(force: true);
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
