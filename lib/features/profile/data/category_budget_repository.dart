import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/category_budget.dart';

class CategoryBudgetRepository {
  CategoryBudgetRepository(this._database);

  final AppDatabase _database;

  Stream<List<CategoryBudget>> watchAllCategoryBudgets() {
    return _database
        .select(_database.categoryBudgetEntries)
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }

  Future<List<CategoryBudget>> getAllCategoryBudgets() async {
    final rows = await _database.select(_database.categoryBudgetEntries).get();
    return rows.map(_mapRow).toList();
  }

  Future<void> saveCategoryBudget(CategoryBudget budget) async {
    await _database
        .into(_database.categoryBudgetEntries)
        .insertOnConflictUpdate(_mapCompanion(budget));
  }

  Future<void> deleteCategoryBudget(String categoryId) async {
    await (_database.delete(
      _database.categoryBudgetEntries,
    )..where((table) => table.categoryId.equals(categoryId))).go();
  }

  CategoryBudget _mapRow(CategoryBudgetEntry row) {
    return CategoryBudget(
      categoryId: row.categoryId,
      monthlyBudget: row.monthlyBudget,
    );
  }

  CategoryBudgetEntriesCompanion _mapCompanion(CategoryBudget budget) {
    return CategoryBudgetEntriesCompanion(
      categoryId: Value(budget.categoryId),
      monthlyBudget: Value(budget.monthlyBudget),
    );
  }
}
