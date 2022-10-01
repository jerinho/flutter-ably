import 'dart:async';
import 'dart:convert' show json;
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
      title : 'Ably',
      home : MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Env{

  static String url = 'staging-api.quickbite.menu';
  static String path = 'api/v1/drivers/';
}

class _MyHomePageState extends State<MyHomePage> {

  Map<String, User> users = {};
  BuildContext? scaffold;

  @override
  Widget build(BuildContext context){
    scaffold = context;
    return Scaffold(
      body : Builder(
        builder : (BuildContext context){
          this.scaffold = context;
          return SafeArea(
            child : Center(
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
                onPressed : ping,
                shape : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                )
              )
            )
          );
        }
      )
    );
  }

  @override
  void initState(){
    init();
  }

  void init() async{
    List<String> emails = ['driver@qb.menu', 'deen@qb.menu'];
    users.clear();
    for(String email in emails){
      User? user = await connect(email);
      if(user != null) users[email] = user;
    }
  }

  Future alert(String text){
    ScaffoldState ss = Scaffold.of(scaffold!);
    return ss.showSnackBar(SnackBar(
      duration : Duration(milliseconds : text.length * 100),
      backgroundColor : Colors.redAccent,
      content : WillPopScope(
        onWillPop: () async{
          ss.removeCurrentSnackBar();
          return true;
        },
        child: Row(
          children: <Widget>[
            Expanded(child : Text(text, style: TextStyle(
              color : Colors.white, fontSize: 18
            ))),
            IconButton(
              icon : Icon(Icons.close), color : Colors.white,
              onPressed: () => ss.removeCurrentSnackBar()
            )
          ],
        ),
      )
    )).closed;
  }

  Future<User?> connect(String email) async{
    ably.RealtimeChannel? channel;
    SharedPreferences spi = await SharedPreferences.getInstance();
    String? token = spi.getString('token.${email}');
    String? refresh = spi.getString('refresh.${email}');
    String? id = spi.getString('id.${email}');
    Map datalogin = {};
    if(token != null) datalogin = {'id' : id, 'token' : token, 'refresh' : refresh};
    if(datalogin.isEmpty){
      datalogin = await login(email, 'abcd1234');
      print('LOGIN : ${datalogin}');
      spi.setString('token.${email}', datalogin['token']);
      spi.setString('refresh.${email}', datalogin['refresh']);
      spi.setString('id.${email}', datalogin['id']);
    }
    ably.ClientOptions options = ably.ClientOptions(
      authCallback : (ably.TokenParams params) async =>
        ably.TokenDetails.fromMap(await getablytoken(datalogin) as Map<String, dynamic>)
    );
    ably.Realtime realtime = await ably.Realtime(options : options);
    await realtime.connection.on().listen((ably.ConnectionStateChange csc){
      print('ConnectionStateChange (${email}) : ${csc.current}');
    });
    channel = await realtime.channels.get('task${datalogin['id']}');
    if(channel == null) return null;
    await channel.on().listen((ably.ChannelStateChange csc) async {
      print('ChannelStateChange (${email}) : ${csc.current}');
    });
    StreamSubscription<ably.Message> subs = channel.subscribe().listen((ably.Message message){
      alert('To : ${email} : ${message.data}');
    });
    return User() .. channel = channel .. email = email .. id = id .. realtime = realtime;
  }

  Future<bool> addtarget(String email, String chanid) async{
    if(users[email] == null) return false;
    ably.RealtimeChannel? channel = await users[email]?.realtime?.channels.get('task${chanid}');
    if(channel == null) return false;
    await channel.on().listen((ably.ChannelStateChange csc) async {
      print('ChannelStateChange (${chanid}) : ${csc.current}');
    });
    users[email]?.target[chanid] = channel;
    return true;
  }

  Future<void> ping() async{
    String target = '6c7fa647-5d53-4032-8a58-0cb49934b09d';
    String user = 'deen@qb.menu';
    String text = 'Test Ably messaging';
    ably.RealtimeChannel? channel = users[user]?.target[target];
    if(channel == null) if(!(await addtarget(user, target))) return;
    if(channel == null) return;
    ably.Message message = ably.Message(clientId : target, data : text);
    channel.publish(message : message);
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

  Future<Map> getablytoken(Map data) async{
    Map<String, String> headers = {
      'Content-Type' : 'application/json',
      'authorization' : data['token'],
      'refresh' : data['refresh']
    };
    Uri uri = Uri.https(Env.url, Env.path + 'ably-token');
    http.Response res = await http.post(uri, headers : headers);
    if(res.statusCode != 200) return {};
    return json.decode(res.body);
  }
}

class User{

  String? email, id;
  ably.RealtimeChannel? channel;
  ably.Realtime? realtime;
  Map<String, ably.RealtimeChannel> target = {};
}