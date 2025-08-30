# Udhar Book App

A modern digital ledger app for shopkeepers to manage customer credit/debit transactions with automatic SMS notifications.

## Features

✅ **Customer Management**
- Add customers with name, mobile number, and email
- View all customers with their current balance status
- Track individual customer transaction history

✅ **Transaction Management**
- Add credit transactions (when customer buys items)
- Add debit transactions (when customer makes payments)
- Real-time balance calculation
- Transaction history with date and time

✅ **SMS Notifications**
- Automatic SMS sent to both shopkeeper and customer
- Transaction details including item name, amount, date
- Current balance information
- Payment status updates

✅ **Modern UI**
- Clean and intuitive interface
- Material Design 3
- Color-coded balance indicators (Red for pending, Green for cleared)
- Responsive design

## How to Use

1. **Add Customer**: Tap the "Add Customer" button and enter customer details
2. **Manage Transactions**: Tap on any customer to view their details
3. **Add Credit**: When customer buys items, add credit transaction
4. **Add Payment**: When customer pays money, add debit transaction
5. **SMS Notifications**: Both parties receive automatic SMS updates

## Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Connect your Android device or start emulator
4. Run `flutter run` to launch the app

## Permissions Required

- SMS permissions for sending transaction notifications
- Storage permissions for local database

## Technology Stack

- **Flutter** - Cross-platform mobile development
- **SQLite** - Local database for data storage
- **SMS API** - For sending notifications
- **Material Design 3** - Modern UI components
