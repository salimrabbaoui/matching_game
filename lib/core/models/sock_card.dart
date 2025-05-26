class SockCard {
  final String imagePath;
  final String name;
  final bool isMatched;
  final bool isFlipped;

  const SockCard({
    required this.imagePath,
    required this.name,
    this.isMatched = false,
    this.isFlipped = false,
  });

  SockCard copyWith({
    String? imagePath,
    String? name,
    bool? isMatched,
    bool? isFlipped,
  }) {
    return SockCard(
      imagePath: imagePath ?? this.imagePath,
      name: name ?? this.name,
      isMatched: isMatched ?? this.isMatched,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SockCard &&
        other.imagePath == imagePath &&
        other.name == name;
  }

  @override
  int get hashCode => imagePath.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'SockCard(imagePath: $imagePath, name: $name, isMatched: $isMatched, isFlipped: $isFlipped)';
  }
}
