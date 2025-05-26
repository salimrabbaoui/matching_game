import 'sock_card.dart';

enum GameStatus { playing, paused, won, lost, initial }

class GameState {
  final int level;
  final int moves;
  final int maxMoves;
  final int pairsCount;
  final List<SockCard> cards;
  final List<bool> cardFlips;
  final List<int> matchedPairs;
  final int? firstCardIndex;
  final int? secondCardIndex;
  final bool isProcessing;
  final GameStatus status;
  final int timeRemaining; // For time-based games
  final bool useImages;

  const GameState({
    required this.level,
    this.moves = 0,
    required this.maxMoves,
    required this.pairsCount,
    this.cards = const [],
    this.cardFlips = const [],
    this.matchedPairs = const [],
    this.firstCardIndex,
    this.secondCardIndex,
    this.isProcessing = false,
    this.status = GameStatus.initial,
    this.timeRemaining = 0,
    this.useImages = true,
  });

  GameState copyWith({
    int? level,
    int? moves,
    int? maxMoves,
    int? pairsCount,
    List<SockCard>? cards,
    List<bool>? cardFlips,
    List<int>? matchedPairs,
    int? firstCardIndex,
    int? secondCardIndex,
    bool? isProcessing,
    GameStatus? status,
    int? timeRemaining,
    bool? useImages,
    bool clearFirstCard = false,
    bool clearSecondCard = false,
  }) {
    return GameState(
      level: level ?? this.level,
      moves: moves ?? this.moves,
      maxMoves: maxMoves ?? this.maxMoves,
      pairsCount: pairsCount ?? this.pairsCount,
      cards: cards ?? this.cards,
      cardFlips: cardFlips ?? this.cardFlips,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      firstCardIndex:
          clearFirstCard ? null : (firstCardIndex ?? this.firstCardIndex),
      secondCardIndex:
          clearSecondCard ? null : (secondCardIndex ?? this.secondCardIndex),
      isProcessing: isProcessing ?? this.isProcessing,
      status: status ?? this.status,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      useImages: useImages ?? this.useImages,
    );
  }

  bool get isGameComplete => matchedPairs.length == pairsCount;
  bool get hasMovesLeft => moves < maxMoves;
  bool get canPlay => status == GameStatus.playing && !isProcessing;

  @override
  String toString() {
    return 'GameState(level: $level, moves: $moves, maxMoves: $maxMoves, status: $status)';
  }
}
