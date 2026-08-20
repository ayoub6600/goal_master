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
        id: _asNullableInt(json['id']),
        fullName: _asNullableString(json['full_name']),
        imageUrl: _asNullableString(json['image_url']),
        employeeId: json['employee_id']?.toString(),
        cmnBranchId: _asNullableInt(json['cmn_branch_id']),
        emailAddress: json['email_address']?.toString(),
        countryCode: json['country_code'] as dynamic,
        contactNo: json['contact_no']?.toString(),
        hrmDepartmentId: json['hrm_department_id'] as dynamic,
        hrmDesignationId: _asNullableInt(json['hrm_designation_id']),
        userId: json['user_id'] as dynamic,
        gender: _asNullableInt(json['gender']),
        dob: json['dob'] as dynamic,
        specialist: json['specialist']?.toString(),
        presentAddress: json['present_address']?.toString(),
        permanentAddress: json['permanent_address']?.toString(),
        note: json['note']?.toString(),
        payCommissionBasedOn: _asNullableInt(json['pay_commission_based_on']),
        targetServiceAmount: json['target_service_amount']?.toString(),
        passport: json['passport'] as dynamic,
        idCard: json['id_card'] as dynamic,
        commission: json['commission']?.toString(),
        salary: json['salary']?.toString(),
        status: _asNullableInt(json['status']),
        createdBy: _asNullableInt(json['created_by']),
        updatedBy: _asNullableInt(json['updated_by']),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'].toString()),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.tryParse(json['updated_at'].toString()),
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

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final stringValue = value.toString();
  return stringValue.isEmpty || stringValue == 'null' ? null : stringValue;
}
