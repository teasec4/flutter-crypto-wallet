import 'package:flutter_crypto_wallet/presentation/pages/confirmation_page.dart';
import 'package:flutter_crypto_wallet/presentation/pages/convert_page.dart';
import 'package:flutter_crypto_wallet/presentation/pages/home_page.dart';
import 'package:flutter_crypto_wallet/presentation/pages/status_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/convert',
      builder: (context, state) => const ConvertPage(),
    ),
    GoRoute(
      path: '/confirmation',
      builder: (context, state) => const ConfirmationPage(),
    ),
    GoRoute(
      path: '/status',
      builder: (context, state) => const StatusPage(),
    ),
  ],
);