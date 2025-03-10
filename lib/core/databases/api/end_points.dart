class EndPoints {
  //********  base url
  static const String baserUrl = 'https://autismvc-stg-api.wakeb.io/api/';
  static const String patient = 'patient';
  static const String parent = 'parent';

  //******* routes
  static const String id = 'id'; //! example route, remove this
  static const String articles = '$patient/blogs';
  static const String profilePatient = '$patient/profile';
  static String article(int id) => '$patient/blogs/$id';
  static String toggleBlogFavorite(int id) =>
      '$patient/blogs/$id/toggle/favorities';
  static const String reservations = 'reservations';
  static String reservation(int id) => 'reservation/$id';
  static String ratesDetails(int id) => 'rates/$id';
  static const String notifications = 'notifications';
  // static const String home = 'home';
  static const String rates = 'rates';
  static const String serviceProvidersSearch = 'serviceProvidersSearch';
  static const String ariRecords = 'ariRecords';
  static const String attachedFiles = '$patient/profile/attachments';
  static String deleteAttachments(int id) => '$patient/profile/attachments/$id';
  static const String patientBills = 'patientBills';
  static const String patientMedicalHistory = 'patientMedicalHistory';
  static String patientBillDetails(int id) => 'reservation/$id';

  static String addPatient = 'addPatient';
  static String updatePatient = 'updatePatient';
  static String helpCenter = 'helpCenter';
  static String favoritesArticles = 'favoritesArticles';
  static String favoritesDoctors = 'favoritesDoctors';
  static String doctor(int id) => 'doctor/$id';
  static String services = '$patient/services';
  static String paymenthistory = '';
  static String termsandconditions = '';

  //# parent
  static String login = '$parent/login';
  static String register = '$parent/register';
  static String resetPassword = '$parent/reset';
  static String sendOTP = '$parent/send-otp';
  static String verifyOTP = '$parent/verify-otp';
  static const String profile = '$parent/profile';

  //# patient
  static const String specialties = '$patient/specialities';
  static const String topDoctors = '$patient/doctors/top-ratings';
}

//doctors/top-ratings
