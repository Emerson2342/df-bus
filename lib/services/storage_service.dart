abstract class StorageService {
  Future<List<String>> getLines();
  Future<void> saveLines(List<String> lines);
  Future<void> addLine(String line);
  Future<void> removeLine(String line);
  Future<void> clearList();
  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool isDarkMode);
}
