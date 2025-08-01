import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class UserPaymentService {
  static UserPaymentService? _instance;
  static UserPaymentService get instance {
    _instance ??= UserPaymentService._internal();
    return _instance!;
  }
  
  bool? _currentValue;
  bool _isLoading = false;
  final StreamController<bool> _streamController = StreamController<bool>.broadcast();
  
  // Getters
  bool? get currentValue => _currentValue;
  bool get isLoading => _isLoading;
  Stream<bool> get stream => _streamController.stream;
  
  // Private constructor - fetch on init
  UserPaymentService._internal() {
    fetch();
  }

    // Async function to get payment status - waits for fetch if null
  Future<bool> getPaymentStatus() async {
    // If value is null, wait for fetch to complete
    if (_currentValue == null) {
      await stream.first;
    }
    return _currentValue ?? false;
  }
  
  // Fetch payment status asynchronously
  Future<bool> fetch() async {
    if (_isLoading) {
      debugPrint("user_payments: Already loading, waiting for current fetch to complete");
      // If already loading, wait for current fetch to complete
      return stream.first;
    }
    
    _isLoading = true;
    _streamController.add(_currentValue ?? false); // Notify current state
    
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint("user_payments: No user found, setting current value to false");
        _currentValue = false;
        _isLoading = false;
        _streamController.add(false);
        return false;
      }
      
      debugPrint("user_payments: Checking payment for user: $userId");
      
      final response = await Supabase.instance.client
          .schema('money')
          .from('payments')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      debugPrint("user_payments: Payment query result: ${response.length} records found");
      
      _currentValue = response.isNotEmpty;
      _isLoading = false;
      _streamController.add(_currentValue!);
      
      return _currentValue!;
    } catch (error) {
      debugPrint("Error checking user payment: $error");
      _currentValue = false;
      _isLoading = false;
      _streamController.add(false);
      return false;
    }
  }
  
  // Dispose resources
  void dispose() {
    _streamController.close();
  }
}
