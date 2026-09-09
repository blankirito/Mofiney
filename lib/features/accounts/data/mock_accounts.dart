import '../domain/account.dart';

const mockAccounts = [
  Account(
    id: 'maybank',
    name: 'Maybank',
    type: AccountType.bank,
    openingBalance: 5420.30,
    isPrimary: true,
  ),

  Account(
    id: 'cimb',
    name: 'CIMB Bank',
    type: AccountType.bank,
    openingBalance: 4250.20,
  ),

  Account(
    id: 'tng',
    name: "Touch 'n Go eWallet",
    type: AccountType.eWallet,
    openingBalance: 500.00,
  ),

  Account(
    id: 'cash',
    name: 'Physical Cash Wallet',
    type: AccountType.cash,
    openingBalance: 680.10,
  ),

  Account(
    id: 'cimb-visa',
    name: 'CIMB Visa Platinum',
    type: AccountType.creditCard,

    // Credit card outstanding.
    openingBalance: 1240.50,

    creditLimit: 10000.00,
    statementCycleDay: 18,
  ),
];