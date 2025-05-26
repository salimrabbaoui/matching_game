# New Architecture for Sock Matching Game

## Overview

This document outlines the new, improved architecture for the Sock Matching Game. The new structure follows clean architecture principles with clear separation of concerns, making the code more maintainable, testable, and scalable.

## Architecture Structure

### 🏗️ Core Layer (`lib/core/`)

The core layer contains the fundamental building blocks of the application:

#### Constants (`lib/core/constants/`)
- **`app_constants.dart`**: Centralized constants for colors, dimensions, animations, and game settings
- Eliminates magic numbers and ensures consistency across the app

#### Models (`lib/core/models/`)
- **`sock_card.dart`**: Immutable data model for sock cards with proper equality and copyWith methods
- **`game_state.dart`**: Comprehensive game state management with enums and computed properties

#### Services (`lib/core/services/`)
- **`game_logic_service.dart`**: Pure business logic for game calculations and rules
- **`storage_service.dart`**: Centralized data persistence with proper error handling

### 🎨 Shared Layer (`lib/shared/`)

Reusable UI components and utilities:

#### Widgets (`lib/shared/widgets/`)
- **`game_card.dart`**: Animated card component with flip animations and image/emoji support
- **Dialogs** (`lib/shared/widgets/dialogs/`):
  - `base_dialog.dart`: Reusable dialog foundation with consistent styling
  - `level_selection_dialog.dart`: Configurable level selection for both game modes
  - `no_hearts_dialog.dart`: Specialized dialog for heart system with subscription integration

### 🎮 Features Layer (`lib/features/`)

Feature-specific modules organized by domain:

#### Menu (`lib/features/menu/`)
- **`menu_page.dart`**: Clean main menu with game mode selection

#### Game (`lib/features/game/`)
- **`classic_game_page.dart`**: Traditional game mode implementation
- **`time_game_page.dart`**: Time-based challenge mode
- **Game Controllers**: Separate game logic from UI

## Key Improvements

### 1. **Separation of Concerns**
```
❌ Before: All logic mixed in single files
✅ After: Clear separation between UI, business logic, and data
```

### 2. **Reusable Components**
```
❌ Before: Repetitive dialog code everywhere
✅ After: BaseDialog and specialized dialog components
```

### 3. **Centralized Configuration**
```
❌ Before: Constants scattered throughout files
✅ After: All constants in AppConstants class
```

### 4. **Service Layer**
```
❌ Before: Direct SharedPreferences usage in UI
✅ After: StorageService with proper error handling
```

### 5. **Type Safety**
```
❌ Before: Primitive types and loose coupling
✅ After: Strong typing with models and enums
```

## Usage Examples

### Creating a Dialog
```dart
// Old way (repetitive)
showDialog(
  context: context,
  builder: (context) => Dialog(
    // 50+ lines of repetitive styling...
  ),
);

// New way (reusable)
BaseDialog.show(
  context: context,
  title: 'Game Over',
  content: Text('Your score: 1500'),
  actions: [
    DialogButton(text: 'Play Again', isPrimary: true),
  ],
);
```

### Level Selection
```dart
// Old way (duplicate dialogs)
_showLevelSelectionDialog(); // 100+ lines each
_showTimeLevelSelectionDialog(); // Nearly identical code

// New way (configurable)
LevelSelectionDialog.show(
  context: context,
  highestLevel: level,
  onLevelSelected: _startGame,
  isTimeMode: true, // Just one parameter difference!
);
```

### Game Logic
```dart
// Old way (mixed with UI)
pairsCount = _calculatePairsForLevel(widget.level);
maxMoves = _calculateMaxMovesForLevel(widget.level);

// New way (pure service)
final gameLogic = GameLogicService();
final pairsCount = gameLogic.calculatePairsForLevel(level);
final maxMoves = gameLogic.calculateMaxMovesForLevel(level);
```

## Migration Guide

### Phase 1: Core Infrastructure ✅
- [x] Constants and models
- [x] Service layer
- [x] Base components

### Phase 2: UI Components ✅
- [x] Reusable dialogs
- [x] Game cards
- [x] Menu page

### Phase 3: Game Features (Next Steps)
- [ ] Classic game page with new architecture
- [ ] Time game page with new architecture
- [ ] Settings page
- [ ] Statistics page

### Phase 4: Advanced Features (Future)
- [ ] Sound service
- [ ] Animation service
- [ ] Localization support
- [ ] Theme service

## File Organization

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── models/
│   │   ├── sock_card.dart
│   │   └── game_state.dart
│   └── services/
│       ├── game_logic_service.dart
│       └── storage_service.dart
├── shared/
│   └── widgets/
│       ├── dialogs/
│       │   ├── base_dialog.dart
│       │   ├── level_selection_dialog.dart
│       │   └── no_hearts_dialog.dart
│       └── game_card.dart
├── features/
│   ├── menu/
│   │   └── menu_page.dart
│   └── game/
│       ├── classic_game_page.dart (to be created)
│       └── time_game_page.dart (to be created)
├── heart_manager.dart (existing)
├── subscription_service.dart (existing)
├── subscription_dialog.dart (existing)
├── main.dart (existing)
└── main_new.dart (new entry point)
```

## Benefits

### For Developers
1. **Easier Testing**: Pure functions and isolated components
2. **Better Maintainability**: Clear file organization and separation
3. **Faster Development**: Reusable components reduce code duplication
4. **Improved Debugging**: Clear data flow and state management

### For Users
1. **Consistent UI**: Unified design system through constants
2. **Better Performance**: Optimized components and lazy loading
3. **Smoother Animations**: Centralized animation configurations
4. **More Reliable**: Better error handling and state management

## Next Steps

1. **Migrate Game Pages**: Update existing game pages to use new architecture
2. **Add Missing Features**: Implement settings and statistics pages
3. **Testing**: Add unit tests for services and components
4. **Documentation**: Add inline documentation and examples
5. **Performance**: Optimize with performance best practices

## Getting Started

To use the new architecture:

1. Replace `main.dart` with `main_new.dart`
2. Update imports to use new component paths
3. Follow the examples in this document
4. Refer to the existing components for patterns

The new architecture is designed to be backwards compatible while providing a clear migration path forward. 