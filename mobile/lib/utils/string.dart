List<String> toStringList(dynamic list) =>
  (list as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

extension StringExtension on String {
    String get capitalize {
      if (isEmpty) return this;
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    }

    String get capitalizeWords {
      return split(RegExp(r'[,\s]+'))
          .map((word) => word.trim().capitalize)
          .join(' ');
    }
}