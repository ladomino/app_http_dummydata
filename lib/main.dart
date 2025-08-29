import 'package:app_http_dummydata/api/api_service.dart';
import 'package:app_http_dummydata/provider_models/employee_model.dart';
import 'package:app_http_dummydata/ui/pages/employee_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const ProviderContainer(child: MyApp()));
}

/// A widget that sets up all providers for the application.
///
/// This widget encapsulates the provider setup logic, making it easier
/// to maintain and modify the provider structure.
class ProviderContainer extends StatelessWidget {
  final Widget child;

  const ProviderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the API service
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, service) => service.dispose(),
        ),

        // Provide the employee provider that depends on the API service
        ChangeNotifierProxyProvider<ApiService, EmployeeProvider>(
          create: (context) => EmployeeProvider(context.read<ApiService>()),
          update: (context, apiService, previous) =>
              previous ?? EmployeeProvider(apiService),
        ),
      ],
      child: child,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        title: 'Flutter Employee Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: EmployeeListWidget(),
      );
  }
}
