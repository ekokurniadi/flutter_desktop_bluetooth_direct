import 'package:shared_preferences/shared_preferences.dart';

class App{
  const App._();
  static late SharedPreferences sharedPreferences;

  static Future<void> init()async{
    sharedPreferences = await SharedPreferences.getInstance();
  }
}