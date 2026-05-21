class Credenciales {
  static const String supabaseUrl =
      'https://ukmfbinwpqfribeladhk.supabase.co/rest/v1/';
  static const String supabaseKey =
      'sb_publishable_gEyPG1zyWhM6lGAsTO3mfw_whu_WU5_';

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