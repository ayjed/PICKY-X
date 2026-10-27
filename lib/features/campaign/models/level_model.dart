/// Domain model representing a distinct Campaign Level in the Saga progression.
class LevelModel {
  final int id;
  final int worldNumber;
  final String worldName;
  final int gridRows;
  final int gridCols;
  final int maxMoves;
  final int star3MinMovesRemaining;
  final int star2MinMovesRemaining;
  final int rewardCoins;
  final int rewardGems;
  final int? timeLimitSeconds;
  final bool hasIceObstacles;
  final bool hasBombObstacles;

  const LevelModel({
    required this.id,
    required this.worldNumber,
    required this.worldName,
    required this.gridRows,
    required this.gridCols,
    required this.maxMoves,
    required this.star3MinMovesRemaining,
    required this.star2MinMovesRemaining,
    this.rewardCoins = 30,
    this.rewardGems = 1,
    this.timeLimitSeconds,
    this.hasIceObstacles = false,
    this.hasBombObstacles = false,
  });

  int get totalCards => gridRows * gridCols;
  int get totalPairs => totalCards ~/ 2;

  /// Calculates stars earned (1, 2, or 3) based on moves remaining upon completion.
  int calculateStars(int movesRemaining) {
    if (movesRemaining >= star3MinMovesRemaining) {
      return 3;
    } else if (movesRemaining >= star2MinMovesRemaining) {
      return 2;
    } else {
      return 1;
    }
  }
}
