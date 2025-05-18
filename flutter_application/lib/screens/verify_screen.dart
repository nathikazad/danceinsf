import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth.dart';

enum VerifyScreenType {
  giveRating,
  addEvent,
  editEvent,
  voteOnProposal,
  none,
}

class VerifyScreen extends ConsumerStatefulWidget {
  final String? nextRoute;
  final VerifyScreenType verifyScreenType;
  const VerifyScreen({super.key, this.nextRoute, this.verifyScreenType = VerifyScreenType.none});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final TextEditingController _countryCodeController =
      TextEditingController(text: '+1');
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _countryCodeController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber =>
      '${_countryCodeController.text.trim()}${_phoneController.text.trim().replaceAll(' ', '')}';

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).signInWithPhone(_fullPhoneNumber);
      setState(() {
        _otpSent = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .verifyOTP(_fullPhoneNumber, _otpController.text.trim());
      print('nextRoute: ${widget.nextRoute}');
      if (!mounted) return;
      if (widget.nextRoute != null) {
        if (widget.nextRoute == 'back') {
          context.pop(true);
        } else {
          await context.push(widget.nextRoute!);
          if (!mounted) return;
          context.pop(true);
        }
      } else {
        context.go('/events');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getMessage() {
    switch (widget.verifyScreenType) {
      case VerifyScreenType.giveRating:
        return 'Verify your phone number to rate this event';
      case VerifyScreenType.addEvent:
        return 'Verify your phone number to add an event';
      case VerifyScreenType.editEvent:
        return 'Verify your phone number to edit this event';
      case VerifyScreenType.none:
        return 'Verify your phone number';
      case VerifyScreenType.voteOnProposal:
        return 'Verify your phone number to vote on proposals';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.only(left: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Theme.of(context).colorScheme.secondaryContainer),
            child: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Verify',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                _getMessage(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: TextField(
                    controller: _countryCodeController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '+1',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 5,
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '234 5323 212',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading || _otpSent ? null : _sendOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading && !_otpSent
                  ? CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary)
                  : const Text('Send',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFamily: "Inter")),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              'Enter OTP Code',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'OTP Code',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 12),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading || !_otpSent ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading && _otpSent
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
