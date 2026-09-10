import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Privacy Matters',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last updated: September 2024',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 1
              _buildSection(
                context,
                title: '1. Information We Collect',
                content: '''We collect information you provide directly, such as:
• Name and email address
• Phone number and delivery address
• Payment and transaction history
• Product preferences and shopping history
• Device information and location data

This information helps us provide better service and personalized experience.''',
              ),

              // Section 2
              _buildSection(
                context,
                title: '2. How We Use Your Information',
                content: '''We use your information for:
• Processing orders and deliveries
• Sending order updates and notifications
• Improving our app and services
• Personalized recommendations
• Marketing and promotional offers
• Customer support and communication
• Fraud prevention and security''',
              ),

              // Section 3
              _buildSection(
                context,
                title: '3. Data Security',
                content: '''Your data is protected with:
• Encrypted data transmission
• Secure password storage
• Limited access to personal information
• Regular security audits
• Compliance with data protection laws

We take data security seriously and implement industry-standard measures.''',
              ),

              // Section 4
              _buildSection(
                context,
                title: '4. Sharing Your Information',
                content: '''We may share your information with:
• Delivery partners (for order fulfillment)
• Payment processors (for transactions)
• Service providers (for app maintenance)
• Legal authorities (when required by law)

We do not sell your personal information to third parties.''',
              ),

              // Section 5
              _buildSection(
                context,
                title: '5. Your Rights',
                content: '''You have the right to:
• Access your personal information
• Correct or update your information
• Delete your account and data
• Opt-out of marketing communications
• Request data portability

To exercise these rights, contact us at privacy@abmart.com''',
              ),

              // Section 6
              _buildSection(
                context,
                title: '6. Cookies & Tracking',
                content: '''Our app uses:
• Session cookies for functionality
• Analytics to understand user behavior
• Device identifiers for tracking preferences
• Location data (with your permission)

You can disable cookies in your device settings.''',
              ),

              // Section 7
              _buildSection(
                context,
                title: '7. Changes to This Policy',
                content: '''We may update this privacy policy periodically. We will notify you of significant changes via email or through the app. Continued use of ABMART indicates acceptance of the updated policy.''',
              ),

              // Contact Section
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Questions?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If you have any questions about our privacy practices, please contact us:',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.blue.shade600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.email, size: 16, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'privacy@abmart.com',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.blue.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '+1 (800) 123-4567',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.blue.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Agree Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for reading our privacy policy!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'I Understand & Accept',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                height: 1.6,
              ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
