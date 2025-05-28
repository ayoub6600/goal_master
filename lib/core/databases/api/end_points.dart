class EndPoints {
  //********  base url
  static const String baserUrl = 'https://web.goalmasters.online/api/';

  //******* routes
  static const String id = 'id'; //! example route, remove this

  //# parent
  static String login = 'login';
  static String getServices = 'get-service-info';
  static String sendOTP = 'resend-otp';

  static String verifyOTP = 'verify';

  static String update = 'user/update';

  static String banner = "list/slider";

  static String register = 'register';

  static String deleteAccount = 'user/delete';

  static String changePassword = 'change-password';

  static String changePasswordUser = 'user/change-password-user';

  static String refresh = 'user/refresh';

  static String profile = 'user/profile';
  static String analysis = 'user/analysis';
  static String bookingHistory(int id) => 'user/booking/history?page=$id';

  static String cancelBooking = 'user/booking/cancel-booking';

  static String listZone = 'list/zone';
  static String listClub = 'list/club';

  static String listCategory = 'list/category';

  static String listService = 'list/service';

  static String listEmployee = 'list/booking';

  static String listTimeslot = 'list/timeslot';

  static String addBooking = 'user/booking/store-booking';

  static String charge = 'user/card/charge';
  //user/card/balance

  static String balance = 'user/card/balance';

  ///user/booking/fillter-new-booking?page=5

  static String fillterNewBooking(int id) =>
      'user/booking/fillter-new-booking?page=$id';
}

//doctors/top-ratings
