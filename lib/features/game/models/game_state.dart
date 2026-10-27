import 'dart:math';
import 'card_model.dart';

enum GameStatus {
  idle,
  playing,
  completed,
  outOfMoves,
  failed,
}

/// Immutable snapshot representing the full game state in Level & Arcade modes.
class GameState {
  final List<CardModel> deck;
  final int? firstSelectedIndex;
  final int? secondSelectedIndex;
  final bool isInputLocked;
  final int moves;
  final int matchedPairs;
  final int totalPairs;
  final int elapsedSeconds;
  final GameStatus status;
  final int? maxMoves; // null in infinite/arcade mode, int in level mode
  final int? timeLimitSeconds;
  final int? levelId;
  final bool isPeekActive;

  const GameState({
    required this.deck,
    this.firstSelectedIndex,
    this.secondSelectedIndex,
    this.isInputLocked = false,
    this.moves = 0,
    this.matchedPairs = 0,
    this.totalPairs = 8,
    this.elapsedSeconds = 0,
    this.status = GameStatus.idle,
    this.maxMoves,
    this.timeLimitSeconds,
    this.levelId,
    this.isPeekActive = false,
  });

  bool get isCompleted => matchedPairs == totalPairs && totalPairs > 0;

  int get movesRemaining {
    if (maxMoves == null) return 999;
    return max(0, maxMoves! - moves);
  }

  int get secondsRemaining {
    if (timeLimitSeconds == null) return 999;
    return max(0, timeLimitSeconds! - elapsedSeconds);
  }

  bool get isLowOnMoves => maxMoves != null && movesRemaining <= 3 && movesRemaining > 0;

  GameState copyWith({
    List<CardModel>? deck,
    int? firstSelectedIndex,
    int? secondSelectedIndex,
    bool clearFirstSelection = false,
    bool clearSecondSelection = false,
    bool? isInputLocked,
    int? moves,
    int? matchedPairs,
    int? totalPairs,
    int? elapsedSeconds,
    GameStatus? status,
    int? maxMoves,
    int? timeLimitSeconds,
    int? levelId,
    bool? isPeekActive,
  }) {
    return GameState(
      deck: deck ?? this.deck,
      firstSelectedIndex: clearFirstSelection ? null : (firstSelectedIndex ?? this.firstSelectedIndex),
      secondSelectedIndex: clearSecondSelection ? null : (secondSelectedIndex ?? this.secondSelectedIndex),
      isInputLocked: isInputLocked ?? this.isInputLocked,
      moves: moves ?? this.moves,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      totalPairs: totalPairs ?? this.totalPairs,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      status: status ?? this.status,
      maxMoves: maxMoves ?? this.maxMoves,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      levelId: levelId ?? this.levelId,
      isPeekActive: isPeekActive ?? this.isPeekActive,
    );
  }
}
