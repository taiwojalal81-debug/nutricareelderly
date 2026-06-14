// lib/data/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'service_exception.dart';

/// Core Supabase service - handles initialization and provides client
class SupabaseService {
  supabase_flutter.SupabaseClient? _client;

  /// Initialize Supabase with URL and anon key
  Future<void> initialize(String url, String anonKey) async {
    try {
      await supabase_flutter.Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _client = supabase_flutter.Supabase.instance.client;
    } catch (e) {
      throw ServiceException(
        'Failed to initialize Supabase',
        code: 'INIT_ERROR',
        originalException: e,
      );
    }
  }

  /// Get the initialized Supabase client
  supabase_flutter.SupabaseClient get client {
    if (_client == null) {
      throw ServiceException('Supabase is not initialized');
    }
    return _client!;
  }

  /// Set the Supabase client (for dependency injection)
  void setClient(supabase_flutter.SupabaseClient client) {
    _client = client;
  }

  /// Check if service is initialized
  bool get isInitialized => _client != null;
}
