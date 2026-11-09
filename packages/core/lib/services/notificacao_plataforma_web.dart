import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> inicializar() async {
  if (web.Notification.permission == 'default') {
    await web.Notification.requestPermission().toDart;
  }
}

Future<void> exibir(String titulo, String corpo) async {
  if (web.Notification.permission != 'granted') return;
  web.Notification(titulo, web.NotificationOptions(body: corpo));
}
