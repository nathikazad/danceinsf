import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dance_shared/auth/auth_service.dart';

// Provider to check if user has a payment - reacts to auth changes
final userHasPaymentProvider = FutureProvider<bool>((ref) async {
  // Watch the auth provider to react to login/logout changes
  final authNotifier = ref.watch(authProvider);
  final user = authNotifier.user;
  print('user: ${user?.id}');
  if (user == null) return false;

  try {
    final response = await Supabase.instance.client
        .from('payments')
        .select('id')
        .eq('user_id', user.id)
        .limit(1);

    return response.isNotEmpty;
  } catch (error) {
    debugPrint("Error checking user payment: $error");
    return false;
  }
});

class StripeUtil {
  static Future<Map<String, dynamic>> createPaymentIntent(int amount, String currency) async {
    try {
      // Get the current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to make a purchase');
      }

      // Create payment intent via Supabase Edge Function
      final functionResponse = await Supabase.instance.client.functions.invoke(
        'create_payment_intent',
        body: {
          'amount': amount,
          'currency': currency,
          'payment_method_types': ['card'],
          'metadata': {
            'course_name': 'Bachata Course',
            'user_id': user.id,
          },
        },
      );

      if (functionResponse.status != 200) {
        final errorData = functionResponse.data;
        throw Exception(errorData['error'] ?? 'Failed to create payment intent');
      }

      return functionResponse.data;
    } catch (error) {
      debugPrint("Error createPaymentIntent: $error");
      rethrow;
    }
  }

  static Future<void> confirmPayment(String paymentIntentId, num amount, String currency, int courseId) async {
    try {
      await Supabase.instance.client.functions.invoke(
        'confirm_payment',
        body: {
          'payment_intent_id': paymentIntentId,
          'amount': amount,
          'course_id': courseId,
          'currency': currency,
        },
      );
    } catch (error) {
      debugPrint("Error confirmPayment: $error");
      rethrow;
    }
  }

  static String getReturnUrl() {
    // For web, return the current URL
    return Uri.base.toString();
  }

  static Widget buildPaymentMethodSelector({
    required String selectedPaymentMethod,
    required Function(String) onPaymentMethodChanged,
  }) {
    final orange = Colors.orange[700]!;
    final brown = const Color(0xFF6D4C41);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: brown,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: brown.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(Icons.credit_card, color: orange),
                    const SizedBox(width: 12),
                    const Text('Credit Card'),
                  ],
                ),
                value: 'credit_card',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  onPaymentMethodChanged(value!);
                },
                activeColor: orange,
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(Icons.apple, color: brown),
                    const SizedBox(width: 12),
                    const Text('Apple Pay'),
                  ],
                ),
                value: 'apple_pay',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  onPaymentMethodChanged(value!);
                },
                activeColor: orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget buildPaymentButton({
    required String selectedPaymentMethod,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    final orange = Colors.orange[700]!;
    final white = Colors.white;

    String buttonText = selectedPaymentMethod == 'apple_pay' ? 'Pay with Apple Pay' : 'Pay with Credit Card';
    IconData buttonIcon = selectedPaymentMethod == 'apple_pay' ? Icons.apple : Icons.credit_card;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(buttonIcon, color: white),
        label: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
} 