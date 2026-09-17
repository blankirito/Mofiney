# Mofiney

Mofiney is a local-first personal finance application built with Flutter and Dart. It is designed to help users manage accounts, transactions, budgets, recurring payments, and financial insights while keeping core financial data available offline.

## Features

### Account Management
- Create and manage multiple account types, including bank accounts, e-wallets, cash, and credit cards.
- Track opening balances, current balances, credit card outstanding amounts, and available credit.
- Archive and restore accounts without removing historical transactions.
- Set a primary account.

### Transactions
- Record expenses, income, and transfers between accounts.
- Edit and delete existing transactions.
- Attach receipt images to transactions.
- Apply balance validation and account-specific financial rules.
- Support credit card spending and repayment flows.

### Budget & Financial Insights
- Set and track a monthly spending target.
- Create category-level budgets.
- Calculate monthly spending, income, remaining budget, and budget utilization from actual transaction data.
- View spending analysis by account, category, and time period.
- Estimate monthly spending based on the current spending pace.

### Recurring Transactions
- Create recurring income and expense schedules.
- Pause, resume, edit, and delete recurring transactions.
- Automatically generate due transactions when the application is opened.
- Calculate estimated monthly recurring inflow, outflow, and net amount.

### Multi-Currency Display
- Select a preferred display currency.
- Retrieve exchange rates from an online exchange-rate API.
- Cache exchange rates locally for offline use.
- Keep financial records in a consistent base ledger currency while converting values for display.

### Security
- Six-digit application PIN.
- Salted SHA-256 PIN hashing.
- Secure credential storage using `flutter_secure_storage`.
- Device authentication using biometrics or device credentials through `local_auth`.

### Data Management
- Local JSON backup and restore.
- Backup support for accounts, transactions, categories, budgets, recurring schedules, and receipt files.
- Export financial data and share exported files.
- No cloud account is required for local backup and restore.

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Database:** Drift / SQLite
- **Local Preferences:** SharedPreferences
- **Secure Storage:** flutter_secure_storage
- **Device Authentication:** local_auth
- **Networking:** HTTP / Exchange-rate API
- **Cryptography:** SHA-256
- **File Handling:** file_picker, image_picker
- **Data Sharing:** share_plus

## Architecture

Mofiney uses a feature-based project structure with separation between domain, data, and presentation responsibilities.

```text
lib/
├── core/
│   ├── database/
│   ├── currency/
│   ├── security/
│   ├── theme/
│   └── utils/
│
└── features/
    ├── accounts/
    ├── transactions/
    ├── categories/
    ├── home/
    ├── analytics/
    ├── profile/
    └── onboarding/
