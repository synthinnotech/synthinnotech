import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:synthinnotech/main.dart';
import 'package:synthinnotech/service/police_service.dart';
import 'package:synthinnotech/service/theme_service.dart';
import 'package:synthinnotech/view/login_page.dart';

class PolicyAcceptanceScreen extends ConsumerWidget {
  const PolicyAcceptanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool acceptTerms = ref.watch(PoliceService.terms);
    bool acceptPrivacy = ref.watch(PoliceService.policy);

    bool canContinue = acceptTerms && acceptPrivacy;
    bool isDark = ref.watch(ThemeService.isDarkTheme);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Terms & Privacy',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            isDark ? Colors.grey.withAlpha(50) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 10,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.security, size: 48, color: baseColor1),
                          SizedBox(height: 16),
                          Text(
                            'Privacy & Terms',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please review and accept our policies to continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    _buildPolicySection(
                      title: 'Terms of Service',
                      isDark: isDark,
                      description:
                          'Our terms outline the rules and guidelines for using our app.',
                      highlights: [
                        'Account responsibilities',
                        'Usage guidelines',
                        'Service availability',
                        'Limitation of liability',
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildPolicySection(
                      title: 'Privacy Policy',
                      isDark: isDark,
                      description:
                          'We are committed to protecting your privacy and personal data.',
                      highlights: [
                        'Data collection practices',
                        'Information usage',
                        'Third-party sharing',
                        'Your privacy rights',
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildCheckboxTile(
                      value: acceptTerms,
                      isDark: isDark,
                      onChanged: (value) =>
                          ref.read(PoliceService.terms.notifier).state = value!,
                      title: 'Terms of Service',
                      linkText: 'Read full terms',
                    ),
                    SizedBox(height: 10),
                    _buildCheckboxTile(
                      isDark: isDark,
                      value: acceptPrivacy,
                      onChanged: (value) => ref
                          .read(PoliceService.policy.notifier)
                          .state = value!,
                      title: 'Privacy Policy',
                      linkText: 'Read full policy',
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: canContinue
                      ? () {
                          Get.off(() => LoginPage(),
                              transition: Transition.downToUp);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canContinue ? baseColor1 : Colors.grey[300],
                    foregroundColor: Colors.white,
                    elevation: canContinue ? 2 : 0,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(
      {required String title,
      required String description,
      required bool isDark,
      required List<String> highlights}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.withAlpha(50) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.grey.withAlpha(80) : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          SizedBox(height: 12),
          ...highlights.map(
            (highlight) => Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: baseColor1),
                  SizedBox(width: 8),
                  Text(
                    highlight,
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(
      {required bool value,
      required ValueChanged<bool?> onChanged,
      required String title,
      required bool isDark,
      required String linkText}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.withAlpha(50) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? baseColor1
              : isDark
                  ? Colors.grey.withAlpha(80)
                  : Colors.grey[300]!,
          width: value ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: baseColor1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: isDark ? Colors.white : Colors.black),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                      text: title,
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: '. '),
                  TextSpan(
                    text: linkText,
                    style: TextStyle(color: baseColor1),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
