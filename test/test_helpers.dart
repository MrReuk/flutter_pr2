import 'package:library_app/app_repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppRepositories> makeRepositories([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(Map<String, Object>.of(initial));
  final prefs = await SharedPreferences.getInstance();
  return AppRepositories(prefs, delay: Duration.zero);
}
