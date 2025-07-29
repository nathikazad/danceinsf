import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dance_shared/auth/auth_service.dart';
import 'package:flutter/material.dart';
// Provider to check if user has a payment - reacts to auth changes
final userHasPaymentProvider = FutureProvider<bool>((ref) async {
  // Watch the auth provider to react to login/logout changes
  final authNotifier = ref.watch(authProvider);
  final user = authNotifier.user;
  print('user: ${user?.id}');
  if (user == null) return false;

  try {
    final response = await Supabase.instance.client
        .schema('money')
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