// lib/presentation/providers/supabase_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

final supabaseClientProvider =
    Provider<supabase_flutter.SupabaseClient>((ref) {
  return supabase_flutter.Supabase.instance.client;
});
