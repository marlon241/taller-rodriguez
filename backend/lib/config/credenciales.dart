class Credenciales {
  static const String supabaseUrl =
      'https://ukmfbinwpqfribeladhk.supabase.co';
  static const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVrbWZiaW53cHFmcmliZWxhZGhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MDM1MTcsImV4cCI6MjA5NDE3OTUxN30.a12G0hWGAvmZ2bHdtbI3wEvLmShnN6EkfYByHxD879g';
  static const String supabaseServiceKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVrbWZiaW53cHFmcmliZWxhZGhrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3ODYwMzUxNywiZXhwIjoyMDk0MTc5NTE3fQ.mYcMLi_kruTFDlaZdtApXejjjkMP9vtgc2j-Y-RCv68';

  static const String firebaseProjectId = 'taller-rodrigez-db';
  static const String firebaseApiKey =
      'AIzaSyBdq0lKHmo5zmRNX_6Nd_d9tcRSjnG48B0';

  static const String firestoreBaseUrl =
      'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents';
}

class SupabaseHeaders {
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'apikey': Credenciales.supabaseKey,
    'Authorization': 'Bearer ${Credenciales.supabaseKey}',
  };
  
  static Map<String, String> get serviceHeaders => {
    'Content-Type': 'application/json',
    'apikey': Credenciales.supabaseServiceKey,
    'Authorization': 'Bearer ${Credenciales.supabaseServiceKey}',
  };
}