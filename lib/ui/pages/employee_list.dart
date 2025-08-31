import 'package:app_http_dummydata/ui/pages/employee_detail.dart';
import 'package:app_http_dummydata/ui/pages/employee_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:app_http_dummydata/provider_models/employee_model.dart';

class EmployeeListWidget extends StatefulWidget {
  const EmployeeListWidget({super.key});

  @override
  EmployeeListWidgetState createState() => EmployeeListWidgetState();
}

class EmployeeListWidgetState extends State<EmployeeListWidget> {
  bool _refresh = false;

  @override
  void initState() {
    super.initState();
    // Fetch employees when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchEmployees();
    });
  }

  _refreshEmployees() {
    setState(() {
      _refresh = true;
    });
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Employee'),
            content: Text('Are you sure you want to delete $name?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

@override
  Widget build(BuildContext context) {
    if (_refresh) {
      _refresh = false;
      context.read<EmployeeProvider>().fetchEmployees();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshEmployees,
            tooltip: 'Refresh',
          ),
          // Add button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmployeeFormWidget()),
                )
            },
            tooltip: 'Add Employee',
          ),
        ],
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.error != null && provider.employees.isEmpty) {
            return Center(child: Text('Error: ${provider.error}'));
          } else if (provider.employees.isEmpty) {
            return const Center(child: Text('No employees found'));
          } else {
            return ListView.builder(
              itemCount: provider.employees.length,
              itemBuilder: (context, index) {
                final employee = provider.employees[index];
                final displayName = employee.employeeName.isNotEmpty
                    ? employee.employeeName
                    : 'Unknown';

                return Slidable(
                  key: ValueKey('slidable_${employee.id}'),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          // Show dialog directly without async/await
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Delete Employee'),
                              content: Text('Are you sure you want to delete $displayName?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Close dialog first
                                    Navigator.of(dialogContext).pop();
                                    
                                    // Then delete employee
                                    provider.deleteEmployee(employee.id);
                                    
                                    // Show snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$displayName deleted'),
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    key: ValueKey(employee.id),
                    title: Text(displayName),
                    subtitle: Text(
                      'Salary: ${employee.employeeSalary.isNotEmpty ? employee.employeeSalary : 'N/A'}',
                    ),
                    trailing: Text(
                      'Age: ${employee.employeeAge.isNotEmpty ? employee.employeeAge : 'N/A'}',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeDetailWidget(
                            key: ValueKey(employee.id),
                            id: employee.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
