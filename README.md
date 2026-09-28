# Salary Calculator Pro

A production-ready Flutter web application for calculating salaries, deductions, taxes, and take-home pay. Designed with a premium SaaS/fintech aesthetic and fully responsive for Desktop, Tablet, and Mobile.

## Features

- **Comprehensive Salary Breakdown**: Calculate gross salary, net salary, allowances, taxes, and other deductions.
- **Progressive Tax Engine**: Configurable flat or progressive tax brackets.
- **Dynamic Allowances & Deductions**: Add fixed or percentage-based allowances and deductions.
- **Salary Frequency Conversion**: Instantly convert salaries between Annual, Monthly, Biweekly, Weekly, Daily, and Hourly.
- **Salary Comparison**: Objectively compare a current salary against a new offer.
- **Local History**: Save calculations to local storage.
- **Premium UI/UX**: Built with Material 3, tailored for a professional SaaS dashboard look.
- **Themes**: Light and Dark mode support.
- **Multi-Currency**: Format numbers with various popular currencies.

## Project Architecture

This project strictly follows clean architecture principles without over-engineering:
- `lib/models/`: Core domain models (Allowances, Deductions, Tax Brackets, Salary Breakdown).
- `lib/services/`: Calculation engine and storage services.
- `lib/providers/`: State management using the `provider` package.
- `lib/core/`: Constants, themes, and utilities.
- `lib/screens/`: Feature-based screens.
- `lib/widgets/`: Reusable, atomic UI components.

## Tech Stack
- **Framework**: [Flutter](https://flutter.dev/) (Web optimized)
- **State Management**: `provider`
- **Local Storage**: `shared_preferences`
- **Charts**: `fl_chart`
- **Typography**: `google_fonts`

## How to Run & Build (Browser Environments)

This repository is completely self-contained and designed to be run in any Flutter-compatible environment. If you do not have Flutter installed on your PC, you can use **GitHub Codespaces**, **Project IDX**, or **Gitpod**.

### Local Commands (Requires Flutter SDK)
To install dependencies:
```bash
flutter pub get
```

To run locally in Chrome:
```bash
flutter run -d chrome
```

To build for Web deployment:
```bash
flutter build web
```

## Contributing
Contributions are welcome. Please adhere to proper Flutter lint rules (`flutter analyze`) and write tests for calculation engine changes.

## License
MIT License
