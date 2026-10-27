/// Model representing an individual card on the dynamic puzzle grid.
class CardModel {
  final String id;
  final String pairKey;
  final String assetName;
  final String semanticLabel;
  bool isFaceUp;
  bool isMatched;
  bool isIce;
  int iceHitsRemaining;
  bool isBomb;
  int bombMovesRemaining;
  bool isPeekRevealed;

  CardModel({
    required this.id,
    required this.pairKey,
    required this.assetName,
    required this.semanticLabel,
    this.isFaceUp = false,
    this.isMatched = false,
    this.isIce = false,
    this.iceHitsRemaining = 0,
    this.isBomb = false,
    this.bombMovesRemaining = 6,
    this.isPeekRevealed = false,
  });

  bool get isEffectivelyFaceUp => isFaceUp || isPeekRevealed;
  bool get isFrozen => isIce && iceHitsRemaining > 0;

  CardModel copyWith({
    String? id,
    String? pairKey,
    String? assetName,
    String? semanticLabel,
    bool? isFaceUp,
    bool? isMatched,
    bool? isIce,
    int? iceHitsRemaining,
    bool? isBomb,
    int? bombMovesRemaining,
    bool? isPeekRevealed,
  }) {
    return CardModel(
      id: id ?? this.id,
      pairKey: pairKey ?? this.pairKey,
      assetName: assetName ?? this.assetName,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
      isIce: isIce ?? this.isIce,
      iceHitsRemaining: iceHitsRemaining ?? this.iceHitsRemaining,
      isBomb: isBomb ?? this.isBomb,
      bombMovesRemaining: bombMovesRemaining ?? this.bombMovesRemaining,
      isPeekRevealed: isPeekRevealed ?? this.isPeekRevealed,
    );
  }
}
