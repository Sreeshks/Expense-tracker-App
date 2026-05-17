import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(CategoriesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAddDialog(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.status == CategoryStatus.loading
                      ? _buildShimmer()
                      : state.categories.isEmpty
                          ? _buildEmpty()
                          : _buildList(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (_, i) => Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.shimmer,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'No categories yet.\nTap + to add one.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.4)),
      ),
    );
  }

  Widget _buildList(BuildContext context, CategoryState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final cat = state.categories[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF312ECB).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF312ECB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cat.name,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
              if (cat.isSynced == 1)
                Icon(Icons.cloud_done_outlined, color: Colors.white.withValues(alpha: 0.3), size: 16),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.read<CategoryBloc>().add(CategoryDeleted(cat.id)),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.delete_outline, color: Color(0xFFFF4444), size: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add Category', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Category name',
              hintStyle: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.3)),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5))),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  context.read<CategoryBloc>().add(CategoryAdded(name));
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF312ECB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Add', style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
