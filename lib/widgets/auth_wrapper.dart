import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/theme_service.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_home.dart';

class AuthWrapper extends StatefulWidget {
  final ThemeService themeService;

  const AuthWrapper({super.key, required this.themeService});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the stream is waiting, show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.data != null && userSnapshot.data!.exists) {
                // User data found, go to Dashboard
                Map<String, dynamic> userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                // Add ID to map if not present
                if (!userData.containsKey('id')) {
                  userData['id'] = snapshot.data!.uid;
                }

                return DashboardHome(
                  user: userData,
                  themeService: widget.themeService,
                );
              } else {
                // User logged in but no Firestore data?
                // Could act as logged out or go to registration/setup.
                // For now, fall back to login/error or sign out.
                FirebaseAuth.instance.signOut();
                return LoginScreen(themeService: widget.themeService);
              }
            },
          );
        }

        // User is not logged in
        return LoginScreen(themeService: widget.themeService);
      },
    );
  }
}
