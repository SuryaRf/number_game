import 'dart:convert';
import 'dart:io';
import 'dart:math';

const _dbFile = 'leaderboard.json';

void main() {
  final leaderboard = _loadLeaderboard();
  print('=== Guess Master+ Persist ===');

  while (true) {
    final name = _readText('Nama pemain: ');
    final level = _pickDifficulty();
    final result = _playOneGame(name, level);
    leaderboard.add(result);
    _saveLeaderboard(leaderboard);

    _printLeaderboard(leaderboard);
    _printAnalytics(leaderboard);

    stdout.write('Main lagi? (y/n): ');
    if ((stdin.readLineSync() ?? '').trim().toLowerCase() != 'y') break;
    print('');
  }
  print('Data tersimpan di $_dbFile. 👋');
}

// ======= GAME LOGIC (sama seperti branch sebelumnya) =======
Map<String, dynamic> _playOneGame(String name, String level) {
  final rng = Random();
  final range = _rangeFor(level);
  final tries = _triesFor(level);
  final secret = rng.nextInt(range['max']! - range['min']! + 1) + range['min']!;
  final mult = _multiplierFor(level);

  print('Hai ${name.isEmpty ? "Player" : name}! Tebak ${range['min']}..${range['max']} (max $tries).');
  int attempts = 0; var won = false;

  while (attempts < tries) {
    final guess = _readInt('Tebakan #${attempts + 1}: ', min: range['min']!, max: range['max']!);
    attempts++;
    if (guess == secret) { print('🎉 Benar!'); won = true; break; }

    print(guess < secret ? 'Naikkan.' : 'Turunkan.');
    final dist = (guess - secret).abs();
    if (dist <= (range['max']! * 0.02)) print('🔥 Sangat dekat!');
    else if (dist <= (range['max']! * 0.05)) print('✨ Cukup hangat.');
    else print('❄️  Masih jauh.');

    if (attempts == 1) print('Paritas target: ${secret.isEven ? "GENAP" : "GANJIL"}');
    if (attempts == 2) {
      final hints = <String>[];
      if (secret % 3 == 0) hints.add('kelipatan 3');
      if (secret % 5 == 0) hints.add('kelipatan 5');
      if (secret % 7 == 0) hints.add('kelipatan 7');
      if (hints.isNotEmpty) print('Tambahan: ${hints.join(", ")}');
    }
  }
  if (!won) print('😢 Habis. Angka: (rahasia)');

  final base = 1000 * mult;
  final bonus = (tries - attempts).clamp(0, tries) * 50;
  final score = won ? (base + bonus) : (base ~/ 10);

  print('Skor: $score');
  return {
    'name': name.isEmpty ? 'Player' : name,
    'level': _labelFor(level),
    'score': score,
    'attempts': attempts,
    'won': won,
    'time': DateTime.now().toIso8601String(),
  };
}

// ======= I/O & UTIL =======
List<Map<String, dynamic>> _loadLeaderboard() {
  final file = File(_dbFile);
  if (!file.existsSync()) return [];
  try {
    final raw = jsonDecode(file.readAsStringSync());
    return (raw as List).cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
}

void _saveLeaderboard(List<Map<String, dynamic>> data) {
  final file = File(_dbFile);
  file.writeAsStringSync(jsonEncode(data), flush: true);
}

void _printLeaderboard(List<Map<String, dynamic>> data){
  if(data.isEmpty){ print('\nBelum ada leaderboard.'); return; }
  final sorted=[...data]..sort((a,b)=>(b['score'] as int).compareTo(a['score'] as int));
  final top=sorted.take(5).toList();
  print('\n🏆 LEADERBOARD (Top 5)');
  print('No | Nama        | Level  | Skor  | Perc | Hasil | Waktu');
  print('---+-------------+--------+-------+------+-------+-------------------------');
  for(int i=0;i<top.length;i++){
    final r=top[i];
    print('${(i+1).toString().padLeft(2)} | '
          '${(r['name'] as String).padRight(11)} | '
          '${(r['level'] as String).padRight(6)} | '
          '${(r['score'] as int).toString().padLeft(5)} | '
          '${(r['attempts'] as int).toString().padLeft(4)} | '
          '${(r['won'] as bool) ? "WIN " : "LOSE"} | '
          '${(r['time'] as String)}');
  }
}

void _printAnalytics(List<Map<String, dynamic>> data){
  final total=data.length;
  final wins=data.where((e)=>e['won']==true).length;
  final avgAttempts=(data.map((e)=>e['attempts'] as int).fold<int>(0,(a,b)=>a+b)/total);
  final winRate=total==0?0.0:(wins*100.0/total);
  print('\n📈 Analytics: Total $total | Win ${wins} (${winRate.toStringAsFixed(1)}%) | Avg Attempts ${avgAttempts.toStringAsFixed(2)}\n');
}

String _readText(String prompt){ stdout.write(prompt); return (stdin.readLineSync()??'').trim(); }
String _pickDifficulty(){ while(true){ stdout.write('Level [E/N/H]: '); final s=(stdin.readLineSync()??'').trim().toUpperCase(); if(['E','N','H'].contains(s)) return s; print('Pilihan tidak valid.'); } }
Map<String,int> _rangeFor(String l){switch(l){case 'E':return{'min':1,'max':50};case'H':return{'min':1,'max':200};default:return{'min':1,'max':100};}}
int _triesFor(String l){switch(l){case 'E':return 10;case'H':return 6;default:return 8;}}
int _multiplierFor(String l){switch(l){case 'E':return 1;case'H':return 3;default:return 2;}}
String _labelFor(String l){switch(l){case 'E':return 'Easy';case'H':return 'Hard';default:return 'Normal';}}
int _readInt(String prompt,{required int min,required int max}){ while(true){ stdout.write(prompt); final s=stdin.readLineSync(); final v=int.tryParse((s??'').trim()); if(v!=null&&v>=min&&v<=max) return v; print('Masukkan bilangan $min..$max.'); } }
