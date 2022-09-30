import 'dart:async';
import 'dart:convert' show json;
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../ably/ably_flutter.dart' as ably;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Env{

  static String url = 'staging-api.quickbite.menu';
  static String path = 'api/v1/drivers/';
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) => Scaffold(
    body : Center(
      child : FlatButton(
        color : Colors.redAccent,
        padding : EdgeInsets.zero, 
        height : 40,
        child : Text(
          'PING',
          style : TextStyle(
            color : Colors.white,
            fontSize : 15,
            fontWeight : FontWeight.bold
          )
        ),
        onPressed : () async{
        },
        shape : RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        )
      )
    )
  );

  @override
  void initState(){
    init();
  }

  void init() async{
    Map data = await login('driver@qb.menu', 'abcd1234');
    ably.RealtimeChannel? chansub, chanpub;
    ably.ClientOptions options = ably.ClientOptions(
      clientId : data['id'],
      authUrl : 'https://staging-api.quickbite.menu/api/v1/drivers/ably-auth',
      authHeaders : {
        'Authorization' : data['token']
      }
    );
    ably.Realtime realtime = await ably.Realtime(options : options);
    return;
    await realtime.connection.on().listen((ably.ConnectionStateChange csc){
      print('ConnectionStateChange : ${csc}');
    });
    chansub = await realtime.channels.get('task${data['id']}');
    chanpub = await realtime.channels.get('staging.driver.location');
    await chansub.on().listen((ably.ChannelStateChange csc) async {
      print('ChannelStateChange : ${csc}');
    });
    StreamSubscription<ably.Message> subs = chansub.subscribe().listen((ably.Message message){
      print('MESSAGE : ${message}');
    });
  }

  Future<Map> login(String email, String password) async{
    Map data = {'driver' : {'email' : email, 'password' : password}};
    Map<String, String> headers = {"Content-Type" : "application/json"};
    String body = json.encode(data);
    Uri uri = Uri.https(Env.url, Env.path + 'login');
    http.Response res = await http.post(uri, headers : headers, body : body);
    if(res.statusCode != 200) return {};
    return{
      'id' : json.decode(res.body)['id'],
      'token' : res.headers['authorization'],
      'refresh' : res.headers['x-driver-refresh-token']
    };
  }
}
