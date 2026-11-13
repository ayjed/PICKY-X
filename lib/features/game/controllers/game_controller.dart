import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_assets.dart';
import '../../campaign/models/level_model.dart';
import '../models/card_model.dart';
import '../models/game_state.dart';

typedef GameEventCallback = void Function();

/// Domain state controller managing the Card Matching engine for both Arcade & Campaign Levels.
class GameController extends ChangeNotifier {
  static const int defaultTotalPairs = 8;
  static const int defaultMismatchDelayMs = 650;

  final LevelModel? level;
  final int mismatchDelayMs;
  final Random _random;

  Timer? _timer;
  Timer? _mismatchTimer;
  Timer? _peekTimer;
  int _sessionId = 0;
  bool _isDisposed = false;
  late GameState _state;

  // Sound & Live-Ops Event Callback Hooks
  GameEventCallback? onFlip;
  GameEventCallback? onMatch;
  GameEventCallback? onMismatch;
  GameEventCallback? onWin;
  GameEventCallback? onOutOfMoves;
  GameEventCallback? onTimeUp;

  GameController({
    this.level,
    int? customTotalPairs,
    this.mismatchDelayMs = defaultMismatchDelayMs,
    Random? random,
    this.onFlip,
    this.onMatch,
    this.onMismatch,
    this.onWin,
    this.onOutOfMoves,
    this.onTimeUp,
  }) : _random = random ?? Random() {
    resetGame();
  }

  GameState get state => _state;
  List<CardModel> get deck => _state.deck;
  int get moves => _state.moves;
  int get matchedPairs => _state.matchedPairs;
  int get totalPairs => _state.totalPairs;
  int get elapsedSeconds => _state.elapsedSeconds;
  bool get isInputLocked => _state.isInputLocked;
  GameStatus get status => _state.status;
  int get movesRemaining => _state.movesRemaining;
  int? get maxMoves => _state.maxMoves;
  bool get isDisposed => _isDisposed;
  bool get hasPendingMismatchTimer => _mismatchTimer != null && _mismatchTimer!.isActive;
  bool get hasPendingPeekTimer => _peekTimer != null && _peekTimer!.isActive;

  void _cancelAllTimers() {
    _timer?.cancel();
    _timer = null;
    _mismatchTimer?.cancel();
    _mismatchTimer = null;
    _peekTimer?.cancel();
    _peekTimer = null;
  }

  /// Resets the game session, cancels timers, and creates a newly shuffled deck.
  void resetGame() {
    _sessionId++;
    _cancelAllTimers();

    final targetPairs = level?.totalPairs ?? defaultTotalPairs;
    final maxAllowedMoves = level?.maxMoves;
    final timeLimit = level?.timeLimitSeconds;

    _state = GameState(
      deck: _generateShuffledDeck(targetPairs),
      totalPairs: targetPairs,
      maxMoves: maxAllowedMoves,
      timeLimitSeconds: timeLimit,
      levelId: level?.id,
      status: GameStatus.idle,
    );
    notifyListeners();
  }

  /// Generates pairs of cards with random shuffle.
  List<CardModel> _generateShuffledDeck(int pairCount) {
    final symbolTemplates = [
      ('ctrl', AppAssets.symbolController, 'Game Controller'),
      ('rkt', AppAssets.symbolRocket, 'Rocket'),
      ('star', AppAssets.symbolStar, 'Star'),
      ('tgt', AppAssets.symbolTarget, 'Target'),
      ('flm', AppAssets.symbolFlame, 'Flame'),
      ('dia', AppAssets.symbolDiamond, 'Diamond'),
      ('crn', AppAssets.symbolCrown, 'Crown'),
      ('lgt', AppAssets.symbolLightning, 'Lightning'),
      // Extended symbols for large grids (5x4, 6x6)
      ('ctrl_b', AppAssets.symbolController, 'Neon Controller'),
      ('rkt_b', AppAssets.symbolRocket, 'Turbo Rocket'),
      ('star_b', AppAssets.symbolStar, 'Gold Star'),
      ('tgt_b', AppAssets.symbolTarget, 'Bullseye'),
      ('flm_b', AppAssets.symbolFlame, 'Inferno Flame'),
      ('dia_b', AppAssets.symbolDiamond, 'Cyan Diamond'),
      ('crn_b', AppAssets.symbolCrown, 'Royal Crown'),
      ('lgt_b', AppAssets.symbolLightning, 'Thunderbolt'),
      ('ctrl_c', AppAssets.symbolController, 'Cyber Pad'),
      ('rkt_c', AppAssets.symbolRocket, 'Cosmic Shuttle'),
    ];

    final List<CardModel> cards = [];
    int idCounter = 0;

    for (int i = 0; i < pairCount && i < symbolTemplates.length; i++) {
      final sym = symbolTemplates[i];
      final isIce = (level?.hasIceObstacles ?? false) && (i % 3 == 0);
      final isBomb = (level?.hasBombObstacles ?? false) && (i == 1);

      // Card 1
      cards.add(CardModel(
        id: 'card_${idCounter++}',
        pairKey: sym.$1,
        assetName: sym.$2,
        semanticLabel: sym.$3,
        isIce: isIce,
        iceHitsRemaining: isIce ? 1 : 0,
        isBomb: isBomb,
        bombMovesRemaining: 8,
      ));

      // Card 2
      cards.add(CardModel(
        id: 'card_${idCounter++}',
        pairKey: sym.$1,
        assetName: sym.$2,
        semanticLabel: sym.$3,
        isIce: isIce,
        iceHitsRemaining: isIce ? 1 : 0,
        isBomb: isBomb,
        bombMovesRemaining: 8,
      ));
    }

    cards.shuffle(_random);
    return cards;
  }

  void _startTimer() {
    if (_timer == null && _state.status != GameStatus.completed && !_isDisposed) {
      _state = _state.copyWith(status: GameStatus.playing);
      final currentSession = _sessionId;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isDisposed || _sessionId != currentSession) {
          timer.cancel();
          return;
        }

        final newElapsed = _state.elapsedSeconds + 1;

        // Check Time Limit in Rush Levels
        if (_state.timeLimitSeconds != null && newElapsed >= _state.timeLimitSeconds!) {
          _timer?.cancel();
          _timer = null;
          _state = _state.copyWith(
            elapsedSeconds: newElapsed,
            status: GameStatus.failed,
            isInputLocked: true,
          );
          notifyListeners();
          onTimeUp?.call();
          return;
        }

        _state = _state.copyWith(elapsedSeconds: newElapsed);
        notifyListeners();
      });
      notifyListeners();
    }
  }

  /// Handles user card tap interaction.
  void handleCardTap(int index) {
    if (_isDisposed || _state.isInputLocked || _state.status == GameStatus.completed || _state.status == GameStatus.outOfMoves || _state.status == GameStatus.failed) {
      return;
    }
    if (index < 0 || index >= _state.deck.length) return;

    final card = _state.deck[index];
    if (card.isFaceUp || card.isMatched) return;

    // Handle Ice card barrier
    if (card.isFrozen) {
      final updatedDeck = List<CardModel>.from(_state.deck);
      updatedDeck[index] = card.copyWith(iceHitsRemaining: card.iceHitsRemaining - 1);
      _state = _state.copyWith(deck: updatedDeck);
      onFlip?.call();
      notifyListeners();
      return;
    }

    _startTimer();
    onFlip?.call();

    final updatedDeck = List<CardModel>.from(_state.deck);
    updatedDeck[index] = card.copyWith(isFaceUp: true);

    if (_state.firstSelectedIndex == null) {
      // First selection of pair
      _state = _state.copyWith(
        deck: updatedDeck,
        firstSelectedIndex: index,
        clearSecondSelection: true,
      );
      notifyListeners();
    } else {
      // Second selection of pair
      final firstIndex = _state.firstSelectedIndex!;
      final newMoves = _state.moves + 1;

      _state = _state.copyWith(
        deck: updatedDeck,
        secondSelectedIndex: index,
        moves: newMoves,
      );
      notifyListeners();

      _evaluatePairMatch(firstIndex, index, newMoves);
    }
  }

  void _evaluatePairMatch(int firstIdx, int secondIdx, int totalMovesUsed) {
    final firstCard = _state.deck[firstIdx];
    final secondCard = _state.deck[secondIdx];

    if (firstCard.pairKey == secondCard.pairKey) {
      // MATCH FOUND
      final updatedDeck = List<CardModel>.from(_state.deck);
      updatedDeck[firstIdx] = firstCard.copyWith(isMatched: true, isFaceUp: true);
      updatedDeck[secondIdx] = secondCard.copyWith(isMatched: true, isFaceUp: true);

      final newMatchedCount = _state.matchedPairs + 1;
      final isCompleted = newMatchedCount == _state.totalPairs;

      if (isCompleted) {
        _timer?.cancel();
        _timer = null;
      }

      _state = _state.copyWith(
        deck: updatedDeck,
        matchedPairs: newMatchedCount,
        clearFirstSelection: true,
        clearSecondSelection: true,
        status: isCompleted ? GameStatus.completed : GameStatus.playing,
      );
      notifyListeners();

      if (isCompleted) {
        onWin?.call();
      } else {
        onMatch?.call();
      }
    } else {
      // MISMATCH -> Check if Out of Moves
      final hasMovesConstraint = _state.maxMoves != null;
      final isOutOfMoves = hasMovesConstraint && (totalMovesUsed >= _state.maxMoves!);

      _state = _state.copyWith(isInputLocked: true);
      notifyListeners();
      onMismatch?.call();

      final currentSession = _sessionId;
      _mismatchTimer?.cancel();
      _mismatchTimer = Timer(Duration(milliseconds: mismatchDelayMs), () {
        if (_isDisposed || _sessionId != currentSession) return;
        _mismatchTimer = null;

        final resetDeck = List<CardModel>.from(_state.deck);
        resetDeck[firstIdx] = resetDeck[firstIdx].copyWith(isFaceUp: false);
        resetDeck[secondIdx] = resetDeck[secondIdx].copyWith(isFaceUp: false);

        if (isOutOfMoves) {
          _timer?.cancel();
          _timer = null;
          _state = _state.copyWith(
            deck: resetDeck,
            clearFirstSelection: true,
            clearSecondSelection: true,
            isInputLocked: true,
            status: GameStatus.outOfMoves,
          );
          notifyListeners();
          onOutOfMoves?.call();
        } else {
          _state = _state.copyWith(
            deck: resetDeck,
            clearFirstSelection: true,
            clearSecondSelection: true,
            isInputLocked: false,
          );
          notifyListeners();
        }
      });
    }
  }

  // --- BOOSTER ACTIONS ---

  /// Adds extra moves to continue playing (from Rewarded Ad or Store Coins)
  void addExtraMoves(int extraMoves) {
    if (_isDisposed) return;
    if (_state.maxMoves != null) {
      _state = _state.copyWith(
        maxMoves: _state.maxMoves! + extraMoves,
        status: GameStatus.playing,
        isInputLocked: false,
      );
      _startTimer();
      notifyListeners();
    }
  }

  /// Peek Booster: Reveals all unrevealed cards for 2.5 seconds
  void applyPeekBooster() {
    if (_state.isInputLocked || _state.status == GameStatus.completed || _isDisposed) return;

    final peekDeck = _state.deck.map((card) {
      if (!card.isMatched) {
        return card.copyWith(isPeekRevealed: true);
      }
      return card;
    }).toList();

    _state = _state.copyWith(deck: peekDeck, isPeekActive: true, isInputLocked: true);
    notifyListeners();

    final currentSession = _sessionId;
    _peekTimer?.cancel();
    _peekTimer = Timer(const Duration(milliseconds: 2500), () {
      if (_isDisposed || _sessionId != currentSession) return;
      _peekTimer = null;

      final unpeekDeck = _state.deck.map((card) {
        return card.copyWith(isPeekRevealed: false);
      }).toList();

      _state = _state.copyWith(deck: unpeekDeck, isPeekActive: false, isInputLocked: false);
      notifyListeners();
    });
  }

  /// Freeze / +Moves Booster: Adds +3 extra moves
  void applyFreezeBooster() {
    if (_isDisposed) return;
    if (_state.maxMoves != null) {
      _state = _state.copyWith(maxMoves: _state.maxMoves! + 3);
      notifyListeners();
    }
  }

  /// Magic Wand Booster: Instantly matches 1 random unmatched pair
  void applyWandBooster() {
    if (_isDisposed || _state.isInputLocked || _state.status == GameStatus.completed) return;

    // Find first unmatched pair key
    String? targetKey;
    for (final card in _state.deck) {
      if (!card.isMatched) {
        targetKey = card.pairKey;
        break;
      }
    }

    if (targetKey != null) {
      final updatedDeck = _state.deck.map((card) {
        if (card.pairKey == targetKey) {
          return card.copyWith(isMatched: true, isFaceUp: true);
        }
        return card;
      }).toList();

      final newMatchedCount = _state.matchedPairs + 1;
      final isCompleted = newMatchedCount == _state.totalPairs;

      if (isCompleted) {
        _timer?.cancel();
        _timer = null;
      }

      _state = _state.copyWith(
        deck: updatedDeck,
        matchedPairs: newMatchedCount,
        clearFirstSelection: true,
        clearSecondSelection: true,
        status: isCompleted ? GameStatus.completed : GameStatus.playing,
      );
      notifyListeners();

      if (isCompleted) {
        onWin?.call();
      } else {
        onMatch?.call();
      }
    }
  }

  /// Shuffle Booster: Reshuffles remaining unmatched cards
  void applyShuffleBooster() {
    if (_isDisposed || _state.isInputLocked || _state.status == GameStatus.completed) return;

    final unmatchedCards = _state.deck.where((c) => !c.isMatched).toList();
    unmatchedCards.shuffle(_random);

    int unmatchedIndex = 0;
    final updatedDeck = _state.deck.map((card) {
      if (!card.isMatched) {
        return unmatchedCards[unmatchedIndex++];
      }
      return card;
    }).toList();

    _state = _state.copyWith(deck: updatedDeck);
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sessionId++;
    _cancelAllTimers();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}
