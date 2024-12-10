import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () {
              // Navigate to Settings screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16.0),
            _buildSectionHeader("Account Information"),
            _buildAccountInformation(),
            const SizedBox(height: 16.0),
            _buildSectionHeader("Camera Preferences"),
            _buildCameraPreferences(),
            const SizedBox(height: 16.0),
            _buildSectionHeader("App Settings"),
            _buildAppSettings(),
          ],
        ),
      ),
    );
  }

  /// Profile header with avatar and basic information
  Widget _buildProfileHeader() {
    return Container(
      color: Colors.deepPurple,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.0,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40.0, color: Colors.deepPurple),
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "John Doe",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text(
                "johndoe@example.com",
                style: TextStyle(fontSize: 16.0, color: Colors.white70),
              ),
              TextButton.icon(
                onPressed: () {
                  // Handle profile edit
                },
                icon: const Icon(Icons.edit, size: 16.0, color: Colors.white),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section header widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Account information section
  Widget _buildAccountInformation() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.email,
            title: "Email",
            subtitle: "johndoe@example.com",
          ),
          _buildListTile(
            icon: Icons.phone,
            title: "Phone",
            subtitle: "+123 456 7890",
          ),
          _buildListTile(
            icon: Icons.lock,
            title: "Change Password",
            subtitle: "Last updated 3 months ago",
            onTap: () {
              // Navigate to change password screen
            },
          ),
        ],
      ),
    );
  }

  /// Camera preferences section
  Widget _buildCameraPreferences() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.camera_alt,
            title: "Default Camera View",
            subtitle: "Grid View (2x2)",
            onTap: () {
              // Handle default camera view settings
            },
          ),
          _buildListTile(
            icon: Icons.notifications,
            title: "Camera Notifications",
            subtitle: "Enabled",
            onTap: () {
              // Handle notifications settings
            },
          ),
        ],
      ),
    );
  }

  /// App settings section
  Widget _buildAppSettings() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            trailing: Switch(
              value: false,
              onChanged: (bool value) {
                // Handle dark mode toggle
              },
            ),
          ),
          _buildListTile(
            icon: Icons.language,
            title: "Language",
            subtitle: "English",
            onTap: () {
              // Navigate to language settings
            },
          ),
          _buildListTile(
            icon: Icons.info,
            title: "About App",
            onTap: () {
              // Navigate to about screen
            },
          ),
        ],
      ),
    );
  }

  /// Helper to build a list tile
  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
