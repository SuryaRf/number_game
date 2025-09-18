import 'dart:io';
import 'dart:math';

void main() {
  print('=== Guess Master: Difficulty + Hints (basic) ===');
  final name = _readText('Nama pemain: ');
  final level = _pickDifficulty();

  final rng = Random();
  final range = _rangeFor(level);
  final tries = _triesFor(level);
  final secret = rng.nextInt(range['max']! - range['min']! + 1) + range['min']!;

  print('Halo, $name! Tebak angka ${range['min']}..${range['max']} (max $tries percobaan).');

  int attempts = 0;
  while (attempts < tries) {
    final guess = _readInt(
      'Tebakan #${attempts + 1}: ',
      min: range['min']!, max: range['max']!,
    );
    attempts++;
    if (guess == secret) {
      print('🎉 Benar! Menang dalam $attempts percobaan.');
      return;
    }
    print(guess < secret ? 'Naikkan (terlalu kecil).' : 'Turunkan (terlalu besar).');
  }
  print('😢 Kesempatan habis. Angka rahasia: $secret');
}

String _readText(String prompt) {
  stdout.write(prompt);
  return (stdin.readLineSync() ?? '').trim();
}

String _pickDifficulty() {
  while (true) {
    stdout.write('Pilih level [E]asy/[N]ormal/[H]ard: ');
    final s = (stdin.readLineSync() ?? '').trim().toUpperCase();
    if (['E','N','H'].contains(s)) return s;
    print('Pilihan tidak valid.');
  }
}

Map<String, int> _rangeFor(String level) {
  switch (level) {
    case 'E': return {'min': 1, 'max': 50};
    case 'H': return {'min': 1, 'max': 200};
    default : return {'min': 1, 'max': 100};
  }
}

int _triesFor(String level) {
  switch (level) {
    case 'E': return 10;
    case 'H': return 6;
    default : return 8;
  }
}

int _readInt(String prompt, {required int min, required int max}) {
  while (true) {
    stdout.write(prompt);
    final s = stdin.readLineSync();
    final v = int.tryParse((s ?? '').trim());
    if (v != null && v >= min && v <= max) return v;
    print('Masukkan bilangan $min..$max.');
  }
}
