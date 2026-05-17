import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routes/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/home/presentation/bloc/dashboard_bloc.dart';
import 'features/sync/presentation/bloc/sync_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const ZyboApp());
}

class ZyboApp extends StatelessWidget {
  const ZyboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DashboardBloc()),
        BlocProvider(create: (_) => TransactionBloc()),
        BlocProvider(create: (_) => CategoryBloc()),
        BlocProvider(create: (_) => SyncBloc()),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: '/',
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
