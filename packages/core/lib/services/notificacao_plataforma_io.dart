import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _plugin = FlutterLocalNotificationsPlugin();
var _id = 0;
var _pronto = false;

Future<void> inicializar() async {
  if (_pronto) return;
  final ok = await _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      windows: WindowsInitializationSettings(
        appName: 'SIV',
        appUserModelId: 'br.com.siv.front',
        guid: '6f0c3b1e-5d2a-4c7e-9a41-2b8d7e3f5a10',
      ),
    ),
  );
  _pronto = ok ?? false;
}

Future<void> exibir(String titulo, String corpo) async {
  if (!_pronto) return;
  await _plugin.show(
    id: _id++,
    title: titulo,
    body: corpo,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails('notificacoes', 'Notificações'),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      windows: WindowsNotificationDetails(),
    ),
  );
}
