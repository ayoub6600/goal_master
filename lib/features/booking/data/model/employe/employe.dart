import 'branch.dart';
import 'designation.dart';

class Employee {
  int? id;
  String? fullName;
  String? imageUrl;
  String? employeeId;
  int? cmnBranchId;
  String? emailAddress;
  dynamic countryCode;
  String? contactNo;
  dynamic hrmDepartmentId;
  int? hrmDesignationId;
  dynamic userId;
  int? gender;
  dynamic dob;
  String? specialist;
  String? presentAddress;
  String? permanentAddress;
  String? note;
  int? payCommissionBasedOn;
  String? targetServiceAmount;
  dynamic passport;
  dynamic idCard;
  String? commission;
  String? salary;
  int? status;
  int? createdBy;
  int? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  Designation? designation;
  Branch? branch;

  Employee({
    this.id,
    this.fullName,
    this.imageUrl,
    this.employeeId,
    this.cmnBranchId,
    this.emailAddress,
    this.countryCode,
    this.contactNo,
    this.hrmDepartmentId,
    this.hrmDesignationId,
    this.userId,
    this.gender,
    this.dob,
    this.specialist,
    this.presentAddress,
    this.permanentAddress,
    this.note,
    this.payCommissionBasedOn,
    this.targetServiceAmount,
    this.passport,
    this.idCard,
    this.commission,
    this.salary,
    this.status,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.designation,
    this.branch,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'] as int?,
        fullName: json['full_name'] as String?,
        imageUrl: json['image_url'] as String?,
        employeeId: json['employee_id'] as String?,
        cmnBranchId: json['cmn_branch_id'] as int?,
        emailAddress: json['email_address'] as String?,
        countryCode: json['country_code'] as dynamic,
        contactNo: json['contact_no'] as String?,
        hrmDepartmentId: json['hrm_department_id'] as dynamic,
        hrmDesignationId: json['hrm_designation_id'] as int?,
        userId: json['user_id'] as dynamic,
        gender: json['gender'] as int?,
        dob: json['dob'] as dynamic,
        specialist: json['specialist'] as String?,
        presentAddress: json['present_address'] as String?,
        permanentAddress: json['permanent_address'] as String?,
        note: json['note'] as String?,
        payCommissionBasedOn: json['pay_commission_based_on'] as int?,
        targetServiceAmount: json['target_service_amount'] as String?,
        passport: json['passport'] as dynamic,
        idCard: json['id_card'] as dynamic,
        commission: json['commission'] as String?,
        salary: json['salary'] as String?,
        status: json['status'] as int?,
        createdBy: json['created_by'] as int?,
        updatedBy: json['updated_by'] as int?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
        designation: json['designation'] == null
            ? null
            : Designation.fromJson(json['designation'] as Map<String, dynamic>),
        branch: json['branch'] == null
            ? null
            : Branch.fromJson(json['branch'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'image_url': imageUrl,
        'employee_id': employeeId,
        'cmn_branch_id': cmnBranchId,
        'email_address': emailAddress,
        'country_code': countryCode,
        'contact_no': contactNo,
        'hrm_department_id': hrmDepartmentId,
        'hrm_designation_id': hrmDesignationId,
        'user_id': userId,
        'gender': gender,
        'dob': dob,
        'specialist': specialist,
        'present_address': presentAddress,
        'permanent_address': permanentAddress,
        'note': note,
        'pay_commission_based_on': payCommissionBasedOn,
        'target_service_amount': targetServiceAmount,
        'passport': passport,
        'id_card': idCard,
        'commission': commission,
        'salary': salary,
        'status': status,
        'created_by': createdBy,
        'updated_by': updatedBy,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'designation': designation?.toJson(),
        'branch': branch?.toJson(),
      };
}
