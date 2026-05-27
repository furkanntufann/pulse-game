import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/pulse_engine.dart';
import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
import '../models/hit_result.dart';
import '../services/ad_service.dart';
import '../services/locale_service.dart';
import '../services/storage_service.dart';
import 'language_flag_button.dart';
import 'mobile_game_frame.dart';
import 'pulse_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final PulseEngine _engine = PulseEngine();
  final StorageService _storage = StorageService();
  final LocaleService _localeService = LocaleService();
  final AdService _adService = AdService();

  AppLocale _locale = AppLocale.tr;
  late AppStrings _s = const AppStrings(AppLocale.tr);

  late final Ticker _ticker;
  double _lastTickSeconds = 0;
  double _pulseTime = 0;

  int _storedBest = 0;
  int _storedToday = 0;

  HitResult? _lastHit;
  double _hitFlash = 0;
  String? _floatingText;
  double _floatingOpacity = 0;

  bool _started = false;
  bool _runSaved = false;
  bool _isRewardLoading = false;

  int get _displayBest =>
      _started ? (_storedBest > _engine.score ? _storedBest : _engine.score) : _storedBest;

  int get _displayToday =>
      _started ? (_storedToday > _engine.score ? _storedToday : _engine.score) : _storedToday;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initializeAds();
    _ticker = createTicker(_onTick)..start();
  }

  Future<void> _initializeAds() async {
    await _adService.initialize();
    if (!mounted) return;
    _adService.maybeShowStartupInterstitial(delay: const Duration(seconds: 3));
  }

  Future<void> _loadInitialData() async {
    final locale = await _localeService.load();
    final best = await _storage.loadBestScore();
    final today = await _storage.loadTodayBest();
    final bestCombo = await _storage.loadBestCombo();
    if (!mounted) return;
    setState(() {
      _locale = locale;
      _s = AppStrings(locale);
      _storedBest = best;
      _storedToday = today;
      _engine.bestScore = best;
      _engine.bestCombo = bestCombo;
    });
  }

  Future<void> _setLocale(AppLocale locale) async {
    await _localeService.save(locale);
    if (!mounted) return;
    setState(() {
      _locale = locale;
      _s = AppStrings(locale);
    });
  }

  void _onTick(Duration elapsed) {
    final seconds = elapsed.inMicroseconds / 1e6;
    if (_lastTickSeconds == 0) _lastTickSeconds = seconds;
    final dt = (seconds - _lastTickSeconds).clamp(0.0, 0.05).toDouble();
    _lastTickSeconds = seconds;
    _pulseTime += dt;

    if (_started && !_engine.isGameOver) {
      _engine.update(seconds, dt);
    }

    if (_started && _engine.isGameOver && !_runSaved) {
      _saveRunAndRefreshHud();
    }

    if (_hitFlash > 0) {
      _hitFlash = (_hitFlash - dt * 2.5).clamp(0.0, 1.0).toDouble();
    }
    if (_floatingOpacity > 0) {
      _floatingOpacity = (_floatingOpacity - dt * 1.2).clamp(0.0, 1.0).toDouble();
    }

    setState(() {});
  }

  void _onTap() {
    if (!_started) {
      setState(() {
        _started = true;
        _runSaved = false;
        _engine.start(_lastTickSeconds);
      });
      return;
    }

    if (_engine.isGameOver) {
      return;
    }

    final result = _engine.tap();
    if (result == null) return;

    _lastHit = result;
    _hitFlash = 1;

    switch (result) {
      case HitResult.perfect:
        _floatingText = _s.perfectHit(_engine.combo);
        HapticFeedback.mediumImpact();
        break;
      case HitResult.good:
        _floatingText = _s.goodHit(_engine.combo);
        HapticFeedback.lightImpact();
        break;
      case HitResult.miss:
        _floatingText = _s.missed;
        HapticFeedback.heavyImpact();
        break;
      case HitResult.trap:
        _floatingText = _s.trapHit;
        HapticFeedback.heavyImpact();
        break;
    }
    _floatingOpacity = 1;

    if (_engine.isGameOver) {
      _saveRunAndRefreshHud();
    }
  }

  Future<void> _saveRunAndRefreshHud() async {
    if (_runSaved || !_started) return;
    _runSaved = true;

    final saved = await _storage.persistRun(
      score: _engine.score,
      combo: _engine.bestCombo,
    );
    if (!mounted) return;
    setState(() {
      _storedBest = saved.bestScore;
      _storedToday = saved.todayScore;
      _engine.bestScore = saved.bestScore;
      _engine.bestCombo = saved.bestCombo;
    });

    await _adService.maybeShowDeathInterstitial();
  }

  Future<void> _restartAfterGameOver() async {
    await _saveRunAndRefreshHud();
    if (!mounted) return;
    setState(() {
      _runSaved = false;
      _engine.start(_lastTickSeconds);
      _lastHit = null;
      _hitFlash = 0;
      _floatingText = null;
      _floatingOpacity = 0;
    });
  }

  Future<void> _continueWithRewardedAd() async {
    if (_isRewardLoading) return;
    if (!_adService.hasRewardedAd) {
      _showInfoSnack(_s.rewardAdNotReady);
      return;
    }
    setState(() => _isRewardLoading = true);
    await _adService.showRewardedForContinue(
      onRewardEarned: () {
        _engine.continueAfterReward(
          extraLives: 2,
          now: _lastTickSeconds,
        );
        _runSaved = false;
      },
    );
    if (!mounted) return;
    setState(() {
      _isRewardLoading = false;
    });
  }

  void _showInfoSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      body: SafeArea(
        child: MobileGameFrame(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onTap,
            child: Column(
              children: [
                _buildHud(),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: _started ? 1.0 : 0.22,
                        child: CustomPaint(
                          painter: PulsePainter(
                            engine: _engine,
                            hitFlash: _hitFlash,
                            hitResult: _lastHit,
                            pulseTime: _pulseTime,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                      if (!_started) Positioned.fill(child: _buildStartOverlay()),
                      if (_engine.isGameOver) _buildGameOverOverlay(),
                      if (_floatingText != null && _floatingOpacity > 0)
                        Opacity(
                          opacity: _floatingOpacity,
                          child: Text(
                            _floatingText!,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _colorForHit(_lastHit),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHowToPlay() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF14141F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _s.howToPlay,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _howToRow(
              color: const Color(0xFF7C4DFF),
              title: _s.howPurpleTitle,
              body: _s.howPurpleBody,
            ),
            _howToRow(
              color: const Color(0xFF00E5C8),
              title: _s.howPerfectTitle,
              body: _s.howPerfectBody,
            ),
            _howToRow(
              color: const Color(0xFFFF6B9D),
              title: _s.howTrapTitle,
              body: _s.howTrapBody,
            ),
            _howToRow(
              color: const Color(0xFFFF5252),
              title: _s.howMissTitle,
              body: _s.howMissBody,
            ),
            _howToRow(
              color: const Color(0xFFFF4081),
              title: _s.howLivesTitle,
              body: _s.howLivesBody,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5C8),
                  foregroundColor: const Color(0xFF0A0A12),
                ),
                child: Text(_s.gotIt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _howToRow({
    required Color color,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForHit(HitResult? hit) {
    return switch (hit) {
      HitResult.perfect => const Color(0xFF00E5C8),
      HitResult.good => const Color(0xFFFFD54F),
      HitResult.miss => const Color(0xFFFF5252),
      HitResult.trap => const Color(0xFFFF6B9D),
      null => Colors.white70,
    };
  }

  Widget _buildHud() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_engine.score}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                _s.recordTodayLine(_displayBest, _displayToday),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: List.generate(
                  PulseEngine.maxLives,
                  (i) => Icon(
                    Icons.favorite,
                    size: 22,
                    color: i < _engine.lives
                        ? const Color(0xFFFF4081)
                        : Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _started
                    ? _s.comboCount(_engine.combo)
                    : _s.gameTitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: _started ? 0 : 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartOverlay() {
    return Stack(
      children: [
        Positioned(
          top: 8,
          right: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LanguageFlagButton(
                locale: AppLocale.tr,
                flagEmoji: '🇹🇷',
                isSelected: _locale == AppLocale.tr,
                onTap: () => _setLocale(AppLocale.tr),
              ),
              const SizedBox(width: 8),
              LanguageFlagButton(
                locale: AppLocale.en,
                flagEmoji: '🇬🇧',
                isSelected: _locale == AppLocale.en,
                onTap: () => _setLocale(AppLocale.en),
              ),
            ],
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _s.gameTitle.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 7,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _s.tagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _showHowToPlay();
                  },
                  icon: const Icon(
                    Icons.help_outline,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    _s.howToPlay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _s.tapToStart,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF00E5C8),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF14141F).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _s.gameOverTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_engine.score}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Color(0xFF00E5C8),
            ),
          ),
          Text(
            '${_s.bestComboLabel}: ${_engine.bestCombo}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _restartAfterGameOver,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                foregroundColor: Colors.white,
              ),
              child: Text(_s.finishButton),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isRewardLoading ? null : _continueWithRewardedAd,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00E5C8),
                foregroundColor: const Color(0xFF0A0A12),
              ),
              icon: const Icon(Icons.ondemand_video_rounded),
              label: Text(
                _isRewardLoading ? '...' : _s.watchAdContinueButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
