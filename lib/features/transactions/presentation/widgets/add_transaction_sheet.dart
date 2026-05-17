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
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              SizedBox(
                width: 343,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Transaction',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1. Expense/Income Toggle
              _buildTypeToggle(),
              const SizedBox(height: 20),

              // 2. Title Input
              _buildTitleInput(),
              const SizedBox(height: 16),

              // 3. Amount Input
              _buildAmountInput(),
              const SizedBox(height: 16),

              // 4 & 5. Category Selector
              _buildCategorySelector(),
              const SizedBox(height: 20),

              // 6. Info Box
              _buildInfoBox(),
              const SizedBox(height: 20),

              // 7. Save Button
              _buildSaveButton(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      width: 343,
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _typeButton('Expense', 'debit'),
          _typeButton('Income', 'credit'),
        ],
      ),
    );
  }

  Widget _typeButton(String label, String value) {
    final isActive = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1DC533) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return SizedBox(
      width: 343,
      height: 56,
      child: TextField(
        controller: _titleController,
        style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Title',
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 16,
            right: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return SizedBox(
      width: 343,
      height: 56,
      child: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Amount ( ₹ )',
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 16,
            right: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state.categories.isEmpty) {
          return SizedBox(
            width: 343,
            child: Text(
              'No categories. Add one in Categories tab.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          );
        }
        return SizedBox(
          width: 343,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CATEGORY',
                style: TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 1.0, // 100% line height
                  letterSpacing: 13 * -0.03, // -3% letter spacing
                  color: Colors.white.withValues(alpha: 0.6), // #FFFFFF99 (60%)
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 35,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = state.categories[index];
                    final isSelected = _selectedCategoryId == cat.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                      child: Container(
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0x80312ECB)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF007AFF)
                                : Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          cat.name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: 343,
      height: 55,
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 20),
      decoration: BoxDecoration(
        color: const Color(0x1A008500), // #0085001A
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0x1A008500), // 1px solid #0085001A
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'Everything you add here is saved only on your device.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400, // Regular
            height: 1.5, // 150% line-height
            letterSpacing: 14 * -0.05, // -5% letter-spacing
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: 343,
      height: 48,
      child: ElevatedButton(
        onPressed: _onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF312ECB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(10),
          elevation: 0,
        ),
        child: Text(
          'Save',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600, // Semi Bold
            height: 1.0, // 100% line-height
            letterSpacing: 16 * -0.03, // -3% letter-spacing
          ),
        ),
      ),
    );
  }

  void _onSave() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    if (title.isEmpty || amountText.isEmpty || _selectedCategoryId == null) {
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      return;
    }
    context.read<TransactionBloc>().add(
      TransactionAdded(
        amount: amount,
        note: title,
        type: _type,
        categoryId: _selectedCategoryId!,
      ),
    );
    context.read<DashboardBloc>().add(DashboardRefreshRequested());
    Navigator.pop(context);
  }
}
