import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo_imp.dart';
import 'package:goal_master/features/balance/data/repo/balance_repo.dart';
import 'package:goal_master/features/balance/data/repo/balance_repo_imp.dart';
import 'package:goal_master/features/card/data/repo/card_repo_imp.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo_imp.dart';
import 'package:goal_master/features/notification/data/repo/notifaction_repo.dart';
import 'package:goal_master/features/notification/data/repo/notifaction_repo_imp.dart';
import 'package:goal_master/features/profile/data/repo/profile_repo_imp.dart';
import 'package:goal_master/features/assistant/data/repo/assistant_repo_imp.dart';
import 'package:goal_master/features/coins/data/repo/coins_repo_imp.dart';
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
  getIt.registerSingleton<AnalysisRepoImp>(
    AnalysisRepoImp(getIt.get<DioConsumer>()),
  );
  //CardRepoImp
  getIt.registerSingleton<CardRepoImp>(
    CardRepoImp(getIt.get<DioConsumer>()),
  );
  //BalanceRepoImp
  getIt.registerSingleton<BalanceRepoImp>(
    BalanceRepoImp(getIt.get<DioConsumer>()),
  );
  getIt.registerSingleton<NotificationRepo>(
    NotificationRepoImp(getIt.get<DioConsumer>()),
  );
  //BalanceRepo
  getIt.registerSingleton<BalanceRepo>(
    BalanceRepoImp(getIt.get<DioConsumer>()),
  );
  getIt.registerSingleton<AssistantRepoImp>(
    AssistantRepoImp(getIt.get<DioConsumer>()),
  );
  getIt.registerSingleton<CoinsRepoImp>(
    CoinsRepoImp(getIt.get<DioConsumer>()),
  );
}
