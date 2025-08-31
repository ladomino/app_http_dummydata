import 'package:app_http_dummydata/api/api_service.dart';
import 'package:app_http_dummydata/data_classes/employee.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class EmployeeProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Employee> _employees = [];
  Employee? _selectedEmployee;
  bool _isLoading = false;
  String? _error;

  EmployeeProvider(this._apiService);

  List<Employee> get employees => _employees;
  Employee? get selectedEmployee => _selectedEmployee;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get employee from in-memory list by ID
  Employee? getEmployeeById(String id) {
    try {
      return _employees.firstWhere((employee) => employee.id == id);
    } catch (e) {
      // If not found, return null
      return null;
    }
  }

  Future<void> fetchEmployees() async {
    _isLoading = true;
    _error = null;

    List<Employee> employees = [];

    try {
      employees = await _apiService.getEmployees();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    if (employees.isNotEmpty) {
      _employees = employees;
    }
    notifyListeners();
  }

  Future<void> fetchEmployee(String id) async {
    _isLoading = true;
    _error = null;
    _selectedEmployee = null;

    // First check if we have the employee in memory
    _selectedEmployee = getEmployeeById(id);

    if (_selectedEmployee != null) {
      debugPrint(
        'Found employee in memory: ${_selectedEmployee?.employeeName}',
      );
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _selectedEmployee = await _apiService.getEmployee(id);

      if (_selectedEmployee == null) {
        _error = 'Employee not found';
        debugPrint('Employee not found with ID: $id');
      } else {
        debugPrint(
          'Successfully fetched employee: ${_selectedEmployee?.employeeName}',
        );
      }
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching employee: $_error');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteEmployee(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    debugPrint('Removing employee with ID: $id');

    try {
      await _apiService.deleteEmployee(id);

      // Remove employee from in-memory list
      //debugPrint('Removing employee from memory with ID: $id');

      //_employees.removeWhere((employee) => employee.id == id);

      // If the deleted employee was the selected one, clear it
      if (_selectedEmployee?.id == id) {
        _selectedEmployee = null;
      }

      _isLoading = false;
    } catch (e) {
      debugPrint(e.toString());

      _isLoading = false;
      _error = e.toString();
    }
    // Remove employee from in-memory list
    debugPrint('Removing employee from memory with ID: $id');

    _employees.removeWhere((employee) => employee.id == id);

    notifyListeners();
  }

  // Method to save an employee (handles both create and update)
  Future<void> saveEmployee(Employee employee) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      //final apiService = ApiService();
      Employee savedEmployee;

      if (employee.id.isEmpty) {
        // This is a new employee, create it
        //savedEmployee = await apiService.createEmployee(employee);
        savedEmployee = Employee(
          id: Uuid().v4(), // Generate a unique ID
          employeeName: employee.employeeName,
          employeeSalary: employee.employeeSalary,
          employeeAge: employee.employeeAge,
          profileImage: employee.profileImage,
        );

        _employees.add(savedEmployee);
      } else {
        // This is an existing employee, update it
        //savedEmployee = await apiService.updateEmployee(employee);
        savedEmployee = Employee(
          id: employee.id,
          employeeName: employee.employeeName,
          employeeSalary: employee.employeeSalary,
          employeeAge: employee.employeeAge,
          profileImage: employee.profileImage,
        );

        // Find and replace the employee in the list
        final index = _employees.indexWhere((e) => e.id == employee.id);
        if (index != -1) {
          _employees[index] = savedEmployee;
        } else {
          _employees.add(savedEmployee);
        }

        // Update selected employee if it's the one we're viewing
        if (_selectedEmployee != null &&
            _selectedEmployee!.id == savedEmployee.id) {
          _selectedEmployee = savedEmployee;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
