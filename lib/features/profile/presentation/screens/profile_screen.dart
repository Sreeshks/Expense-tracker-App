import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../../categories/presentation/bloc/category_state.dart';

import '../../../sync/presentation/bloc/sync_bloc.dart';
import '../../../sync/presentation/bloc/sync_event.dart';
import '../../../sync/presentation/bloc/sync_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _categoryController = TextEditingController();
  final _limitController = TextEditingController();
  final _nicknameController = TextEditingController();
  String _nickname = 'User';
  double _currentLimit = 1000;
  bool _isEditingNickname = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    context.read<CategoryBloc>().add(CategoriesLoadRequested());
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString(ApiConstants.nicknameKey) ?? 'User';
      _currentLimit = prefs.getDouble('monthly_limit') ?? 1000;
      _nicknameController.text = _nickname;
    });
  }

  Future<void> _saveLimit() async {
    final amount = double.tryParse(_limitController.text.trim());
    if (amount == null || amount <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_limit', amount);
    setState(() => _currentLimit = amount);
    _limitController.clear();
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _saveNickname() async {
    final name = _nicknameController.text.trim();
    if (name.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.nicknameKey, name);
    setState(() {
      _nickname = name;
      _isEditingNickname = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.nicknameKey);
    await prefs.remove(ApiConstants.phoneKey);
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/phone', (route) => false);
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _limitController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 20),
            Text(
              'Profile & Settings',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // --- NICKNAME ---
            _sectionLabel('NICKNAME'),
            const SizedBox(height: 8),
            _buildNicknameRow(),
            const SizedBox(height: 24),

            // --- ALERT LIMIT ---
            _sectionLabel('ALERT LIMIT (₹)'),
            const SizedBox(height: 8),
            _buildLimitRow(),
            const SizedBox(height: 6),
            Text(
              'Current Limit: ₹${_currentLimit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),

            // --- CATEGORIES ---
            _sectionLabel('CATEGORIES'),
            const SizedBox(height: 8),
            _buildAddCategoryRow(),
            const SizedBox(height: 12),
            _buildCategoryList(),
            const SizedBox(height: 24),

            // --- CLOUD SYNC ---
            _sectionLabel('CLOUD SYNC'),
            const SizedBox(height: 8),
            _buildSyncCard(),
            const SizedBox(height: 24),

            // --- LOG OUT ---
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.4),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildNicknameRow() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _isEditingNickname
                ? TextField(
                    controller: _nicknameController,
                    autofocus: true,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                    onSubmitted: (_) => _saveNickname(),
                  )
                : Text(
                    _nickname,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
          ),
          GestureDetector(
            onTap: () {
              if (_isEditingNickname) {
                _saveNickname();
              } else {
                setState(() => _isEditingNickname = true);
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isEditingNickname ? Icons.check : Icons.edit_outlined,
                color: Colors.white.withValues(alpha: 0.6),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _limitController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Amount  (₹)',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _saveLimit,
          child: Container(
            height: 46,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF312ECB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Set',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCategoryRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _categoryController,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'New category Name',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            final name = _categoryController.text.trim();
            if (name.isNotEmpty) {
              context.read<CategoryBloc>().add(CategoryAdded(name));
              _categoryController.clear();
              FocusScope.of(context).unfocus();
            }
          },
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF312ECB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state.categories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No categories added yet.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          );
        }
        return Column(
          children: state.categories.map((cat) {
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cat.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.read<CategoryBloc>().add(
                      CategoryDeleted(cat.id),
                    ),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFFF4444),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSyncCard() {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        final isSyncing = state.status == SyncStatus.syncing;
        return GestureDetector(
          onTap: isSyncing
              ? null
              : () => context.read<SyncBloc>().add(SyncRequested()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1DB954), Color(0xFF16873D)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync To Cloud',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sync and update data to the backend',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSyncing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Image.asset(
                    'assets/cloud.png',
                    width: 28,
                    height: 28,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Log Out',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF4444),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.power_settings_new,
              color: Color(0xFFFF4444),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
