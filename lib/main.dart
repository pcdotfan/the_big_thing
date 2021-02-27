import 'package:the_big_thing/entities/folder.dart';
import 'package:the_big_thing/entities/thing.dart';
import 'package:the_big_thing/screens/create_edit_folder.dart';
import 'package:the_big_thing/screens/create_edit_thing.dart';
import 'package:the_big_thing/screens/folder.dart';
import 'package:the_big_thing/screens/home.dart';
import 'package:the_big_thing/screens/not_found.dart';
import 'package:the_big_thing/screens/scan.dart';
import 'package:the_big_thing/screens/thing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/route_manager.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> configureLocalTimeZone() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
}

class AppComponent extends StatefulWidget {
  @override
  State createState() {
    return AppComponentState();
  }
}

class AppComponentState extends State<AppComponent> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '大事发生',
      debugShowCheckedModeBanner: false,
      unknownRoute: GetPage(name: '/not-found', page: () => NotFoundPage()),
      initialRoute: '/',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        const Locale.fromSubtags(languageCode: 'zh')
      ],
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
        GetPage(
            name: '/folders/create-edit', page: () => CreateEditFolderPage()),
        GetPage(name: '/folders/:id', page: () => FolderThings()),
        GetPage(name: '/things/create-edit', page: () => CreateEditThingPage()),
        GetPage(name: '/things/:id', page: () => ThingDetailPage()),
        GetPage(name: '/scan', page: () => ScanQRCodePage())
      ],
      theme: ThemeData(
        fontFamily: 'SourceHanSerifCN',
        primaryColor: Colors.grey.shade900,
        primaryColorLight: Colors.grey.shade800,
        primaryColorDark: Colors.black,
        secondaryHeaderColor: Colors.blue.shade700,
        accentColor: Colors.blue.shade700,
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // schedule
  await configureLocalTimeZone();
  await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/launcher_icon')),
      onSelectNotification: (String payload) async {
    if (int.parse(payload) > 0) {
      Get.toNamed('/things/' + payload);
    }
  });

  // hive
  await Hive.initFlutter();
  Hive.registerAdapter(FolderAdapter());
  Hive.registerAdapter(ThingAdapter());
  await Hive.openBox<Folder>('folders');
  await Hive.openBox<Thing>('things');

  // final foldersBox = await Hive.openBox<Folder>('folders');
  // final thingsBox = await Hive.openBox<Thing>('things');
  // foldersBox.clear();
  // thingsBox.clear();

  runApp(AppComponent());
}
