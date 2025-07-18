import 'package:dance_sf/utils/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dance_shared/dance_shared.dart';

enum VerifyScreenType {
  giveRating,
  addEvent,
  editEvent,
  voteOnProposal,
  none,
}

class VerifyScreen extends ConsumerStatefulWidget {
  final String? nextRoute;
  final extra;
  const VerifyScreen({super.key, this.nextRoute, this.extra});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final TextEditingController _countryCodeController =
      TextEditingController(text: '+${AppStorage.countryCode}');
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

  VerifyScreenType get _verifyScreenType => widget.extra is Map ? (widget.extra as Map)['verifyScreenType'] as VerifyScreenType? ?? VerifyScreenType.none : VerifyScreenType.none;

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
      if (!mounted) return;
      if (widget.nextRoute != null) {
        if (widget.nextRoute == '/back') {
          context.pop(true);
        } else {
          await context.push(widget.nextRoute!);
          if (!mounted) return;
          context.pop(true);
        }
      } else {
        context.pop(true);
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
    final l10n = AppLocalizations.of(context)!;
    switch (_verifyScreenType) {
      case VerifyScreenType.giveRating:
        return l10n.verifyMessageRate;
      case VerifyScreenType.addEvent:
        return l10n.verifyMessageAdd;
      case VerifyScreenType.editEvent:
        return l10n.verifyMessageEdit;
      case VerifyScreenType.none:
        return l10n.verifyMessage;
      case VerifyScreenType.voteOnProposal:
        return l10n.verifyMessageVote;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(l10n.verifyTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 18)),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
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
                        hintText: '+${AppStorage.countryCode}',
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
                        hintText: AppStorage.zone == 'San Francisco' ? '234 5323 212' : '55 1234 5678',
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
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary))
                    : Text(l10n.send,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            fontFamily: "Inter")),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),
                Text(
                  l10n.enterOTPCode,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary, fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: l10n.otpCode,
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
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: const CircularProgressIndicator(color: Colors.white))
                      : Text(l10n.verify,
                          style:
                              const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
