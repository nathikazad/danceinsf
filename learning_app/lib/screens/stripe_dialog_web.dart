import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_shared/auth/auth_service.dart';
import 'package:learning_app/screens/login_dialog.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';
import 'package:learning_app/utils/stripe_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class StripePaymentDialog extends ConsumerStatefulWidget {
  const StripePaymentDialog({super.key});

  @override
  ConsumerState<StripePaymentDialog> createState() => _StripePaymentDialogState();
}

class _StripePaymentDialogState extends ConsumerState<StripePaymentDialog> {
  bool _isLoading = false;
  String? _error;
  bool _paymentSuccess = false;
  Map<String, dynamic>? paymentIntentData;
  String? _clientSecret;
  bool _webStripeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebStripe();
  }

  Future<void> _initializeWebStripe() async {
    if (!_webStripeInitialized) {
      try {
        await WebStripe.instance.initialise(
          publishableKey: 'pk_test_51RgHPYQ3gDIZndwWrWx1aNclnFjsh6E3v01vBdNZAfqMEw1ZEAshkauhbtObKB7F3U9OVp7RNpgMhJy7uT2NcV6U00KQIWykjt',
        );
        _webStripeInitialized = true;
      } catch (e) {
        print('WebStripe initialization failed: $e');
      }
    }
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

      setState(() {
        _isLoading = false;
      });
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

  Future<void> _handleWebPayment() async {
    try {
      setState(() {
        _isLoading = true;
      });
      debugPrint("confirming payment");
      await WebStripe.instance.confirmPaymentElement(
        ConfirmPaymentElementOptions(
          confirmParams: ConfirmPaymentParams(return_url: StripeUtil.getReturnUrl()),
          redirect: PaymentConfirmationRedirect.ifRequired,
        ),
      );
      debugPrint("payment confirmed");
      // Get payment intent ID from the data we created earlier
      final paymentIntentId = paymentIntentData?['payment_intent_id'];
      if (paymentIntentId != null) {
        debugPrint("confirming payment with id: $paymentIntentId");
        await StripeUtil.confirmPayment(paymentIntentId, 990, "mxn", 1);
      }
      
      // Invalidate the userHasPaymentProvider to refresh the payment status
      ref.invalidate(userHasPaymentProvider);
      
      // Wait for the provider to refetch and confirm payment status
      await ref.read(userHasPaymentProvider.future);
      
      setState(() {
        _paymentSuccess = true;
        _isLoading = false;
      });

      // Close dialog after success
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop();
          final screenWidth = MediaQuery.of(context).size.width;
          final isDesktop = screenWidth > 600; // Using 600px threshold as in landing page
          if (isDesktop) {
            context.go('/desktop-video');
          } else {
            context.go('/mobile-video');
          }
        }
      });
    } catch (error) {
      debugPrint("Error _handleWebPayment: $error");
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildWebPaymentElement() {
    if (_clientSecret == null) return const SizedBox.shrink();
    
    return PaymentElement(
      autofocus: true,
      enablePostalCode: true,
      onCardChanged: (_) {},
      clientSecret: _clientSecret!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authProvider);
    final user = auth.user;
    final l10n = AppLocalizations.of(context)!;
    final orange = Colors.orange[700]!;
    final brown = const Color(0xFF6D4C41);
    final white = Colors.white;

    return Dialog(
      backgroundColor: white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
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
                l10n.completeYourPurchase,
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
                  l10n.paymentSuccessful,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.paymentSuccessMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: brown),
                ),
              ] else if (user == null) ...[
                // Show login required message
                Icon(Icons.lock, color: orange, size: 64),
                const SizedBox(height: 16),
                Text(
                  l10n.loginRequired,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: brown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginRequiredMessage,
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
                    child: Text(l10n.loginToContinue, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                Text(
                  l10n.bachataCoursePrice,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: brown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.courseDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: brown.withOpacity(0.7)),
                ),
                const SizedBox(height: 24),
                // Web platform - show PaymentElement
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(l10n.errorOccurred, style: TextStyle(color: orange)),
                  ),
                if (_clientSecret != null) ...[
                  _buildWebPaymentElement(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _handleWebPayment(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.payAmount, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => makePayment(990),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.continueToPayment, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  l10n.securePaymentMessage,
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