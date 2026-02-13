import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const TapMasterPro());
}

class TapMasterPro extends StatelessWidget {
  const TapMasterPro({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random random = Random();
  final AudioPlayer player = AudioPlayer();
  Timer? timer;

  double targetX = 100;
  double targetY = 200;

  int score = 0;
  int timeLeft = 30;
  int level = 1;

  bool gameRunning = false;

  void startGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      level = 1;
      gameRunning = true;
    });

    moveTarget();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;

          if (score >= 10) level = 2;
          if (score >= 20) level = 3;
        });
      } else {
        t.cancel();
        setState(() {
          gameRunning = false;
        });
      }
    });
  }

  void moveTarget() {
    setState(() {
      targetX = random.nextDouble() * 300;
      targetY = random.nextDouble() * 500;
    });
  }

  Future<void> tapTarget() async {
    if (!gameRunning) return;

    await player.play(AssetSource('tap.wav'));

    setState(() {
      score++;
    });

    moveTarget();
  }

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double size;
    if (level == 1) {
      size = 80;
    } else if (level == 2) {
      size = 60;
    } else {
      size = 45;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Tap Master Pro",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Score: $score",
                  style: const TextStyle(fontSize: 22),
                ),
                Text(
                  "Time: $timeLeft",
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  "Level: $level",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                if (!gameRunning)
                  ElevatedButton(
                    onPressed: startGame,
                    child: Text(
                      timeLeft == 0 ? "Play Again" : "Start Game",
                    ),
                  ),
              ],
            ),
            if (gameRunning)
              Positioned(
                left: targetX,
                top: targetY,
                child: GestureDetector(
                  onTap: tapTarget,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 3,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
