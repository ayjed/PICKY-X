import 'package:flutter_test/flutter_test.dart';
import 'package:picky_x/features/game/controllers/game_controller.dart';
import 'package:picky_x/features/game/models/game_state.dart';

void main() {
  group('GameController & State Machine Tests', () {
    test('Deck initialization contains exactly 16 cards (8 pairs)', () {
      final controller = GameController();
      expect(controller.deck.length, 16);
      expect(controller.totalPairs, 8);
      expect(controller.moves, 0);
      expect(controller.matchedPairs, 0);
      expect(controller.elapsedSeconds, 0);
      expect(controller.isInputLocked, false);
      expect(controller.status, GameStatus.idle);

      // Verify each pair key appears exactly twice
      final pairCounts = <String, int>{};
      for (final card in controller.deck) {
        pairCounts[card.pairKey] = (pairCounts[card.pairKey] ?? 0) + 1;
      }
      expect(pairCounts.length, 8);
      for (final count in pairCounts.values) {
        expect(count, 2);
      }
    });

    test('Moves counter increments once per two-card attempt', () {
      final controller = GameController();

      // First tap reveals card 0
      controller.handleCardTap(0);
      expect(controller.deck[0].isFaceUp, true);
      expect(controller.moves, 0); // No move counted yet

      // Second tap reveals card 1 -> completes 1 attempt
      controller.handleCardTap(1);
      expect(controller.moves, 1);
    });

    test('Matching pair stays revealed and increments matchedPairs count', () {
      bool matchEventFired = false;
      final controller = GameController(
        onMatch: () => matchEventFired = true,
      );

      // Locate two cards with the same pairKey
      final firstKey = controller.deck[0].pairKey;
      int secondIdx = -1;
      for (int i = 1; i < controller.deck.length; i++) {
        if (controller.deck[i].pairKey == firstKey) {
          secondIdx = i;
          break;
        }
      }
      expect(secondIdx, isNonNegative);

      controller.handleCardTap(0);
      controller.handleCardTap(secondIdx);

      expect(controller.deck[0].isMatched, true);
      expect(controller.deck[secondIdx].isMatched, true);
      expect(controller.matchedPairs, 1);
      expect(matchEventFired, true);
      expect(controller.isInputLocked, false);
    });

    test('Mismatch locks input and resets face-down after delay', () async {
      bool mismatchEventFired = false;
      final controller = GameController(
        mismatchDelayMs: 50, // Short delay for unit test
        onMismatch: () => mismatchEventFired = true,
      );

      // Locate two cards with different pairKeys
      final firstKey = controller.deck[0].pairKey;
      int differentIdx = -1;
      for (int i = 1; i < controller.deck.length; i++) {
        if (controller.deck[i].pairKey != firstKey) {
          differentIdx = i;
          break;
        }
      }
      expect(differentIdx, isNonNegative);

      controller.handleCardTap(0);
      controller.handleCardTap(differentIdx);

      expect(controller.isInputLocked, true);
      expect(mismatchEventFired, true);

      // During lock, tapping another card should be ignored
      controller.handleCardTap(2);
      expect(controller.moves, 1);

      // Wait for mismatch delay to complete
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(controller.isInputLocked, false);
      expect(controller.deck[0].isFaceUp, false);
      expect(controller.deck[differentIdx].isFaceUp, false);
    });

    test('Completing all 8 pairs triggers onWin and completes status', () {
      bool winEventFired = false;
      final controller = GameController(
        onWin: () => winEventFired = true,
      );

      // Group card indices by pairKey
      final pairsMap = <String, List<int>>{};
      for (int i = 0; i < controller.deck.length; i++) {
        final key = controller.deck[i].pairKey;
        pairsMap.putIfAbsent(key, () => []).add(i);
      }

      // Match all 8 pairs
      for (final entry in pairsMap.entries) {
        final indices = entry.value;
        controller.handleCardTap(indices[0]);
        controller.handleCardTap(indices[1]);
      }

      expect(controller.matchedPairs, 8);
      expect(controller.moves, 8);
      expect(controller.status, GameStatus.completed);
      expect(winEventFired, true);
    });

    test('Restart resets all game metrics and reshuffles', () {
      final controller = GameController();
      controller.handleCardTap(0);
      expect(controller.deck[0].isFaceUp, true);

      controller.resetGame();
      expect(controller.moves, 0);
      expect(controller.matchedPairs, 0);
      expect(controller.elapsedSeconds, 0);
      expect(controller.status, GameStatus.idle);
      expect(controller.deck.every((c) => !c.isFaceUp && !c.isMatched), true);
    });
  });
}
