// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Example settings states
  bool _wifi = true;
  bool _bluetooth = false;
  bool _notifications = true;
  bool _darkMode = false;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Listen to authentication state
  late final Stream<User?> _authStateChanges;

  @override
  void initState() {
    super.initState();
    _authStateChanges = _auth.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: StreamBuilder<User?>(
        stream: _authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking auth state
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            // User is logged in
            return _buildLoggedInSettings(snapshot.data);
          } else {
            // User is not logged in
            return _buildLoggedOutSettings();
          }
        },
      ),
    );
  }

  /// Builds the settings view for logged-in users
  Widget _buildLoggedInSettings(User? user) {
    return ListView(
      children: [
        // Account Section
        _buildSectionHeader('Account'),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          subtitle: Text(user?.email ?? 'No Email'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _navigateTo(context, 'Profile');
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Privacy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _navigateTo(context, 'Privacy');
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _logout,
        ),

        // Connectivity Section
        _buildSectionHeader('Connectivity'),
        SwitchListTile(
          secondary: const Icon(Icons.wifi),
          title: const Text('Wi-Fi'),
          value: _wifi,
          onChanged: (bool value) {
            setState(() {
              _wifi = value;
            });
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.bluetooth),
          title: const Text('Bluetooth'),
          value: _bluetooth,
          onChanged: (bool value) {
            setState(() {
              _bluetooth = value;
            });
          },
        ),

        // Notifications Section
        _buildSectionHeader('Notifications'),
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          value: _notifications,
          onChanged: (bool value) {
            setState(() {
              _notifications = value;
            });
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.brightness_6),
          title: const Text('Dark Mode'),
          value: _darkMode,
          onChanged: (bool value) {
            setState(() {
              _darkMode = value;
              // Implement theme switching logic here if needed
            });
          },
        ),

        // About Section
        _buildSectionHeader('About'),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _navigateTo(context, 'About');
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _navigateTo(context, 'Help & Support');
          },
        ),
      ],
    );
  }

  /// Builds the settings view for logged-out users
  Widget _buildLoggedOutSettings() {
    return ListView(
      children: [
        // Authentication Section
        _buildSectionHeader('Authentication'),
        ListTile(
          leading: const Icon(Icons.login),
          title: const Text('Login'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.app_registration),
          title: const Text('Register'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
        ),

        // Connectivity Section
        _buildSectionHeader('Connectivity'),
        SwitchListTile(
          secondary: const Icon(Icons.wifi),
          title: const Text('Wi-Fi'),
          value: _wifi,
          onChanged: (bool value) {
            setState(() {
              _wifi = value;
            });
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.bluetooth),
          title: const Text('Bluetooth'),
          value: _bluetooth,
          onChanged: (bool value) {
            setState(() {
              _bluetooth = value;
            });
          },
        ),

        // Notifications Section
        _buildSectionHeader('Notifications'),
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          value: _notifications,
          onChanged: (bool value) {
            setState(() {
              _notifications = value;
            });
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.brightness_6),
          title: const Text('Dark Mode'),
          value: _darkMode,
          onChanged: (bool value) {
            setState(() {
              _darkMode = value;
              // Implement theme switching logic here if needed
            });
          },
        ),

        // About Section
        _buildSectionHeader('About'),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _navigateTo(context, 'About');
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _navigateTo(context, 'Help & Support');
          },
        ),
      ],
    );
  }

  /// Handles logout functionality
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully logged out')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  /// Builds a section header with the given [title].
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Handles navigation to different settings pages.
  void _navigateTo(BuildContext context, String pageName) {
    // Placeholder for navigation logic
    // Replace with actual navigation code as needed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pageName),
        content: Text('Navigate to $pageName page'),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}