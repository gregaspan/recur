import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:recur_application/screens/bottom_navigation_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _wifi = true;
  bool _bluetooth = false;
  bool _notifications = true;
  int currentIndex = 3;
  final PageController pageController = PageController(initialPage: 0);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final Stream<User?> _authStateChanges;

  final String calendarSubscriptionUrl = 'https://calendar.lafayette.edu/category/24/events.ics';

  @override
  void initState() {
    super.initState();
    _authStateChanges = _auth.authStateChanges();
  }

  void navigateToPage(int navBarIndex) {
    if (navBarIndex != currentIndex) {
      setState(() {
        currentIndex = navBarIndex;
      });
      if (navBarIndex == 0) {
        // Navigate to Home
        Navigator.pushReplacementNamed(context, '/');
      } else if (navBarIndex == 1) {
        // Navigate to Progress (reset to first page)
        Navigator.pushReplacementNamed(context, '/progress');
      } else if (navBarIndex == 2) {
        // Navigate to Challenges
        Navigator.pushReplacementNamed(context, '/challenges');
      } else if (navBarIndex == 3) {
        // Navigate to Settings
        pageController.jumpToPage(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
          style: TextStyle(
                    fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: StreamBuilder<User?>(
        stream: _authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return _buildLoggedInSettings(snapshot.data);
          } else {
            return _buildLoggedOutSettings();
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          navigateToPage(index);
        },
      ),
    );
  }

  Future<void> _subscribeToCalendar(BuildContext context) async {
    final Uri url = Uri.parse(calendarSubscriptionUrl);

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch the calendar subscription URL.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Calendar subscription opened. Please check your calendar app.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL: $e')),
      );
    }
  }

  Widget _buildLoggedInSettings(User? user) {
    return ListView(
      children: [
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

        _buildSectionHeader('Calendar'),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Subscribe to Calendar'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _subscribeToCalendar(context),
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

  Widget _buildLoggedOutSettings() {
    return ListView(
      children: [
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

        _buildSectionHeader('Calendar'),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Subscribe to Calendar'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _subscribeToCalendar(context),
        ),

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