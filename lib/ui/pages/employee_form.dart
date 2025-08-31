import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_http_dummydata/provider_models/employee_model.dart';
import 'package:app_http_dummydata/data_classes/employee.dart';

class EmployeeFormWidget extends StatefulWidget {
  final String?
  id; // Optional ID - if provided, we're editing; if null, we're adding

  const EmployeeFormWidget({super.key, this.id});

  @override
  EmployeeFormWidgetState createState() => EmployeeFormWidgetState();
}

class EmployeeFormWidgetState extends State<EmployeeFormWidget> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for each field
  final _nameController = TextEditingController();
  final _salaryController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isSubmitting = false;
  bool _isLoading = false;
  String? _error;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.id != null;

    // If we're in edit mode, load the employee data
    if (_isEditMode) {
      _loadEmployeeData();
    }
  }

  Future<void> _loadEmployeeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<EmployeeProvider>(context, listen: false);

      // Check if we already have the employee in the provider
      Employee? employee = provider.getEmployeeById(widget.id!);

      // If not, fetch it
      if (employee == null) {
        await provider.fetchEmployee(widget.id!);
        employee = provider.selectedEmployee;
      }

      // If we have the employee, populate the form fields
      if (employee != null) {
        _nameController.text = employee.employeeName;
        _salaryController.text = employee.employeeSalary;
        _ageController.text = employee.employeeAge;
      } else {
        _error = 'Could not load employee data';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _nameController.dispose();
    _salaryController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // Validate and submit the form
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Create an employee object with the form data
        final employee = Employee(
          id: widget.id ?? '', // Use existing ID if editing, empty if adding
          employeeName: _nameController.text.trim(),
          employeeSalary: _salaryController.text.trim(),
          employeeAge: _ageController.text.trim(),
          profileImage: '', // We're not handling image uploads in this example
        );

        // Get the provider
        final provider = Provider.of<EmployeeProvider>(context, listen: false);

        // Save the employee (the provider will handle whether it's an update or create)
        await provider.saveEmployee(employee);

        // If successful, show a success message and navigate back
        if (provider.error == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditMode
                      ? 'Employee updated successfully'
                      : 'Employee added successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        } else {
          // If there was an error, show it
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${provider.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // Handle any unexpected errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Employee' : 'Add Employee'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter employee name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Salary field
                    TextFormField(
                      controller: _salaryController,
                      decoration: const InputDecoration(
                        labelText: 'Salary',
                        hintText: 'Enter employee salary',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a salary';
                        }
                        // Check if it's a valid number
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Age field
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        hintText: 'Enter employee age',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an age';
                        }
                        // Check if it's a valid integer
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid integer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isEditMode ? 'Update Employee' : 'Add Employee',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
