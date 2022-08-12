import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:enerhisayo/screens/home/my_homeApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:image/image.dart' as img;

class NotificationApi{

  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  

  static Future init({bool initScheduled = false}) async {
    final android= AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);

    final details = await _notifications.getNotificationAppLaunchDetails();
    if(details != null && details.didNotificationLaunchApp){
      onNotifications.add(details.payload);
    }

    await _notifications.initialize(
      settings,
      onSelectNotification: (payload) async{
        onNotifications.add(payload);
      }
    );

    if(initScheduled){ 
      tz.initializeTimeZones();
      final locationName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    }

  } 

  static Future _notificationDetails() async{
    
    final largeIconPath = await _downloadAndSaveFile('https://drive.google.com/uc?id=1RZBUiodqlKXkuLch0P5kqonV3xHUvrqR', 'largeIcon');

    ByteData imageBytes = await rootBundle.load('assets/logo.png');
    List<int> values = imageBytes.buffer.asUint8List();
    img.Image photo;
    photo = img.decodeImage(values)!;
    int pixel = photo.getPixel(5, 0);

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        importance: Importance.max,
        largeIcon: FilePathAndroidBitmap(largeIconPath)
      )
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async => _notifications.show(
    id,
    title,
    body,
    await _notificationDetails(),
    payload:payload,
  );

  static Future showScheduledNotification({ 
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate
  }) async => _notifications.zonedSchedule(
    id,
    title,
    body,
    _scheduleDaily(Time(08)),
    await _notificationDetails(),
    payload:payload,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );

  static tz.TZDateTime _scheduleDaily(Time time) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Manila'));
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 
      time.hour, time.minute, time.second);

    return scheduledDate.isBefore(now)
    ?scheduledDate.add(Duration(days: 1))
    :scheduledDate;

  }

    static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(Uri.parse(url));
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

}