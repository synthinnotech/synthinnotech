import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synthinnotech/main.dart';
import 'package:synthinnotech/view/policy_acceptance_screen.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: 0,
                            color: Colors.black.withAlpha(50),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 58,
                          backgroundImage: AssetImage('assets/images/logo.png'),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 1),
                            blurRadius: 5,
                            spreadRadius: 1,
                            color: Colors.black.withAlpha(50),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.withAlpha(65)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Welcome to',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [baseColor1, baseColor3],
                                ).createShader(bounds),
                                child: Text(
                                  'SynthinnoTech',
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Your journey to excellence starts here.\nDiscover amazing features and possibilities.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      height: 1.6,
                                      letterSpacing: 0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.off(() => PolicyAcceptanceScreen(),
                        transition: Transition.rightToLeft);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: baseColor3,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: baseColor3.withAlpha(100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20, color: baseColor2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
