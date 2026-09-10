import 'package:flutter/material.dart';

import '../domain/category.dart';

final defaultCategories = [
  Category(
    id: 'expense-food-dining',
    name: 'Food & Dining',
    type: CategoryType.expense,
    iconCodePoint: Icons.restaurant_rounded.codePoint,
    isDefault: true,
  ),
  Category(
    id: 'expense-transportation',
    name: 'Transportation',
    type: CategoryType.expense,
    iconCodePoint: Icons.directions_car_rounded.codePoint,
    isDefault: true,
  ),
  Category(
    id: 'expense-groceries',
    name: 'Groceries',
    type: CategoryType.expense,
    iconCodePoint: Icons.local_grocery_store_outlined.codePoint,
    isDefault: true,
  ),
  Category(
    id: 'expense-shopping',
    name: 'Shopping',
    type: CategoryType.expense,
    iconCodePoint: Icons.shopping_bag_outlined.codePoint,
    isDefault: true,
  ),
  Category(
    id: 'expense-entertainment',
    name: 'Entertainment',
    type: CategoryType.expense,
    iconCodePoint: Icons.movie_outlined.codePoint,
    isDefault: true,
  ),

  Category(
    id: 'income-salary',
    name: 'Salary',
    type: CategoryType.income,
    iconCodePoint: Icons.work_outline_rounded.codePoint,
    isDefault: true,
  ),
  Category(
    id: 'income-bonus',
    name: 'Bonus',
    type: CategoryType.income,
    iconCodePoint: Icons.card_giftcard_rounded.codePoint,
    isDefault: true,
  ),
  Category(
    id: 'income-freelance',
    name: 'Freelance',
    type: CategoryType.income,
    iconCodePoint: Icons.laptop_mac_rounded.codePoint,
    isDefault: true,
  ),
  Category(
    id: 'income-other',
    name: 'Other Income',
    type: CategoryType.income,
    iconCodePoint: Icons.payments_outlined.codePoint,
    isDefault: true,
  ),
];
