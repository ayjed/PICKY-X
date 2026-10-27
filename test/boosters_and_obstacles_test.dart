import 'package:flutter_test/flutter_test.dart';
import 'package:picky_x/features/campaign/data/level_catalog.dart';
import 'package:picky_x/features/game/controllers/game_controller.dart';
import 'package:picky_x/features/game/models/game_state.dart';

void main() {
  group('Boosters & Obstacles Engine Tests', () {
    test('Peek Booster temporarily reveals unmatched cards', () {
      final controller = GameController();
      expect(controller.state.isPeekActive, false);

      controller.applyPeekBooster();
      expect(controller.state.isPeekActive, true);
      expect(controller.deck.every((c) => c.isEffectivelyFaceUp), true);
    });

    test('Freeze / +Moves Booster increases max allowed moves by 3', () {
      final lvl = LevelCatalog.getLevel(1); // 8 max moves
      final controller = GameController(level: lvl);

      expect(controller.maxMoves, 8);
      controller.applyFreezeBooster();
      expect(controller.maxMoves, 11);
    });

    test('Magic Wand Booster instantly matches and clears an unmatched pair', () {
      final lvl = LevelCatalog.getLevel(1); // 3 pairs total
      final controller = GameController(level: lvl);

      expect(controller.matchedPairs, 0);
      controller.applyWandBooster();
      expect(controller.matchedPairs, 1);
    });

    test('Shuffle Booster rearranges unmatched cards without incrementing moves', () {
      final controller = GameController();
      expect(controller.moves, 0);

      controller.applyShuffleBooster();
      expect(controller.moves, 0);
      expect(controller.deck.length, 16);
    });

    test('Ice cards require a hit to crack before revealing', () {
      // Level 20 has ice obstacles enabled
      final lvl = LevelCatalog.getLevel(20);
      final controller = GameController(level: lvl);

      // Find an ice card
      final iceCardIndex = controller.deck.indexWhere((c) => c.isFrozen);
      if (iceCardIndex != -1) {
        expect(controller.deck[iceCardIndex].iceHitsRemaining, 1);
        expect(controller.deck[iceCardIndex].isFaceUp, false);

        // Tap once to crack ice
        controller.handleCardTap(iceCardIndex);
        expect(controller.deck[iceCardIndex].iceHitsRemaining, 0);
        expect(controller.deck[iceCardIndex].isFaceUp, false); // Still face down, ice cracked

        // Tap second time to flip
        controller.handleCardTap(iceCardIndex);
        expect(controller.deck[iceCardIndex].isFaceUp, true);
      }
    });

    test('Running out of moves triggers onOutOfMoves event', () async {
      bool outOfMovesFired = false;
      final lvl = LevelCatalog.getLevel(1); // 8 max moves
      final controller = GameController(
        level: lvl,
        mismatchDelayMs: 10,
        onOutOfMoves: () => outOfMovesFired = true,
      );

      // Force mismatch until moves reach maxMoves
      for (int move = 0; move < 8; move++) {
        int c1 = -1;
        int c2 = -1;
        for (int i = 0; i < controller.deck.length; i++) {
          for (int j = i + 1; j < controller.deck.length; j++) {
            if (controller.deck[i].pairKey != controller.deck[j].pairKey &&
                !controller.deck[i].isMatched &&
                !controller.deck[j].isMatched) {
              c1 = i;
              c2 = j;
              break;
            }
          }
          if (c1 != -1) break;
        }

        if (c1 != -1 && c2 != -1) {
          controller.handleCardTap(c1);
          controller.handleCardTap(c2);
          await Future<void>.delayed(const Duration(milliseconds: 15));
        }
      }

      expect(controller.moves, 8);
      expect(controller.status, GameStatus.outOfMoves);
      expect(outOfMovesFired, true);
    });
  });
}
