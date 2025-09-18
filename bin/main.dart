// main.dart (Branch game-core)
import 'dart:io';
import 'dart:math';

void main() {
  print('=== Guess Master: Core ===');
  final rng = Random();
  final secret = rng.nextInt(100) + 1; // 1..100

  int attempts = 0;
  while (true) {
    final guess = _readInt('Tebak angka 1..100: ');
    attempts++;

    if (guess == secret) {
      print('🎉 Benar! Kamu butuh $attempts percobaan.');
      break;
    } else if (guess < secret) {
      print('Terlalu kecil!');
    } else {
      print('Terlalu besar!');
    }
  }
}

int _readInt(String prompt) {
  while (true) {
    stdout.write(prompt);
    final s = stdin.readLineSync();
    final v = int.tryParse((s ?? '').trim());
    if (v != null && v >= 1 && v <= 100) return v;
    print('Masukkan bilangan 1..100.');
  }
}

