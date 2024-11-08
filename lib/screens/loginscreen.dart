import 'package:endroid/screens/loginform.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(16),
          child: screenWidth > 600
              ? Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'lib/assets/main.png', // Make sure to add your logo in the assets folder
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: LoginForm(),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/main.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    const LoginForm(),
                  ],
                ),
        ),
      ),
    );
  }
}
