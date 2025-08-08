import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dance_shared/stripe/stripe_util.dart';

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
  final bool production;
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
    required this.production,
  });

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
    Stripe.publishableKey = widget.publishableKey;
    Stripe.instance.applySettings();
  }

  Future<void> makePayment(int amount) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      paymentIntentData = await StripeUtil.createPaymentIntent(
        amount: amount, 
        currency: widget.currency, 
        metadata: widget.metadata, 
        stripeAccountId: widget.stripeAccountId, 
        production: widget.production);
      _clientSecret = paymentIntentData!['client_secret'];
      debugPrint("payment data: $_clientSecret");
      if (widget.stripeAccountId != null) {
        Stripe.stripeAccountId = widget.stripeAccountId;
      }
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
          await StripeUtil.confirmPayment(paymentIntentId, widget.amount, widget.currency, widget.metadata);
        }

        // Call the callback to refresh payment status
        
        
        paymentIntentData = null;
        _clientSecret = null;
        
        setState(() {
          _paymentSuccess = true;
          _isLoading = false;
        });

        // Close dialog after success
        Future.delayed(const Duration(seconds: 2), () async {
          if (mounted) {
            debugPrint("closing dialog");
            Navigator.of(context).pop();
            await widget.postPaymentCallback(ref);
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
                    onPressed: () => makePayment(widget.amount),
                  ),
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