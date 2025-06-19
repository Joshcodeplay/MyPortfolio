import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'homepage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    void _handleLogin() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Centered Animation
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
              child: Column(
                children: [
                  const Text(
                    'StudySync',
                    style: TextStyle(
                      fontSize: 52,  // Increased from 48
                      fontWeight: FontWeight.w800,
                      color: Colors.deepPurple,
                      fontFamily: 'Poppins',
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 240,  // Decreased from 220
                    child: Center(  // Explicitly centered
                      child: Lottie.asset(
                        'assets/animations/study_flow.json',
                        width: MediaQuery.of(context).size.width * 0.8,  // Responsive width
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.school,
                            size: 100,  // Increased from 100
                            color: Colors.deepPurple,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),  // Decreased from 20
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Study better with the right partners. Log in to join your academic community.',
                      textAlign: TextAlign.center,  // Centered text
                      style: TextStyle(
                        fontSize: 18,  // Increased from 16
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),  // Decreased from 40

            // Login Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 30,  // Increased from 28
                          fontWeight: FontWeight.w700,
                          color: Colors.deepPurple,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                            color: Colors.deepPurple,
                            fontFamily: 'Poppins',
                            fontSize: 16,  // Added explicit size
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.deepPurple[300],
                            size: 24,  // Added size
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),  // Decreased from 20
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            color: Colors.deepPurple,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.deepPurple[300],
                            size: 24,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),  // Decreased from 28
                      SizedBox(
                        width: double.infinity,
                        height: 58,  // Increased from 56
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 20,  // Increased from 18
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),  // Kept the same

            // Feature Sections with Larger Animations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildFeatureRow(
                    animation: 'assets/animations/collab_team.json',
                    title: 'Collaborate Smarter',
                    description: 'Study and share with peers in real-time',
                    reverse: false,
                  ),
                  const SizedBox(height: 30),  // Decreased from 40
                  _buildFeatureRow(
                    animation: 'assets/animations/sync_pulse.json',
                    title: 'Sync Your Success',
                    description: 'Connect with like-minded students',
                    reverse: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),  // Kept the same
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required String animation,
    required String title,
    required String description,
    required bool reverse,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (!reverse) ...[
            Expanded(
              flex: 3,  // Changed from 2 to give more space to animation
              child: Lottie.asset(
                animation,
                height: 180,  // Decreased from 200
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.people,
                    size: 100,  // Increased from 80
                    color: Colors.deepPurple,
                  );
                },
              ),
            ),
            const SizedBox(width: 20),  // Decreased from 24
          ],
          Expanded(
            flex: 3,  // Adjusted to balance with larger animation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,  // Increased from 20
                    fontWeight: FontWeight.w700,
                    color: Colors.deepPurple,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),  // Decreased from 12
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,  // Increased from 14
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (reverse) ...[
            const SizedBox(width: 20),  // Decreased from 24
            Expanded(
              flex: 3,
              child: Lottie.asset(
                animation,
                height: 180,  // Decreased from 200
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.sync,
                    size: 100,
                    color: Colors.deepPurple,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}