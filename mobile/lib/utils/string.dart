
List<String> toStringList(dynamic list) =>
  (list as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    }
}