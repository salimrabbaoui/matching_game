import 'dart:async';
import '../../core/models/game_state.dart';
import '../../core/models/sock_card.dart';
import '../../core/services/game_logic_service.dart';
import '../../core/services/storage_service.dart';
import '../../heart_manager.dart';

abstract class BaseGameController {
  final GameLogicService _gameLogic = GameLogicService();
  final StorageService _storage = StorageService();

  late StreamController<GameState> _gameStateController;
  GameState _currentState =
      const GameState(level: 1, maxMoves: 0, pairsCount: 0);

  // Getters
  Stream<GameState> get gameStateStream => _gameStateController.stream;
  GameState get currentState => _currentState;

  // Initialize controller
  void initialize(int level) {
    _gameStateController = StreamController<GameState>.broadcast();
    _initializeGame(level);
  }

  // Dispose controller
  void dispose() {
    _gameStateController.close();
  }

  // Initialize game state
  void _initializeGame(int level) {
    final pairsCount = _gameLogic.calculatePairsForLevel(level);
    final maxMoves = _gameLogic.calculateMaxMovesForLevel(level);
    final cards = _gameLogic.initializeCards(level, useImages: true);
    final cardFlips = List.generate(cards.length, (index) => false);

    _updateState(_currentState.copyWith(
      level: level,
      pairsCount: pairsCount,
      maxMoves: maxMoves,
      cards: cards,
      cardFlips: cardFlips,
      matchedPairs: [],
      moves: 0,
      status: GameStatus.playing,
      clearFirstCard: true,
      clearSecondCard: true,
      isProcessing: false,
    ));
  }

  // Handle card tap
  Future<void> onCardTapped(int index) async {
    if (!_canTapCard(index)) return;

    // Flip the card
    final newCardFlips = List<bool>.from(_currentState.cardFlips);
    newCardFlips[index] = true;

    if (_currentState.firstCardIndex == null) {
      // First card
      _updateState(_currentState.copyWith(
        firstCardIndex: index,
        cardFlips: newCardFlips,
      ));
    } else {
      // Second card
      _updateState(_currentState.copyWith(
        secondCardIndex: index,
        cardFlips: newCardFlips,
        isProcessing: true,
        moves: _currentState.moves + 1,
      ));

      // Check for match after delay
      await Future.delayed(const Duration(milliseconds: 1000));
      await _checkMatch();
    }
  }

  // Check if card can be tapped
  bool _canTapCard(int index) {
    return _currentState.canPlay &&
        !_currentState.cardFlips[index] &&
        !_currentState.matchedPairs.contains(index) &&
        _currentState.secondCardIndex == null &&
        _currentState.firstCardIndex != index;
  }

  // Check for match between two cards
  Future<void> _checkMatch() async {
    final firstIndex = _currentState.firstCardIndex!;
    final secondIndex = _currentState.secondCardIndex!;
    final firstCard = _currentState.cards[firstIndex];
    final secondCard = _currentState.cards[secondIndex];

    if (_gameLogic.doCardsMatch(firstCard, secondCard)) {
      // Match found
      final newMatchedPairs = List<int>.from(_currentState.matchedPairs)
        ..addAll([firstIndex, secondIndex]);

      _updateState(_currentState.copyWith(
        matchedPairs: newMatchedPairs,
        clearFirstCard: true,
        clearSecondCard: true,
        isProcessing: false,
      ));

      // Check if game is complete
      if (_currentState.isGameComplete) {
        await _handleGameWon();
      }
    } else {
      // No match - flip cards back
      final newCardFlips = List<bool>.from(_currentState.cardFlips);
      newCardFlips[firstIndex] = false;
      newCardFlips[secondIndex] = false;

      _updateState(_currentState.copyWith(
        cardFlips: newCardFlips,
        clearFirstCard: true,
        clearSecondCard: true,
        isProcessing: false,
      ));

      // Check if game is lost
      if (!_currentState.hasMovesLeft) {
        await _handleGameLost();
      }
    }
  }

  // Handle game won
  Future<void> _handleGameWon() async {
    _updateState(_currentState.copyWith(status: GameStatus.won));

    // Update highest level
    final nextLevel = _gameLogic.getNextLevel(_currentState.level);
    await _updateHighestLevel(nextLevel);

    // Update statistics
    await _storage.incrementGamesWon();
    await _storage.incrementGamesPlayed();

    final score = _gameLogic.calculateScore(_currentState);
    await _storage.addToTotalScore(score);

    // Call subclass method
    await onGameWon(score);
  }

  // Handle game lost
  Future<void> _handleGameLost() async {
    _updateState(_currentState.copyWith(status: GameStatus.lost));

    // Lose a heart
    HeartManager().loseHeart();

    // Update statistics
    await _storage.incrementGamesPlayed();

    // Call subclass method
    await onGameLost();
  }

  // Update game state and notify listeners
  void _updateState(GameState newState) {
    _currentState = newState;
    _gameStateController.add(_currentState);
  }

  // Abstract methods for subclasses
  Future<void> onGameWon(int score);
  Future<void> onGameLost();
  Future<void> _updateHighestLevel(int level);

  // Reset game
  void resetGame() {
    _initializeGame(_currentState.level);
  }

  // Pause/Resume game
  void pauseGame() {
    if (_currentState.status == GameStatus.playing) {
      _updateState(_currentState.copyWith(status: GameStatus.paused));
    }
  }

  void resumeGame() {
    if (_currentState.status == GameStatus.paused) {
      _updateState(_currentState.copyWith(status: GameStatus.playing));
    }
  }
}
