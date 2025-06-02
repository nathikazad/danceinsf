import 'package:flutter/material.dart';
import 'package:dance_sf/screens/verify_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<bool> handleRatingVerification(BuildContext context) async {
  if (Supabase.instance.client.auth.currentUser == null) {
    try {
      final result = await GoRouter.of(context).push<bool>('/verify',
          extra: {
            'nextRoute': '/back',
            'verifyScreenType': VerifyScreenType.giveRating});
      if (result != true) {
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Need to verify your phone number to rate events'),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      }
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to verify phone number. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
  }
  return true;
}