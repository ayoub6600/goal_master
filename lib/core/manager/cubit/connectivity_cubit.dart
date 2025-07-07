import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectivityStatus { connected, disconnected }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  ConnectivityCubit() : super(ConnectivityStatus.connected) {
    _startMonitoring();
  }

  Timer? _timer;

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final connected = await _checkInternetConnection();
      emit(connected
          ? ConnectivityStatus.connected
          : ConnectivityStatus.disconnected);
    });
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
