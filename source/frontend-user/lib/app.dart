// app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/product/providers/product_provider.dart';
import 'features/product/providers/product_type_provider.dart';
import 'features/product/providers/review_provider.dart'; // Import ReviewProvider
import 'features/navigation/providers/navigation_provider.dart';
import 'features/payment/payment_feature.dart'; // Import PaymentFeature
import 'features/support/presentation/providers/message_provider.dart'; // Thêm import MessageProvider
import 'features/profile/data/repositories/address_provider.dart'; // Import AddressProvider
import 'widgets/main_layout.dart';
import 'core/routes/app_router.dart';
import 'package:frontend_user/features/build_pc/providers/pc_provider.dart';
import 'package:frontend_user/features/build_pc/presentation/screens/build_configuration_screen.dart';
import 'package:frontend_user/features/build_pc/presentation/screens/saved_builds_screen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()), // Keep one CartProvider
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ProductTypeProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()), // Thêm ReviewProvider
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        // Add PaymentProvider using the static method from PaymentFeature
        ...PaymentFeature.getProviders(),
        ChangeNotifierProvider(create: (context) => PCProvider()),
        ChangeNotifierProvider(create: (context) => AddressProvider()),
        ChangeNotifierProxyProvider<AuthProvider, MessageProvider>(
          create: (context) => MessageProvider(context.read<AuthProvider>()),
          update: (context, auth, previousMessages) => MessageProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Personal Computer Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: false,
          scaffoldBackgroundColor: kIsWeb ? const Color(0xFFF5F5F5) : null,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
              TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        home: const MainLayout(),
        routes: {
          '/build_pc': (context) => const BuildConfigurationScreen(),
          '/saved_builds': (context) => const SavedBuildsScreen(),
        },
      ),
    );
  }
}