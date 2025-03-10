// import 'package:avc_client/core/routing/routes_keys.dart';
// import 'package:avc_client/features/dummy_view.dart';
// import 'package:avc_client/features/favorites/presentation/manager/fav_toggle_cubit/fav_toggle_cubit.dart';
// import 'package:avc_client/features/favorites/presentation/view/favorites_view.dart';
// import 'package:avc_client/features/home/data/repo/home_repo_imp.dart';
// import 'package:avc_client/features/home/presentation/manager/fetch_services_cubit/fetch_services_cubit.dart';
// import 'package:avc_client/features/home/presentation/manager/fetch_specialities_cubit/fetch_specialities_cubit.dart';
// import 'package:avc_client/features/home/presentation/manager/fetch_top_doctors_cubit/fetch_top_doctors_cubit.dart';
// import 'package:avc_client/features/home/presentation/view/home_view.dart';
// import 'package:avc_client/features/my_booking/presentation/view/booking_view.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// import '../../features/services/presentation/view/services_view.dart';
// import '../services/service_locator.dart';

// List<StatefulShellBranch> routesBranches = [
//   StatefulShellBranch(
//     routes: <RouteBase>[
//       GoRoute(
//         path: RoutesKeys.kHomeViewTab,
//         builder: (context, state) => MultiBlocProvider(providers: [
//           BlocProvider<FetchSpecialtiesCubit>(
//             create: (context) => FetchSpecialtiesCubit(getIt<HomeRepoImp>()),
//           ),
//           BlocProvider<FetchServicesCubit>(
//             create: (context) => FetchServicesCubit(getIt<HomeRepoImp>()),
//           ),
//           BlocProvider<FetchTopDoctorsCubit>(
//             create: (context) => FetchTopDoctorsCubit(getIt<HomeRepoImp>()),
//           ),
//           //FetchTopDoctorsCubit
//         ], child: const HomeView()),
//       ),
//     ],
//   ),
//   StatefulShellBranch(
//     routes: <RouteBase>[
//       GoRoute(
//         path: RoutesKeys.kReservationsTab,
//         builder: (context, state) => const BookingView(),
//       ),
//     ],
//   ),
//   StatefulShellBranch(
//     routes: <RouteBase>[
//       GoRoute(
//         path: RoutesKeys.kServiceTab,
//         builder: (context, state) => const ServicesView(),
//       ),
//     // ],
//   ),
//   StatefulShellBranch(
//     routes: <RouteBase>[
//       GoRoute(
//         path: RoutesKeys.kFavTab,
//         builder: (context, state) => MultiBlocProvider(providers: [
//           BlocProvider<FavToggleCubit>(
//             create: (context) => FavToggleCubit(),
//           ),
//         ], child: const FavoritesView()),
//       ),
//     ],
//   ),
//   StatefulShellBranch(
//     routes: <RouteBase>[
//       GoRoute(
//         path: RoutesKeys.kAccountTab,
//         builder: (context, state) => const DummyAddPatientView(
//           title: 'الحساب',
//         ),
//       ),
//     ],
//   ),
// ];
