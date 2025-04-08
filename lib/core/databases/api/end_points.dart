class EndPoints {
  //********  base url
  static const String baserUrl = 'https://web.goalmasters.online/api/';

  //******* routes
  static const String id = 'id'; //! example route, remove this

  //# parent
  static String login = 'login';

  static String sendOTP = 'resend-otp';

  static String verifyOTP = 'verify';

  static String update = 'user/update';

  static String register = 'register';

  static String changePassword = 'change-password';

  static String changePasswordUser = 'user/change-password-user';

  static String refresh = 'user/refresh';

  static String profile = 'user/profile';
  static String bookingHistory(int id) => 'user/booking/history?page=$id';

  static String cancelBooking = 'user/booking/cancel-booking';

  static String listZone = 'list/zone';
  static String listClub = 'list/club';

  static String listCategory = 'list/category';

  static String listService = 'list/service';

  static String listEmployee = 'list/booking';

  static String listTimeslot = 'list/timeslot';
}

//doctors/top-ratings
