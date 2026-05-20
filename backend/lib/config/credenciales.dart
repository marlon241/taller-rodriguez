class Credenciales {
  static const String supabaseUrl =
      'https://ywztrexdhztdmfceoggx.supabase.co/rest/v1/';
  static const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl3enRyZXhkaHp0ZG1mY2VvZ2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxOTc5MTYsImV4cCI6MjA5NDc3MzkxNn0.3tLJM9tQztDgYbdUP_IMi_-HxuFIjd7oq2ED3FGLv7Y';

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
}
