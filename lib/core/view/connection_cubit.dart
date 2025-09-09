import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionCubit extends Cubit<bool> {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectionCubit() : super(true) {
    _init();
  }

  Future<void> _init() async {
    final initial = await _connectivity.checkConnectivity();
    _emitFromResult(initial);
    _subscription = _connectivity.onConnectivityChanged.listen(_emitFromResult);
  }

  void _emitFromResult(List<ConnectivityResult> result) {
    emit(!result.contains(ConnectivityResult.none));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
