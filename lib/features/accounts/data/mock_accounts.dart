import '../domain/account.dart';

const mockAccounts = [
  Account(
    id: 'maybank',
    name: 'Maybank',
    type: AccountType.bank,
    openingBalance: 5420.30,
    isPrimary: true,
    currencyCode: 'MYR',
  ),

  Account(
    id: 'cimb',
    name: 'CIMB Bank',
    type: AccountType.bank,
    openingBalance: 4250.20,
    currencyCode: 'MYR',
  ),

  Account(
    id: 'tng',
    name: "Touch 'n Go eWallet",
    type: AccountType.eWallet,
    openingBalance: 500.00,
    currencyCode: 'MYR',
  ),

  Account(
    id: 'cash',
    name: 'Physical Cash Wallet',
    type: AccountType.cash,
    openingBalance: 680.10,
    currencyCode: 'MYR',
  ),

  Account(
    id: 'cimb-visa',
    name: 'CIMB Visa Platinum',
    type: AccountType.creditCard,
    openingBalance: 1240.50,
    creditLimit: 10000.00,
    statementCycleDay: 18,
    currencyCode: 'MYR',
  ),
];
