import '../domain/home_dashboard_data.dart';
import '../domain/home_transaction.dart';

const mockHomeDashboardData = HomeDashboardData(
  currencyCode: 'MYR',
  currencySymbol: 'RM',

  totalBalance: 12850.60,
  todaySpent: 56.80,

  monthlySpent: 1842.50,
  monthlyBudget: 4000,
  monthlyIncome: 4000,

  dailySpending: [
    24.5,
    48,
    65.1,
    142.2,
    56.8,
    70,
    76,
    38,
    32,
    61,
    44,
    50,
    82,
    91,
    35,
    43,
    53,
    39,
    63,
    98,
    78,
    31,
    48,
    56,
    66,
    38,
    104,
    89,
    46,
    52,
  ],

  forecastAmount: 0,
  forecastChangePercentage: 12.4,

  forecastTitle: 'Food & Dining spending is trending higher this month.',

  forecastDescription:
      'Your recent dining expenses are above your current monthly average.',

  recentTransactions: [
    HomeTransaction(
      title: 'GrabFood',
      subtitle: 'Food & Dining · Today, 12:43 PM',
      account: 'Maybank',
      amount: -28.90,
      type: HomeTransactionType.expense,
    ),
    HomeTransaction(
      title: 'Salary',
      subtitle: 'Income · Sep 1',
      account: 'Main Account',
      amount: 4000,
      type: HomeTransactionType.income,
    ),
    HomeTransaction(
      title: 'Petrol',
      subtitle: 'Transportation · Aug 31',
      account: 'Maybank',
      amount: -80,
      type: HomeTransactionType.expense,
    ),
    HomeTransaction(
      title: 'Transfer to Savings',
      subtitle: 'Transfer · Aug 31',
      account: 'CIMB → Savings',
      amount: 500,
      type: HomeTransactionType.transfer,
    ),
  ],
);
