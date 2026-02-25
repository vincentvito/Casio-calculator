# Skeuo Calc

A premium tactile calculator app with neumorphic design, haptic feedback, and multiple calculation modes.

## Features

- **Basic Calculator** - Standard arithmetic operations with state-machine accuracy
- **Scientific Calculator** - Advanced mathematical functions (trigonometry, logarithms, etc.)
- **Currency Converter** - Convert between world currencies
- **Unit Converter** - Convert between various units of measurement
- **TVM Solver** - Time Value of Money financial calculations
- **Percentage Calculator** - Quick percentage calculations
- **Date Interval Calculator** - Calculate days between dates

## Design

- Neumorphic (soft UI) design with tactile button aesthetics
- Light and dark theme support
- Customizable haptic feedback intensity
- Optional sound effects

## Technical Stack

- **Framework:** Flutter
- **State Management:** Provider
- **Local Storage:** Hive
- **Architecture:** Clean Architecture with separation of concerns

## Requirements

- iOS 13.0+
- Android API 21+

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

3. Build for release:
   ```bash
   flutter build ios --release
   flutter build apk --release
   ```

## Project Structure

```
lib/
├── core/           # Enums, constants, extensions, utilities
├── data/           # Data layer (repositories, models, datasources)
├── domain/         # Business logic (engines, services)
├── presentation/   # UI layer (screens, widgets, providers)
└── theme/          # App theming and styling
```

## License

All rights reserved.
