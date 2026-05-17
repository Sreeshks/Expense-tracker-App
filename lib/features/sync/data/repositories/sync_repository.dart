import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../categories/data/repositories/category_repository.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';

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
}
