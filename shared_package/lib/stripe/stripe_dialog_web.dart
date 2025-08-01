import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';
import 'package:dance_shared/stripe/stripe_util.dart';
// import 'package:go_router/go_router.dart';

class StripePaymentDialog extends ConsumerStatefulWidget {
  final Future<void> Function(WidgetRef ref) postPaymentCallback;
  final String publishableKey;
  final String? stripeAccountId;
  final int amount;
  final String currency;
  final String itemTitle;
  final String itemDescription;
  final Map<String, dynamic> metadata;
  final dynamic l10n;
  const StripePaymentDialog({
    super.key,
    required this.postPaymentCallback,
    required this.publishableKey,
    this.stripeAccountId,
    required this.amount,
    required this.currency,
    required this.itemTitle,
    required this.itemDescription,
    required this.metadata,
    required this.l10n,
  });

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
        if (widget.stripeAccountId != null) {
          await WebStripe.instance.initialise(
            publishableKey: widget.publishableKey,
            stripeAccountId: widget.stripeAccountId!,
          );
        } else {
          await WebStripe.instance.initialise(
            publishableKey: widget.publishableKey,
          );
        }
        _webStripeInitialized = true;
      } catch (e) {
        print('WebStripe initialization failed: ${(e as StripeConfigException).message}');
      }
    }
  }

  Future<void> makePayment(int amount) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      paymentIntentData = await StripeUtil.createPaymentIntent(amount, widget.currency, widget.metadata, widget.stripeAccountId);
      _clientSecret = paymentIntentData!['client_secret'];
      debugPrint("payment data: $_clientSecret");

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      paymentIntentData = null;
      _clientSecret = null;
      debugPrint("Error makePayment: $error");
      debugPrint("Error makePayment: ${(error as StripeConfigException).message}");
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
        await StripeUtil.confirmPayment(paymentIntentId, widget.amount, widget.currency, widget.metadata);
      }
      // Call the callback to refresh payment status
      
      setState(() {
        _paymentSuccess = true;
        _isLoading = false;
      });
      // Close dialog after success
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          Navigator.of(context).pop();
          await widget.postPaymentCallback(ref);
        }
      });
    } catch (error) {
      debugPrint("Error _handleWebPayment: ${error.toString()}");
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
    final l10n = widget.l10n;
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
              ] else ...[
                Text(
                  widget.itemTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: brown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.itemDescription,
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
                        : Text(l10n.payAmount(widget.amount ~/ 100, widget.currency.toUpperCase()), style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => makePayment(widget.amount),
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