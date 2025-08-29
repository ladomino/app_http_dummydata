import 'package:app_http_dummydata/ui/pages/employee_detail.dart';
import 'package:flutter/material.dart';
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
            onPressed: () => {},
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
                return ListTile(
                  key: ValueKey(employee.id),
                  title: Text(
                    employee.employeeName.isNotEmpty
                        ? employee.employeeName
                        : 'Unknown',
                  ),
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
                );
              },
            );
          }
        },
      ),
    );
  }
}
