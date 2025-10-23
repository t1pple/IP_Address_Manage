import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/ip_addresses_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/ip_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IpManagerApp());
}

class IpManagerApp extends StatelessWidget {
  const IpManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => IpAddressesProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (_, s, __) {
          // ธีมที่ใช้ฟอนต์ Prompt ทั้ง Light/Dark
          final light = ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.light,
            textTheme: GoogleFonts.promptTextTheme(),
          );
          final dark = ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.dark,
            textTheme: GoogleFonts.promptTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ),
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'IP Address Manager',
            theme: light,
            darkTheme: dark,
            themeMode: s.themeMode,

            // ให้ทั้งแอปปรับขนาดฟอนต์ตาม SettingsProvider (ไม่มีอะไรหาย)
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  // Flutter 3.22+: ใช้ TextScaler
                  textScaler: TextScaler.linear(s.textScale),
                  // ถ้าเวอร์ชันเก่า ให้ใช้ textScaleFactor: s.textScale,
                ),
                child: child!,
              );
            },

            home: const IpListScreen(),
          );
        },
      ),
    );
  }
}
