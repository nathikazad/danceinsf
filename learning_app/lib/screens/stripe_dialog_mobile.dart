import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_shared/auth/auth_service.dart';
import 'package:learning_app/screens/login_dialog.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:learning_app/utils/stripe_util.dart';

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
  String? _clientSecret;

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = 'pk_test_51RgHPYQ3gDIZndwWrWx1aNclnFjsh6E3v01vBdNZAfqMEw1ZEAshkauhbtObKB7F3U9OVp7RNpgMhJy7uT2NcV6U00KQIWykjt';
    Stripe.instance.applySettings();
  }

  Future<void> makePayment(int amount) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      paymentIntentData = await StripeUtil.createPaymentIntent(amount, 'usd');
      _clientSecret = paymentIntentData!['client_secret'];
      debugPrint("payment data: $_clientSecret");

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'My Bachata Moves',
          paymentIntentClientSecret: _clientSecret!,
          style: ThemeMode.system,
        ),
      );
      
      // Only proceed to display after successful initialization
      await displayPaymentSheet();
    } catch (error) {
      paymentIntentData = null;
      _clientSecret = null;
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
        debugPrint("paid successfully");

        // Get payment intent ID from the data we created earlier
        final paymentIntentId = paymentIntentData?['payment_intent_id'];
        if (paymentIntentId != null) {
          await StripeUtil.confirmPayment(paymentIntentId, 4900, 1);
        }
        
        paymentIntentData = null;
        _clientSecret = null;
        
        setState(() {
          _paymentSuccess = true;
          _isLoading = false;
        });

        // Close dialog after success
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            debugPrint("closing dialog");
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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
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
                StripeUtil.buildPaymentMethodSelector(
                  selectedPaymentMethod: _selectedPaymentMethod,
                  onPaymentMethodChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_error!, style: TextStyle(color: orange)),
                  ),
                if (_isLoading)
                  const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
                else
                  StripeUtil.buildPaymentButton(
                    selectedPaymentMethod: _selectedPaymentMethod,
                    isLoading: _isLoading,
                    onPressed: () => makePayment(4900),
                  ),
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