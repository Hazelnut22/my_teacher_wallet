import 'package:flutter/material.dart';
import 'package:my_teacher_wallet/core/app_flavor.dart';
import 'package:my_teacher_wallet/main.dart';

Future<void> main() async {
  AppFlavor.appFlavor = Flavor.dev;
  WidgetsFlutterBinding.ensureInitialized();
  
  await mainApp();
}