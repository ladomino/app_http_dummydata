import 'package:app_http_dummydata/ui/pages/employee_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_http_dummydata/provider_models/employee_model.dart';

class EmployeeDetailWidget extends StatefulWidget {
  final String id;

  const EmployeeDetailWidget({super.key, required this.id});

  @override
  EmployeeDetailWidgetState createState() => EmployeeDetailWidgetState();
}

class EmployeeDetailWidgetState extends State<EmployeeDetailWidget> {
  @override
  void initState() {
    super.initState();
    debugPrint('Init state employee details for ID: ${widget.id}');
  
    // Fetch employee details when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchEmployee(widget.id);
    });
  }

  @override
  void didUpdateWidget(EmployeeDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch if the ID changes
    if (oldWidget.id != widget.id) {
      debugPrint('Refetching employee details for ID: ${widget.id}');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<EmployeeProvider>().fetchEmployee(widget.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building employee details for ID: ${widget.id}');
    final employeeProvider = context.read<EmployeeProvider>();

    return Scaffold(

      appBar: AppBar(
        title: const Text('Employee Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
         actions: [
          // Add an edit button to the app bar
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to the employee form page with the current employee ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeFormWidget(id: widget.id),
                ),
              ).then((_) {
                // Refresh the employee details when returning from the edit form
                employeeProvider.fetchEmployee(widget.id);
              });
            },
            tooltip: 'Edit Employee',
          ),
        ],
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.error != null && provider.selectedEmployee == null) {
            return Center(child: Text('Error: ${provider.error}'));
          } else if (provider.selectedEmployee == null) {
            return const Center(child: Text('No employee details found'));
          } else {
            final employee = provider.selectedEmployee;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee?.employeeName ?? 'Unknown',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    key: ValueKey(employee?.id),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('ID', employee?.id ?? ''),
                          _buildDetailRow('Age', employee?.employeeAge ?? 'N/A'),
                          _buildDetailRow(
                            'Salary',
                            employee?.employeeSalary ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
