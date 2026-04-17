import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Khởi tạo GoRouter
final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text(
            'VitaminC Base Frame Ready!\nNhóm bắt đầu chia task thôi!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  ],
);