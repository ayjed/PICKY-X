import '../models/level_model.dart';

/// Catalog of 60 handcrafted, progressive Campaign Levels across 5 distinct Worlds.
class LevelCatalog {
  LevelCatalog._();

  static final List<LevelModel> levels = _generateAllLevels();

  static LevelModel getLevel(int levelNumber) {
    if (levelNumber < 1) return levels.first;
    if (levelNumber > levels.length) return levels.last;
    return levels[levelNumber - 1];
  }

  static List<LevelModel> getLevelsForWorld(int worldNumber) {
    return levels.where((l) => l.worldNumber == worldNumber).toList();
  }

  static List<LevelModel> _generateAllLevels() {
    final List<LevelModel> list = [];

    final worlds = [
      (1, 'Neon Meadow', 1, 12),
      (2, 'Cyber City', 13, 24),
      (3, 'Crystal Caverns', 25, 36),
      (4, 'Solar Forge', 37, 48),
      (5, 'Cosmic Core', 49, 60),
    ];

    for (final w in worlds) {
      final worldNum = w.$1;
      final worldName = w.$2;
      final start = w.$3;
      final end = w.$4;

      for (int i = start; i <= end; i++) {
        int rows = 4;
        int cols = 4;
        int maxMoves = 16;
        int star3Min = 5;
        int star2Min = 2;
        int coins = 25 + (worldNum * 5);
        int gems = (i == end) ? 5 : (i % 6 == 0 ? 2 : 1);
        bool ice = false;
        bool bomb = false;
        int? timeLimit;

        if (worldNum == 1) {
          // World 1: Gentle ramp-up (2x3 -> 2x4 -> 3x4 -> 4x4)
          if (i <= 3) {
            rows = 2;
            cols = 3; // 6 cards, 3 pairs
            maxMoves = 8;
            star3Min = 3;
            star2Min = 1;
          } else if (i <= 6) {
            rows = 2;
            cols = 4; // 8 cards, 4 pairs
            maxMoves = 10;
            star3Min = 4;
            star2Min = 2;
          } else if (i <= 9) {
            rows = 3;
            cols = 4; // 12 cards, 6 pairs
            maxMoves = 14;
            star3Min = 5;
            star2Min = 2;
          } else {
            rows = 4;
            cols = 4; // 16 cards, 8 pairs
            maxMoves = 18;
            star3Min = 6;
            star2Min = 2;
          }
        } else if (worldNum == 2) {
          // World 2: Standard 4x4 with tightening moves & ice cards
          rows = 4;
          cols = 4; // 16 cards, 8 pairs
          maxMoves = 16 - ((i - start) ~/ 4);
          star3Min = 5;
          star2Min = 2;
          ice = i >= 18;
        } else if (worldNum == 3) {
          // World 3: 4x4 & 4x5 grids + time limits
          if (i % 2 == 0) {
            rows = 4;
            cols = 4;
            maxMoves = 14;
          } else {
            rows = 4;
            cols = 5; // 20 cards, 10 pairs
            maxMoves = 20;
          }
          star3Min = 4;
          star2Min = 1;
          ice = true;
          if (i == end) timeLimit = 60; // 60-second boss rush
        } else if (worldNum == 4) {
          // World 4: 4x5 grids with bombs and ice
          rows = 4;
          cols = 5; // 20 cards, 10 pairs
          maxMoves = 18 - ((i - start) ~/ 4);
          star3Min = 4;
          star2Min = 1;
          ice = true;
          bomb = i >= 42;
        } else {
          // World 5: 6x6 Master stages (36 cards, 18 pairs)
          rows = 6;
          cols = 6;
          maxMoves = 36 - ((i - start) ~/ 2);
          star3Min = 6;
          star2Min = 2;
          ice = true;
          bomb = true;
          if (i == end) {
            coins = 200;
            gems = 10;
          }
        }

        list.add(LevelModel(
          id: i,
          worldNumber: worldNum,
          worldName: worldName,
          gridRows: rows,
          gridCols: cols,
          maxMoves: maxMoves,
          star3MinMovesRemaining: star3Min,
          star2MinMovesRemaining: star2Min,
          rewardCoins: coins,
          rewardGems: gems,
          timeLimitSeconds: timeLimit,
          hasIceObstacles: ice,
          hasBombObstacles: bomb,
        ));
      }
    }

    return list;
  }
}
