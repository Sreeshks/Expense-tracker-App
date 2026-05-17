import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../../categories/presentation/bloc/category_state.dart';
import '../../../home/presentation/bloc/dashboard_bloc.dart';
import '../../../home/presentation/bloc/dashboard_event.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'debit';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(CategoriesLoadRequested());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Transaction', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                GestureDetector(onTap: () => Navigator.pop(context), child: Text('Close', style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.6)))),
              ],
            ),
            const SizedBox(height: 20),
            _buildTypeToggle(),
            const SizedBox(height: 20),
            _buildTextField(_titleController, 'Title'),
            const SizedBox(height: 16),
            _buildTextField(_amountController, 'Amount ( ₹ )', isNumber: true),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.white.withValues(alpha: 0.4)),
                  const SizedBox(width: 8),
                  Flexible(child: Text('Everything you add here is saved only on your device.', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF312ECB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                child: Text('Save', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [_typeButton('Expense', 'debit'), _typeButton('Income', 'credit')]),
    );
  }

  Widget _typeButton(String label, String value) {
    final isActive = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: isActive ? const Color(0xFF1DB954) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5))),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 16, color: Colors.white.withValues(alpha: 0.3)),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state.categories.isEmpty) {
          return Text('No categories. Add one in Categories tab.', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CATEGORY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 1)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.categories.map((cat) {
                final isSelected = _selectedCategoryId == cat.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryId = cat.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: isSelected ? Colors.white : AppColors.background, borderRadius: BorderRadius.circular(8)),
                    child: Text(cat.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.black : Colors.white)),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  void _onSave() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    if (title.isEmpty || amountText.isEmpty || _selectedCategoryId == null) return;
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;
    context.read<TransactionBloc>().add(TransactionAdded(amount: amount, note: title, type: _type, categoryId: _selectedCategoryId!));
    context.read<DashboardBloc>().add(DashboardRefreshRequested());
    Navigator.pop(context);
  }
}
