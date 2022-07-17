import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _Timer(),
    );
  }
}

class _Timer extends StatefulWidget {
  _Timer({Key? key}) : super(key: key);

  @override
  State<_Timer> createState() => __TimerState();
}

class __TimerState extends State<_Timer> {
  late StreamSubscription<int> subscription; // Stream을 제어할 변수
  int? _currentTick; // 현재 초
  bool _isPaused = false; // 현재 초가 멈췄는지 여부 확인

  @override
  void initState() {
    super.initState();
    _start(30); // 시간을 30으로 최초 설정
  }

  // 최초 시간 설정해서 타이머 하는 함수
  void _start(int duration) {
    // 초가 흘러가는 것을 언제든지 listen 하고 있다.
    subscription = Ticker().tick(ticks: duration).listen((value) {
      // 즉각적으로 변화하는 값을 setState()를 통해 즉시 반영
      setState(() {
        _isPaused = false;
        _currentTick = value;
      });
    });
  }

  // 멈췄던 시간부터 타이머 하는 함수
  void _resume() {
    setState(() {
      _isPaused = false;
    });

    subscription.resume();
  }

  // 시간을 멈추는 함수
  void _stop() {
    setState(() {
      _isPaused = true;
    });

    subscription.pause();
  }

  // 화면 꾸미기
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            width: 100.0,
            height: 100.0,
            color: Colors.black,
            child: Text(
              _currentTick == null ? '' : _currentTick.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 45.0),
            ),
          ),

          SizedBox(
            // 약간 여백을 준다.
            height: 20,
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Restart Button
              ElevatedButton(
                  style: circle(),
                  onPressed: () {
                    subscription.cancel();
                    _start(30);
                  },
                  child: Text('Restart')),

              SizedBox(
                // 약간 여백을 준다.
                width: 20,
              ),

              // Resume Button & Stop Button
              ElevatedButton(
                  style: circle(),
                  onPressed: () {
                    _isPaused ? _resume() : _stop();
                  },
                  child: Text(_isPaused ? 'Resume' : 'Stop'))
            ],
          )
        ],
      ),
    );
  }

  // Button Style 둥글게 하는 함수 (외곽 테두리  18.0 둥글게 합니다...)
  ButtonStyle circle() {
    return ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))));
  }
}

// 초가 어떻게 흘러가는지 나타내는  함수
class Ticker {
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(
        Duration(seconds: 1), // 지속기간
        (x) => ticks - x).take(ticks + 1); // x가 0부터 시작, ticks가 30이고, 31번 반복 실행
  }
}
