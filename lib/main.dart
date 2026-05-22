import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  await apiService.initialize();
  runApp(
    Provider<ApiService>.value(
      value: apiService,
      child: const CoachApp(),
    ),
  );
}
