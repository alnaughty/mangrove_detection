import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mangrove_classification/mangrove_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MangroveApp());
}
