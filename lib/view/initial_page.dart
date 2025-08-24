import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synthinnotech/main.dart';
import 'package:synthinnotech/view/policy_acceptance_screen.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [baseColor1, baseColor3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              spreadRadius: 1,
                              color: const Color.fromARGB(255, 95, 94, 94),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                AssetImage('assets/images/logo.png')),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Welcome to',
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white.withAlpha(120),
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'SynthinnoTech',
                        style: TextStyle(
                            fontSize: 35,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Your journey to excellence starts here.\nDiscover amazing features and possibilities.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withAlpha(200),
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.off(() => PolicyAcceptanceScreen(),
                              transition: Transition.rightToLeft);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: baseColor3,
                          elevation: 8,
                          shadowColor: Colors.black.withAlpha(80),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
