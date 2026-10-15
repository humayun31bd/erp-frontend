import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
enum OverrideActionType { voidItem, voidCart, highDiscount, priceChange }

class ManagerOverrideService {
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  SharedPreferences? _prefs;
  
  static const String _prefKeyAttempts = 'override_failed_attempts';
  static const String _prefKeyLockout = 'override_lockout_until';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _failedAttempts = _prefs?.getInt(_prefKeyAttempts) ?? 0;
    
    final lockoutStr = _prefs?.getString(_prefKeyLockout);
    if (lockoutStr != null) {
      _lockoutUntil = DateTime.tryParse(lockoutStr);
    }
  }
  
  Future<void> _saveState() async {
    await _prefs?.setInt(_prefKeyAttempts, _failedAttempts);
    if (_lockoutUntil != null) {
      await _prefs?.setString(_prefKeyLockout, _lockoutUntil!.toIso8601String());
    } else {
      await _prefs?.remove(_prefKeyLockout);
    }
  }

  Future<bool> requestOverride({
    required BuildContext context,
    required OverrideActionType actionType,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final secondsLeft = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Security Lockout: Try again in $secondsLeft seconds.'),
             backgroundColor: Colors.red,
           ),
         );
      }
      return false;
    }

    // 1. Show PIN Dialog to Manager
    final String? managerPin = await _showPinDialog(context, actionType);
    
    if (managerPin == null || managerPin.isEmpty) {
      return false; // Cancelled by user
    }

    // 2. Validate PIN against backend
    bool isValid = await _verifyPinWithBackend(managerPin);
    
    if (isValid) {
      _failedAttempts = 0;
      _lockoutUntil = null;
      await _saveState();
      // 3. Log the override in the database
      await _logOverrideAudit(
        actionType: actionType,
        reason: reason,
        metadata: metadata,
        managerId: 'manager_123', // from validated PIN
      );
      return true;
    } else {
      _failedAttempts++;
      
      if (_failedAttempts >= 6) {
         _lockoutUntil = DateTime.now().add(const Duration(minutes: 5));
         _logSecurityEvent('BRUTE_FORCE_ATTEMPT', '6 failed PIN attempts');
      } else if (_failedAttempts >= 3) {
         _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
         _logSecurityEvent('SUSPICIOUS_ACTIVITY', '3 failed PIN attempts');
      }
      
      await _saveState();

      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Invalid Manager PIN. Failed attempts: $_failedAttempts'),
             backgroundColor: Colors.red,
           ),
         );
      }
      return false;
    }
  }

  Future<String?> _showPinDialog(BuildContext context, OverrideActionType actionType) async {
    final TextEditingController pinController = TextEditingController();
    
    String actionName = '';
    switch (actionType) {
      case OverrideActionType.voidItem:
        actionName = 'Void Item';
        break;
      case OverrideActionType.voidCart:
        actionName = 'Void Cart';
        break;
      case OverrideActionType.highDiscount:
        actionName = 'Apply High Discount';
        break;
      case OverrideActionType.priceChange:
        actionName = 'Change Price';
        break;
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Manager Override Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Action: $actionName'),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Manager PIN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                ),
                onSubmitted: (value) {
                  Navigator.of(dialogContext).pop(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(pinController.text),
              child: const Text('AUTHORIZE'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _verifyPinWithBackend(String pin) async {
    try {
      // 1. Try online verification against the API
      // final response = await api.verifyManagerPin(pin);
      // return response.isValid;
      
      // MOCK ONLINE VERIFICATION
      await Future.delayed(const Duration(milliseconds: 500));
      // Simulate network error 50% of the time for testing
      if (DateTime.now().second % 2 == 0) throw Exception('Network Unreachable');
      
      return pin == '1234'; 
    } catch (e) {
      // 2. Fallback to secure offline local cache
      print('Network unavailable or API failed. Falling back to secure local PIN cache...');
      
      // TODO: In production, do NOT store plain text. 
      // Compare against an encrypted local database using:
      // return BCrypt.checkpw(pin, secureBox.get('manager_hash'));
      
      return pin == '1234'; // Mock offline success
    }
  }

  Future<void> _logOverrideAudit({
    required OverrideActionType actionType,
    required String reason,
    Map<String, dynamic>? metadata,
    required String managerId,
  }) async {
    // TODO: Replace with real API Call to /api/manager-override/log
    print('Override Logged: $actionType by $managerId for $reason');
  }

  void _logSecurityEvent(String eventType, String details) {
    // TODO: Replace with real API Call to /api/security/events
    print('SECURITY ALERT [$eventType]: $details');
  }
}

final managerOverrideServiceProvider = Provider<ManagerOverrideService>((ref) {
  return ManagerOverrideService();
});
