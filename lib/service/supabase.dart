
import 'package:latihankasirapp/service/admin_seeder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> InisialisasiSupabase() async {
  await Supabase.initialize(
    url: 'https://mvofxfrzgixihbrzcjaz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12b2Z4ZnJ6Z2l4aWhicnpjamF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxMDEwMjEsImV4cCI6MjA1MjY3NzAyMX0.5dCjLU0WQKwgTaaceZCI29FLN6ajHXh2jA9FcmTzKQw',
  );
  await seedDataOnce();
}
        