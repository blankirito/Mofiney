import 'database/app_database.dart';
import '../features/accounts/data/account_repository.dart';
import '../features/transactions/data/transaction_repository.dart';
import '../features/profile/data/app_settings_repository.dart';
import '../features/profile/data/category_budget_repository.dart';
import '../features/categories/data/category_repository.dart';
import '../features/profile/data/recurring_schedule_repository.dart';
import '../features/profile/data/financial_export_service.dart';
import '../features/profile/data/local_backup_service.dart';
import 'security/app_lock_service.dart';

final AppDatabase appDatabase = AppDatabase();

final AccountRepository accountRepository = AccountRepository(appDatabase);

final TransactionRepository transactionRepository = TransactionRepository(
  appDatabase,
);

final AppSettingsRepository appSettingsRepository = AppSettingsRepository(
  appDatabase,
);

final CategoryBudgetRepository categoryBudgetRepository =
    CategoryBudgetRepository(appDatabase);

final RecurringScheduleRepository recurringScheduleRepository =
    RecurringScheduleRepository(appDatabase);

final CategoryRepository categoryRepository = CategoryRepository(appDatabase);

final FinancialExportService financialExportService = FinancialExportService(
  appDatabase,
);

final LocalBackupService localBackupService = LocalBackupService(appDatabase);

final appLockService = AppLockService();
