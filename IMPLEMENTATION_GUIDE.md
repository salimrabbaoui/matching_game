# Implementation Guide: Migrating to New Architecture

## Quick Start

### Step 1: Test the New Architecture

1. **Backup your current `main.dart`**:
   ```bash
   mv lib/main.dart lib/main_old.dart
   ```

2. **Use the new main file**:
   ```bash
   mv lib/main_new.dart lib/main.dart
   ```

3. **Run the app** to see the new menu system:
   ```bash
   flutter run
   ```

### Step 2: Fix Import Issues

The new menu page has placeholder imports for game pages that don't exist yet. You have two options:

#### Option A: Quick Fix (Comment out for now)
```dart
// In lib/features/menu/menu_page.dart
// import '../game/classic_game_page.dart';
// import '../game/time_game_page.dart';

// Then replace the navigation with your existing pages:
void _startClassicGame(int level) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MatchingGamePage(level: level), // Your existing page
    ),
  );
}
```

#### Option B: Create New Game Pages (Recommended)

Copy your existing game logic but use the new architecture:

```dart
// lib/features/game/classic_game_page.dart
import 'package:flutter/material.dart';
import '../../shared/widgets/game_card.dart';
import '../../core/constants/app_constants.dart';
import 'base_game_controller.dart';

class ClassicGameController extends BaseGameController {
  @override
  Future<void> onGameWon(int score) async {
    // Handle classic game win
  }

  @override
  Future<void> onGameLost() async {
    // Handle classic game loss
  }

  @override
  Future<void> _updateHighestLevel(int level) async {
    await StorageService().setHighestLevel(level);
  }
}

class ClassicGamePage extends StatefulWidget {
  final int level;
  
  const ClassicGamePage({super.key, required this.level});
  
  @override
  State<ClassicGamePage> createState() => _ClassicGamePageState();
}

class _ClassicGamePageState extends State<ClassicGamePage> {
  late ClassicGameController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = ClassicGameController();
    _controller.initialize(widget.level);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Level ${widget.level}')),
      body: StreamBuilder<GameState>(
        stream: _controller.gameStateStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          
          final state = snapshot.data!;
          return Column(
            children: [
              // Game info
              _buildGameInfo(state),
              
              // Game grid
              Expanded(child: _buildGameGrid(state)),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildGameInfo(GameState state) {
    return Container(
      padding: EdgeInsets.all(AppConstants.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Moves: ${state.moves}/${state.maxMoves}'),
          Text('Pairs: ${state.matchedPairs.length ~/ 2}/${state.pairsCount}'),
        ],
      ),
    );
  }
  
  Widget _buildGameGrid(GameState state) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _calculateCrossAxisCount(state.cards.length),
      ),
      itemCount: state.cards.length,
      itemBuilder: (context, index) {
        return GameCard(
          sockCard: state.cards[index],
          isFlipped: state.cardFlips[index],
          isMatched: state.matchedPairs.contains(index),
          onTap: () => _controller.onCardTapped(index),
        );
      },
    );
  }
  
  int _calculateCrossAxisCount(int cardCount) {
    // Simple logic - you can make this more sophisticated
    if (cardCount <= 8) return 2;
    if (cardCount <= 18) return 3;
    if (cardCount <= 32) return 4;
    return 5;
  }
}
```

## Migration Strategy

### Phase 1: Foundation (Already Done ✅)
- Core constants, models, and services
- Base UI components
- New menu system

### Phase 2: Gradual Migration

1. **Start with dialogs**: Replace existing dialogs with new components
2. **Update constants**: Replace hardcoded values with `AppConstants`
3. **Service integration**: Use `StorageService` instead of direct SharedPreferences

### Phase 3: Complete Game Pages

1. Create game controllers extending `BaseGameController`
2. Build new game pages using reusable components
3. Integrate heart system and subscription service

## Immediate Benefits You'll See

### 1. Consistent Dialogs
Replace this repetitive code:
```dart
// Old way - repeated everywhere
showDialog(
  context: context,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(/* styling */),
      child: Column(/* content */),
    ),
  ),
);
```

With this simple call:
```dart
// New way - one line
BaseDialog.show(
  context: context,
  title: 'Level Complete!',
  content: Text('Great job! Score: $score'),
  actions: [DialogButton(text: 'Next Level', isPrimary: true)],
);
```

### 2. Centralized Styling
Instead of scattered constants:
```dart
// Old way - magic numbers everywhere
BorderRadius.circular(20)  // Here
BorderRadius.circular(12)  // There
Colors.purple.shade50      // Different shades
```

Use consistent constants:
```dart
// New way - consistent design
BorderRadius.circular(AppConstants.largeBorderRadius)
BorderRadius.circular(AppConstants.borderRadius)
AppConstants.primaryColor
```

### 3. Type-Safe Game Logic
Replace primitive obsession:
```dart
// Old way - loose typing
List<bool> cardFlips = [];
int? firstCard;
bool isProcessing = false;
```

With proper models:
```dart
// New way - type safety
GameState state = GameState(
  cardFlips: [],
  firstCardIndex: null,
  status: GameStatus.playing,
);
```

## Testing the Architecture

### Quick Test Checklist

1. **Menu Navigation**: ✅ New menu should show two game modes
2. **Level Selection**: ✅ Dialogs should display with proper styling
3. **Constants**: ✅ All colors and dimensions should be consistent
4. **Services**: ✅ Storage should persist level progress

### Advanced Testing

1. **Game Logic Service**:
   ```dart
   final gameLogic = GameLogicService();
   assert(gameLogic.calculatePairsForLevel(1) == 2);
   assert(gameLogic.calculateMaxMovesForLevel(1) > 2);
   ```

2. **Storage Service**:
   ```dart
   final storage = StorageService();
   await storage.setHighestLevel(5);
   assert(await storage.getHighestLevel() == 5);
   ```

3. **UI Components**:
   ```dart
   // Test dialog shows correctly
   BaseDialog.show(context: context, title: 'Test');
   
   // Test game card displays
   GameCard(sockCard: SockCard(imagePath: '🧦', name: 'Test'));
   ```

## Rollback Plan

If you need to rollback:

1. **Restore original main**:
   ```bash
   mv lib/main.dart lib/main_new.dart
   mv lib/main_old.dart lib/main.dart
   ```

2. **Keep new architecture**: The new files don't interfere with existing code

3. **Gradual adoption**: You can use individual components even with old architecture

## Next Steps

1. **Test the new menu system**
2. **Gradually replace dialogs with new components**
3. **Use constants instead of magic numbers**
4. **Create game controllers for better state management**
5. **Add missing features (settings, statistics)**

## Support

The new architecture is designed to be:
- **Backwards compatible**: Old code still works
- **Incrementally adoptable**: Use what you want, when you want
- **Well documented**: Clear examples and patterns
- **Extensible**: Easy to add new features

Start small, test often, and gradually adopt the new patterns! 
 