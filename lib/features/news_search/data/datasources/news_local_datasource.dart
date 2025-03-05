import 'package:shared_preferences/shared_preferences.dart';

class NewsLocalDataSource {
  final SharedPreferences sharedPreferences;

  NewsLocalDataSource(this.sharedPreferences);

  Future<List<String>> getSearchHistory() async {
    return sharedPreferences.getStringList('search_history') ?? [];
  }

  Future<void> saveSearchQuery(String query) async {
    final history = await getSearchHistory();
    if (!history.contains(query)) {
      history.insert(0, query);
      await sharedPreferences.setStringList('search_history', history.take(10).toList());
    }
  }
}
