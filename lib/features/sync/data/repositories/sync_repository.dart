// ignore_for_file: avoid_print
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../categories/data/repositories/category_repository.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';
import '../../../transactions/data/models/transaction_model.dart';

class SyncRepository {
  final ApiClient _apiClient;
  final CategoryRepository _categoryRepo;
  final TransactionRepository _transactionRepo;

  SyncRepository({
    ApiClient? apiClient,
    CategoryRepository? categoryRepo,
    TransactionRepository? transactionRepo,
  }) : _apiClient = apiClient ?? ApiClient(),
       _categoryRepo = categoryRepo ?? CategoryRepository(),
       _transactionRepo = transactionRepo ?? TransactionRepository();

  Future<void> syncAll() async {
    await _purgeDeleted();
    await pullFromServer();
    await _uploadNew();
  }

  Future<void> _purgeDeleted() async {
    final deletedCategories = await _categoryRepo.getDeleted();
    if (deletedCategories.isNotEmpty) {
      final ids = deletedCategories.map((c) => c.id).toList();
      await _apiClient.deleteJson(ApiConstants.deleteCategories, {'ids': ids});
      await _categoryRepo.permanentDelete(ids);
    }

    final deletedTransactions = await _transactionRepo.getDeleted();
    if (deletedTransactions.isNotEmpty) {
      final ids = deletedTransactions.map((t) => t.id).toList();
      await _apiClient.deleteJson(ApiConstants.deleteTransactions, {
        'ids': ids,
      });
      await _transactionRepo.permanentDelete(ids);
    }
  }

  Future<void> _uploadNew() async {
    final unsyncedCategories = await _categoryRepo.getUnsynced();
    for (final cat in unsyncedCategories) {
      await _apiClient.postJson(ApiConstants.addCategories, {
        'category_id': cat.id,
        'name': cat.name,
      });
    }
    if (unsyncedCategories.isNotEmpty) {
      await _categoryRepo.markSynced(
        unsyncedCategories.map((c) => c.id).toList(),
      );
    }

    final unsyncedTransactions = await _transactionRepo.getUnsynced();
    if (unsyncedTransactions.isNotEmpty) {
      await _apiClient.postJson(ApiConstants.addTransactions, {
        'transactions': unsyncedTransactions.map((t) => t.toApiJson()).toList(),
      });
      await _transactionRepo.markSynced(
        unsyncedTransactions.map((t) => t.id).toList(),
      );
    }
  }

  Future<void> pullFromServer() async {
    // 1. Fetch Categories
    try {
      final catResponse = await _apiClient.get(ApiConstants.getCategories);
      if (catResponse['status'] == 'success' &&
          catResponse['categories'] != null) {
        final categoriesJson = catResponse['categories'] as List;
        final List<CategoryModel> categories = [];
        for (final item in categoriesJson) {
          final id = (item['category_id'] ?? item['id'])?.toString() ?? '';
          if (id.isEmpty) continue;
          categories.add(
            CategoryModel(
              id: id,
              name: item['name']?.toString() ?? 'Unnamed',
              isSynced: 1,
            ),
          );
        }
        await _categoryRepo.saveFetched(categories);
      }
    } catch (e) {
      print('Failed to pull categories: $e');
    }

    // 2. Fetch Transactions
    try {
      final txnResponse = await _apiClient.get(ApiConstants.getTransactions);
      if (txnResponse['status'] == 'success' &&
          txnResponse['transactions'] != null) {
        final transactionsJson = txnResponse['transactions'] as List;

        // Load all categories to map transaction categories by name
        final localCategories = await _categoryRepo.getAll();

        final List<TransactionModel> transactions = [];
        for (final item in transactionsJson) {
          final categoryName = item['category']?.toString() ?? 'Other';

          // Match category by name
          var matchedCategory = localCategories.firstWhere(
            (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
            orElse: () => const CategoryModel(id: '', name: ''),
          );

          String categoryId;
          if (matchedCategory.id.isNotEmpty) {
            categoryId = matchedCategory.id;
          } else {
            // If category doesn't exist, create it locally
            final newCat = await _categoryRepo.add(categoryName);
            // Mark it as synced
            await _categoryRepo.markSynced([newCat.id]);
            categoryId = newCat.id;

            // Re-fetch local categories
            localCategories.add(newCat);
          }

          final typeString = (item['type']?.toString() ?? 'credit')
              .toLowerCase();

          final txnId =
              (item['transaction_id'] ?? item['id'])?.toString() ?? '';
          if (txnId.isEmpty) continue;

          final amountVal = item['amount'];
          final parsedAmount = amountVal != null
              ? (amountVal as num).toDouble()
              : 0.0;

          final timestampStr = item['timestamp']?.toString();
          final parsedTimestamp = timestampStr != null
              ? DateTime.tryParse(timestampStr) ?? DateTime.now()
              : DateTime.now();

          transactions.add(
            TransactionModel(
              id: txnId,
              amount: parsedAmount,
              note: item['note']?.toString() ?? '',
              type: typeString,
              categoryId: categoryId,
              timestamp: parsedTimestamp,
              isSynced: 1,
              isDeleted: 0,
            ),
          );
        }
        await _transactionRepo.saveFetched(transactions);
      }
    } catch (e) {
      print('Failed to pull transactions: $e');
    }
  }
}
