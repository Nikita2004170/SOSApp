import 'package:shared_preferences/shared_preferences.dart';

class EmergencyNumberHelper {
  static const _key = 'emergencyNumber';

  static Future<void> saveEmergencyNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, number);
  }

  static Future<String?> getEmergencyNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}
