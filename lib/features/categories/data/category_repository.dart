import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/category.dart';

class CategoryRepository {
  CategoryRepository(this._database);

  final AppDatabase _database;

  Future<List<Category>> getAllCategories() async {
    final rows = await _database.select(_database.categoryEntries).get();

    return rows.map(_mapRowToCategory).toList();
  }

  Stream<List<Category>> watchAllCategories() {
    return _database
        .select(_database.categoryEntries)
        .watch()
        .map((rows) => rows.map(_mapRowToCategory).toList());
  }

  Future<void> insertCategory(Category category) async {
    await _database
        .into(_database.categoryEntries)
        .insert(_mapCategoryToCompanion(category));
  }

  Future<void> updateCategory(Category category) async {
    await (_database.update(_database.categoryEntries)
          ..where((table) => table.id.equals(category.id)))
        .write(_mapCategoryToCompanion(category));
  }

  Future<void> deleteCategory(String id) async {
    await (_database.delete(
      _database.categoryEntries,
    )..where((table) => table.id.equals(id))).go();
  }

  Category _mapRowToCategory(CategoryEntry row) {
    return Category(
      id: row.id,
      name: row.name,
      type: _categoryTypeFromString(row.type),
      iconCodePoint: row.iconCodePoint,
      isDefault: row.isDefault,
      isActive: row.isActive,
    );
  }

  CategoryEntriesCompanion _mapCategoryToCompanion(Category category) {
    return CategoryEntriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
      type: Value(category.type.name),
      iconCodePoint: Value(category.iconCodePoint),
      isDefault: Value(category.isDefault),
      isActive: Value(category.isActive),
    );
  }

  CategoryType _categoryTypeFromString(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => CategoryType.expense,
    );
  }

  Future<void> seedCategoriesIfEmpty(List<Category> categories) async {
    final existing = await getAllCategories();

    if (existing.isNotEmpty) {
      return;
    }

    await _database.batch((batch) {
      batch.insertAll(
        _database.categoryEntries,
        categories.map(_mapCategoryToCompanion).toList(),
      );
    });
  }
}
