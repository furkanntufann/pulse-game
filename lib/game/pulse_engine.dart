import 'dart:math';

import '../models/hit_result.dart';

/// Genişleyen nabız halkası.
class PulseRing {
  PulseRing({
    required this.radius,
    required this.speed,
    required this.targetRadius,
    required this.isDecoy,
    required this.spawnedAt,
  });

  double radius;
  final double speed;
  final double targetRadius;
  final bool isDecoy;
  final double spawnedAt;

  void update(double now, double dt) {
    radius += speed * dt;
  }

  bool get isExpired => radius > targetRadius * 2.45;
}

/// Sonsuz nabız oyununun çekirdek mantığı.
class PulseEngine {
  PulseEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const int maxLives = 3;
  static const double baseTargetRadius = 118;
  static const double perfectWindow = 16;
  static const double goodWindow = 32;

  // Başlangıç yavaş, orta-geç oyun daha sert rampa
  static const double _baseSpeed = 68;
  static const double _speedPerDifficulty = 3.8;
  static const double _maxSpeed = 267.75;
  static const double _difficultyPerfect = 0.85;
  static const double _difficultyGood = 0.55;

  int score = 0;
  int combo = 0;
  int lives = maxLives;
  int bestScore = 0;
  int bestCombo = 0;
  int pulsesLanded = 0;

  double difficulty = 0;
  bool isGameOver = false;
  bool waitingForNextPulse = false;

  PulseRing? activePulse;
  double _lastSpawnTime = 0;
  double _spawnDelay = 0.4;

  double get targetRadius => baseTargetRadius + sin(difficulty * 0.18) * 6;

  void reset() {
    score = 0;
    combo = 0;
    lives = maxLives;
    difficulty = 0;
    isGameOver = false;
    waitingForNextPulse = false;
    activePulse = null;
    pulsesLanded = 0;
    _lastSpawnTime = 0;
    _spawnDelay = 0.52;
  }

  void update(double now, double dt) {
    if (isGameOver) return;

    final pulse = activePulse;
    if (pulse != null) {
      pulse.update(now, dt);
      if (pulse.isExpired) {
        if (pulse.isDecoy) {
          _dismissDecoy();
        } else {
          _onMiss();
        }
        activePulse = null;
        waitingForNextPulse = true;
        _lastSpawnTime = now;
        _spawnDelay = pulse.isDecoy ? 0.3 : 0.36;
      }
      return;
    }

    if (waitingForNextPulse && now - _lastSpawnTime >= _spawnDelay) {
      _spawnPulse(now);
      waitingForNextPulse = false;
    }
  }

  void _spawnPulse(double now) {
    final speed = min(
      _baseSpeed + difficulty * _speedPerDifficulty + _random.nextDouble() * 14,
      _maxSpeed,
    );
    final isDecoy = _random.nextDouble() < min(0.12 + difficulty * 0.007, 0.32);

    activePulse = PulseRing(
      radius: 24,
      speed: speed,
      targetRadius: targetRadius,
      isDecoy: isDecoy,
      spawnedAt: now,
    );
  }

  HitResult? tap() {
    if (isGameOver) return null;

    final pulse = activePulse;
    if (pulse == null) return null;

    if (pulse.isDecoy) {
      _onDecoyTap();
      activePulse = null;
      waitingForNextPulse = true;
      _lastSpawnTime = pulse.spawnedAt;
      _spawnDelay = 0.32;
      return HitResult.trap;
    }

    final delta = (pulse.radius - pulse.targetRadius).abs();

    HitResult result;
    if (delta <= perfectWindow) {
      result = HitResult.perfect;
    } else if (delta <= goodWindow) {
      result = HitResult.good;
    } else {
      result = HitResult.miss;
    }

    if (result == HitResult.miss) {
      _onMiss();
    } else {
      _onHit(result);
    }

    activePulse = null;
    waitingForNextPulse = true;
    _lastSpawnTime = pulse.spawnedAt;
    _spawnDelay = result == HitResult.perfect ? 0.3 : 0.38;

    return result;
  }

  void _onHit(HitResult result) {
    combo++;
    if (combo > bestCombo) bestCombo = combo;

    // Her 10 combo: +1 can (en fazla maxLives)
    if (combo > 0 && combo % 10 == 0) {
      lives = min(lives + 1, maxLives);
    }

    final multiplier = 1 + (combo ~/ 5);
    final base = result == HitResult.perfect ? 100 : 50;
    score += base * multiplier;
    pulsesLanded++;
    difficulty += result == HitResult.perfect ? _difficultyPerfect : _difficultyGood;

    if (score > bestScore) bestScore = score;
  }

  /// Pembe tuzak süresi doldu — dokunulmadı, ceza yok.
  void _dismissDecoy() {}

  /// Pembe tuzak — dokunuldu: can gider, combo sıfırlanır.
  void _onDecoyTap() {
    combo = 0;
    lives--;
    difficulty = max(0, difficulty - 1);
    if (lives <= 0) {
      isGameOver = true;
    }
  }

  void _onMiss() {
    combo = 0;
    lives--;
    difficulty = max(0, difficulty - 2);
    if (lives <= 0) {
      isGameOver = true;
    }
  }

  void continueAfterReward({
    required int extraLives,
    required double now,
  }) {
    if (!isGameOver) return;
    lives = min(maxLives, lives + extraLives);
    if (lives <= 0) {
      lives = 1;
    }
    isGameOver = false;
    activePulse = null;
    waitingForNextPulse = true;
    _lastSpawnTime = now;
    _spawnDelay = 0.4;
  }

  /// İlk nabızı başlatmak için.
  void start(double now) {
    reset();
    _spawnPulse(now);
  }
}
