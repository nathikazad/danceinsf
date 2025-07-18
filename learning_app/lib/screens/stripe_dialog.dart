import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_shared/auth/auth_service.dart';
import 'package:learning_app/screens/login_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentDialog extends ConsumerStatefulWidget {
  const StripePaymentDialog({super.key});

  @override
  ConsumerState<StripePaymentDialog> createState() => _StripePaymentDialogState();
}

class _StripePaymentDialogState extends ConsumerState<StripePaymentDialog> {
  bool _isLoading = false;
  String? _error;
  bool _paymentSuccess = false;
  String _selectedPaymentMethod = 'credit_card';
  Map<String, dynamic>? paymentIntentData;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
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

  Future<void> makePayment(String amount) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      paymentIntentData = await createPaymentIntent(amount, 'usd');
      debugPrint("payment data: ${paymentIntentData!['client_secret']}");

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'My Bachata Moves',
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          style: ThemeMode.system,
        ),
      ).then((value) async {
        await displayPaymentSheet();
        debugPrint("paid successfully: $value");
      }).onError((error, stackTrace) {
        debugPrint("Error makePayment: $error");
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      });
    } catch (error) {
      paymentIntentData = null;
      debugPrint("Error makePayment: $error");
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
      rethrow;
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        paymentIntentData = null;
        debugPrint("paid successfully");
        await Stripe.instance.confirmPaymentSheetPayment();
        
        setState(() {
          _paymentSuccess = true;
          _isLoading = false;
        });

        // Close dialog after success
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }).onError((error, stackTrace) {
        debugPrint("Error displayPaymentSheet: $error");
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      });
    } on StripeException catch (error) {
      debugPrint("stripe exception $error");
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildPaymentMethodSelector() {
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
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
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
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
                activeColor: orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    final orange = Colors.orange[700]!;
    final white = Colors.white;

    String buttonText = _selectedPaymentMethod == 'apple_pay' ? 'Pay with Apple Pay' : 'Pay with Credit Card';
    IconData buttonIcon = _selectedPaymentMethod == 'apple_pay' ? Icons.apple : Icons.credit_card;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () => makePayment('4900'), // $49.00 in cents
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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.state.user;
    final orange = Colors.orange[700]!;
    final brown = const Color(0xFF6D4C41);
    final white = Colors.white;

    return Dialog(
      backgroundColor: white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: brown),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Complete Your Purchase',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: brown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_paymentSuccess) ...[
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for your purchase. You will receive access to the course shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: brown),
                ),
              ] else if (user == null) ...[
                // Show login required message
                Icon(Icons.lock, color: orange, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Login Required',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: brown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please log in to complete your purchase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: brown.withOpacity(0.7)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close payment dialog
                      showDialog(
                        context: context,
                        builder: (context) => const LoginDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Login to Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                Text(
                  'Bachata Course - \$49',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: brown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get lifetime access to our comprehensive bachata course with unlimited replays.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: brown.withOpacity(0.7)),
                ),
                const SizedBox(height: 24),
                _buildPaymentMethodSelector(),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_error!, style: TextStyle(color: orange)),
                  ),
                if (_isLoading)
                  const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
                else
                  _buildPaymentButton(),
                const SizedBox(height: 12),
                Text(
                  'Secure payment powered by Stripe',
                  style: TextStyle(
                    fontSize: 12,
                    color: brown.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 