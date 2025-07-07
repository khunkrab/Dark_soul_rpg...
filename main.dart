import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(DarkSoulRPG());

class DarkSoulRPG extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark Soul RPG',
      home: NameInputPage(),
    );
  }
}

class PlayerClass {
  final String name;
  final int hp;
  final int atk;
  final String skill;
  final String skillDesc;

  PlayerClass(this.name, this.hp, this.atk, this.skill, this.skillDesc);
}

final classes = [
  PlayerClass("นักรบ", 150, 15, "ฟันแรง", "โจมตี x2"),
  PlayerClass("จอมเวทย์", 100, 20, "เวทย์ไฟ", "โจมตีเวทย์ 40-60"),
  PlayerClass("นักธนู", 120, 12, "ยิงทะลุ", "โจมตีไม่ลดดาเมจ"),
  PlayerClass("คาบอร์ด", 180, 10, "โล่สะท้อน", "สะท้อนความเสียหายครึ่งหนึ่ง"),
];

class Player {
  String name;
  PlayerClass playerClass;
  int gold = 50;
  int xp = 0;
  int level = 1;
  int weaponBonus = 0;

  Player({required this.name, required this.playerClass});
}

class Enemy {
  String name;
  int hp;
  int atk;
  int goldReward;
  int xpReward;

  Enemy({required this.name, required this.hp, required this.atk, required this.goldReward, required this.xpReward});
}

class NameInputPage extends StatefulWidget {
  @override
  _NameInputPageState createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  final _controller = TextEditingController();

  void goToClassSelection() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassSelectionPage(playerName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("กรอกชื่อตัวละคร")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "ชื่อของคุณ"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: goToClassSelection,
              child: Text("ถัดไป"),
            ),
          ],
        ),
      ),
    );
  }
}

class ClassSelectionPage extends StatelessWidget {
  final String playerName;

  ClassSelectionPage({required this.playerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("เลือกคลาส")),
      body: ListView.builder(
        itemCount: classes.length,
        itemBuilder: (_, index) {
          final c = classes[index];
          return ListTile(
            title: Text("\${c.name} - HP: \${c.hp}, ATK: \${c.atk}"),
            subtitle: Text("สกิล: \${c.skill} (\${c.skillDesc})"),
            onTap: () {
              final player = Player(name: playerName, playerClass: c);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatusPage(player: player),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StatusPage extends StatelessWidget {
  final Player player;

  StatusPage({required this.player});

  @override
  Widget build(BuildContext context) {
    final pc = player.playerClass;

    return Scaffold(
      appBar: AppBar(title: Text("สถานะของ \${player.name}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🧍‍♂️ \${player.name} (คลาส: \${pc.name})", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("เลเวล: \${player.level}"),
            Text("HP: \${pc.hp}"),
            Text("ATK: \${pc.atk} (+\${player.weaponBonus})"),
            Text("ทอง: \${player.gold}"),
            Text("XP: \${player.xp}"),
            Text("สกิล: \${pc.skill} - \${pc.skillDesc}"),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("ไปต่อสู้กับศัตรู"),
              onPressed: () {
                Enemy enemy = Enemy(name: "ศัตรูธรรมดา", hp: 100, atk: 10, goldReward: 20, xpReward: 15);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BattlePage(player: player, enemy: enemy),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text("สู้กับบอส"),
              onPressed: () {
                Enemy boss = Enemy(name: "บอสไฟ", hp: 300, atk: 25, goldReward: 100, xpReward: 60);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BattlePage(player: player, enemy: boss, isBoss: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BattlePage extends StatefulWidget {
  final Player player;
  final Enemy enemy;
  final bool isBoss;

  BattlePage({required this.player, required this.enemy, this.isBoss = false});

  @override
  _BattlePageState createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  late int playerHp;
  late int enemyHp;
  String battleLog = "";

  @override
  void initState() {
    super.initState();
    playerHp = widget.player.playerClass.hp;
    enemyHp = widget.enemy.hp;
  }

  void attackEnemy() {
    int damage = widget.player.playerClass.atk + widget.player.weaponBonus;
    int enemyDamage = widget.enemy.atk;

    setState(() {
      enemyHp -= damage;
      if (enemyHp > 0) {
        playerHp -= enemyDamage;
        battleLog = "คุณโจมตีศัตรู \$damage dmg, โดนสวนกลับ \$enemyDamage dmg";
      } else {
        battleLog = "คุณชนะศัตรู! ได้ทอง \${
          widget.enemy.goldReward} และ XP \${
          widget.enemy.xpReward}";
        widget.player.gold += widget.enemy.goldReward;
        widget.player.xp += widget.enemy.xpReward;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isBoss ? "🔥 บอสไฟต์" : "⚔️ การต่อสู้")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👹 \${widget.enemy.name} - HP: \$enemyHp"),
            Text("🧍‍♂️ คุณ - HP: \$playerHp"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (enemyHp <= 0 || playerHp <= 0) ? null : attackEnemy,
              child: Text("โจมตี"),
            ),
            SizedBox(height: 20),
            Text(battleLog, style: TextStyle(fontSize: 16)),
            if (enemyHp <= 0 || playerHp <= 0)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("กลับ"),
              ),
          ],
        ),
      ),
    );
  }
}