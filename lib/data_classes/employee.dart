class Employee {
  final String id;
  final String employeeName;
  final String employeeSalary;
  final String employeeAge;
  final String profileImage;

  Employee({
    required this.id,
    required this.employeeName,
    required this.employeeSalary,
    required this.employeeAge,
    required this.profileImage,
  });

  get hasEmptyId => id.isEmpty;

  const Employee.empty() 
  :   id = '',
      employeeName = '',
      employeeSalary = '',
      employeeAge = '',
      profileImage = '';


  factory Employee.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw FormatException('Null json received');
    }

     return Employee(
      id: json['id']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? '',
      employeeSalary: json['employee_salary']?.toString() ?? '',
      employeeAge: json['employee_age']?.toString() ?? '',
      profileImage: json['profile_image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'employeeName': employeeName,
      'employeeSalary': employeeSalary,
      'employeeAge': employeeAge,
      'profileImage': profileImage,
    };

    if (id.isNotEmpty) {
      map['id'] = id;
    }

    if (profileImage.isNotEmpty) {
      map['profileImage'] = profileImage;
    }
    return map;
  }

  // Create a copy of this Employee with optional new values
  Employee copyWith({
    String? id,
    String? employeeName,
    String? employeeSalary,
    String? employeeAge,
    String? profileImage,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      employeeSalary: employeeSalary ?? this.employeeSalary,
      employeeAge: employeeAge ?? this.employeeAge,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  // Override equality to compare Employee objects properly
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee &&
        other.id == id &&
        other.employeeName == employeeName &&
        other.employeeSalary == employeeSalary &&
        other.employeeAge == employeeAge &&
        other.profileImage == profileImage;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      employeeName,
      employeeSalary,
      employeeAge,
      profileImage,
    );
  }

  @override
  String toString() {
    return 'Employee(id: $id, name: $employeeName, salary: $employeeSalary, age: $employeeAge)';
  }
}
