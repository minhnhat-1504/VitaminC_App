import 'package:flutter/material.dart';
import '../../../../core/shared_widgets/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Hồ sơ cá nhân"),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          const Center(child: Text("Người dùng VitaminC", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Chế độ tối"),
            trailing: Switch(value: false, onChanged: (val) {}),
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Thông báo nhắc học"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
          const ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Đăng xuất", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}