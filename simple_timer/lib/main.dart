import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleTimer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: MyHomePage(title: 'Simple Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  static const platform = const MethodChannel("package.timerSound/simpletimer");
  MaterialColor isStartColor = Colors.blue,
      otherColor = Colors.blueGrey; //  ボタンの色を変えるための変数
  int time = 0, minute = 0, second = 0; //  計測時に使う方の時間
  int deftime = 0, defminute = 0, defsecond = 0; //  デフォ
  Timer mainTimer; //  タイマー部分
  bool isStop = false; //  タイマーが止まっているかどうか
  bool isTimerStart = false; //  タイマーが始まっているかどうか

  void _playTimer() {
    try {
      platform.invokeMethod("playTimer"); //  KotlinのplayTimer()を呼び出す
    } catch (e) {}
  }

  void startTimer() async //  スタートを押したときのタイマー部分
  {
    otherColor = Colors.blue;
    isStop = false;
    isTimerStart = true;
    mainTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      //  時間、分、秒すべてが0より小さくなったときにループから抜ける
      if (!isStop) {
        if (time < 0 && minute < 0 && second < 0) finishTimer();
        setState(() {
          second--;
        });
        if (second < 1) //  0秒になったとき
        {
          if (minute < 1) //  分もダメ(0)な場合
          {
            if (time < 1) //  時間もダメな場合終了
            {
              finishTimer();
            } else //  時間は残ってる場合一時間減らして分のほうに60分渡してそこから1引いて秒のほうに渡す
            {
              setState(() {
                time--;
                minute += 59;
                second += 60;
              });
            }
          } else //  分が残ってた場合
          {
            setState(() {
              minute--;
              second += 60;
            });
          }
        }
      }
    });
  }

  Future<void> finishTimer() async {
    isTimerStart = false;
    mainTimer.cancel(); //  タイマー終了
    isStartColor = Colors.blue;

    //  時間を元に戻す
    time = deftime;
    minute = defminute;
    second = defsecond;

    //  ボタンを一時的にクリック不可に
    setState(() {
      isStartColor = Colors.blueGrey;
      otherColor = Colors.blueGrey;
    });

    _playTimer();
    await Future.delayed(Duration(seconds: 4));

    //  そして戻す
    setState(() {
      isStartColor = Colors.blue;
      otherColor = Colors.blueGrey;
    });
  }

  void getTimes() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      String str = await File("${dir.path}/data.txt").readAsString();
      final times = str.split('\n');
      setState(() {
        time = int.parse(times[0]);
        deftime = time;
        minute = int.parse(times[1]);
        defminute = minute;
        second = int.parse(times[2]);
        defsecond = second;
      });
    } catch (e) {
      return;
    }
  }

  @override
  void initState() {
    getTimes();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void writeData() async {
    final dir = await getApplicationDocumentsDirectory(); //  このアプリの場所取得
    File("${dir.path}/data.txt")
        .writeAsString("$deftime\n$defminute\n$defsecond");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      writeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "残り時間\n$time 時間 $minute 分 $second 秒\n",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue, fontSize: 30),
            ),
            Row(
              // 設定ボタンなど
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  //  タイマースタート
                  onPressed: () {
                    if (isTimerStart) return;
                    if (isStartColor == Colors.blueGrey) return;
                    setState(() {
                      isStartColor = Colors.blueGrey;
                    });
                    startTimer();
                  },
                  child: Text(
                    "スタート",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: isStartColor,
                ),
                FlatButton(
                  onPressed: () {
                    if (isTimerStart) return;
                    if (isStartColor == Colors.blueGrey) return;
                    settingTimes();
                  }, //  時間設定
                  child: Text(
                    "設定",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: isStartColor,
                ),
                FlatButton(
                  //  タイマーストップ
                  onPressed: () {
                    if (otherColor == Colors.blueGrey) return;
                    if (isStop)
                      isStop = false;
                    else
                      isStop = true;
                  },
                  child: Text(
                    "ストップ",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: otherColor,
                ),
                FlatButton(
                  onPressed: () {
                    if (otherColor == Colors.blueGrey) return;
                    isStop = false;
                    isTimerStart = false;
                    setState(() {
                      time = deftime;
                      minute = defminute;
                      second = defsecond;
                      isStartColor = Colors.blue;
                      otherColor = Colors.blueGrey;
                    });
                    if (mainTimer != null) {
                      mainTimer.cancel();
                    }
                  },
                  child: Text(
                    //  タイマーリセット
                    "リセット",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: otherColor,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    writeData();
                    SystemNavigator.pop(); //  アプリを終了させる
                  },
                  child: Text("アプリを終了",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  color: Colors.blue,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void settingTimes() {
    showDialog(
      context: this.context,
      builder: (context) {
        TextEditingController tControl = TextEditingController(text: "$time"),
            mControl = TextEditingController(text: "$minute"),
            sControl = TextEditingController(text: "$second");
        return SimpleDialog(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(5),
              child: TextField(
                // 分表示
                decoration: InputDecoration(labelText: "時間"),
                enabled: true,
                maxLength: 10,
                maxLengthEnforced: true,
                controller: tControl,
                style: TextStyle(color: Colors.black),
                keyboardType: TextInputType.number,
              ),
            ),
            Container(
              margin: EdgeInsets.all(5),
              child: TextField(
                // 分表示
                decoration: InputDecoration(labelText: "分"),
                enabled: true,
                maxLength: 2,
                maxLengthEnforced: true,
                controller: mControl,
                style: TextStyle(color: Colors.black),
                keyboardType: TextInputType.number,
              ),
            ),
            Container(
              margin: EdgeInsets.all(5),
              child: TextField(
                // 分表示
                decoration: InputDecoration(labelText: "秒"),
                enabled: true,
                maxLength: 2,
                maxLengthEnforced: true,
                controller: sControl,
                style: TextStyle(color: Colors.black),
                keyboardType: TextInputType.number,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      //  入力した時間とかを保存
                      setState(() {
                        this.time = int.parse(tControl.text);
                        this.minute = int.parse(mControl.text);
                        this.second = int.parse(sControl.text);
                      });
                      //  60越えの処理
                      //  秒
                      if (this.second > 59) {
                        setState(() {
                          minute += (second / 60).round();
                          second -= (second / 60).round() * 60;
                        });
                      }
                      //  分
                      if (this.minute > 59) {
                        setState(() {
                          time += (minute / 60).round();
                          minute -= (minute / 60).round() * 60;
                        });
                      }
                      setState(() {
                        //  デフォルトの時間反映
                        deftime = time;
                        defminute = minute;
                        defsecond = second;
                      });
                      //  ダイアログ閉じる
                      Navigator.of(this.context, rootNavigator: true)
                          .pop(this.context);
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue),
                FlatButton(
                    onPressed: () {
                      //  ダイアログ閉じる
                      Navigator.of(this.context, rootNavigator: true)
                          .pop(this.context);
                    },
                    child: Text(
                      "キャンセル",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue),
              ],
            )
          ],
        );
      },
    );
  }
}
