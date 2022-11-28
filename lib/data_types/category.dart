class Category {
  Category({required this.name, required this.emoji});

  String name;
  String emoji;

  @override
  String toString() {
    return emoji + " " + name;
  }
}
