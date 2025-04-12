import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PrivateChatScreen extends StatefulWidget {
  @override
  _PrivateChatScreenState createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  GoogleMapController? mapController;
  LatLng? branchLocation;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications(); // تهيئة الإشعارات
    connectToSocket(); // الاتصال بـ Socket.io
  }

  // تهيئة الإشعارات
  void initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  // الاتصال بـ Socket.io
  void connectToSocket() {
    socket = IO.io('https://socket.goalmasters.online', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.emit('register', 115);

    socket.on('connect', (_) {
      print('Connected to Socket');
    });

    socket.on('private-message', (data) {
      print('Received Message: $data');

      final message = {
        'receiver': data['text']?['receiver'] ?? 'غير معروف',
        'sender': data['sender'] ?? 'غير معروف',
        'msg': data['text']?['msg'] ?? 'رسالة غير معروفة',
        'bookingId': data['text']?['booking_id']?['id'] ?? 'غير متاح',
        'branchName': data['text']?['branch_id']?['name'] ?? 'غير متاح',
        'lat': data['text']?['branch_id']?['lat'],
        'long': data['text']?['branch_id']?['long'],
      };

      setState(() {
        messages.add(message);
        if (message['lat'] != null && message['long'] != null) {
          branchLocation = LatLng(message['lat'], message['long']);
          mapController?.moveCamera(CameraUpdate.newLatLng(branchLocation!));
        }
      });

      // عرض الإشعار عند استلام رسالة جديدة
      _showNotification(message['msg'], message['branchName']);
    });

    socket.on('disconnect', (_) {
      print('Disconnected from Socket');
    });
  }

  // عرض إشعار عند استلام الرسالة
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id', // يجب أن يكون ثابت
      'Channel Name',
      channelDescription: 'وصف القناة',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📩 الدردشة الخاصة')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final googleMapsUrl =
                    "https://www.google.com/maps/search/?api=1&query=${message['lat']},${message['long']}";

                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("👤 المرسل إليه: ${message['receiver']}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        Text("📢 من: ${message['sender']}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        Text("💬 ${message['msg']}"),
                        Text("📌 حجز رقم: ${message['bookingId']}"),
                        Text("🏢 الفرع: ${message['branchName']}"),
                        if (message['lat'] != null && message['long'] != null)
                          TextButton(
                            onPressed: () => _openMap(googleMapsUrl),
                            child: Text("📍 افتح في خرائط Google"),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 300,
            child: branchLocation != null
                ? GoogleMap(
                    onMapCreated: (controller) => mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: branchLocation!,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId("branchLocation"),
                        position: branchLocation!,
                        infoWindow: InfoWindow(title: "📍 موقع الفرع"),
                      )
                    },
                  )
                : Center(child: Text("لا يوجد موقع لعرضه")),
          ),
        ],
      ),
    );
  }

  void _openMap(String url) {
    print("فتح الرابط: $url");
  }
}
