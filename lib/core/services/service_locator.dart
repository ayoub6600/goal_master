import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo_imp.dart';
import 'package:goal_master/features/profail/data/repo/profile_repo_imp.dart';
import '../../features/booking/data/repo/booking_repo_imp.dart';
import '../databases/api/dio_consumer.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<DioConsumer>(DioConsumer(dio: getIt<Dio>()));

  getIt.registerSingleton<AuthRepoImpl>(
    AuthRepoImpl(getIt.get<DioConsumer>()),
  );
  getIt.registerSingleton<ProfileRepoImp>(
    ProfileRepoImp(getIt.get<DioConsumer>()),
  );
  getIt.registerSingleton<BookingRepoImp>(
    BookingRepoImp(getIt.get<DioConsumer>()),
  );
}
