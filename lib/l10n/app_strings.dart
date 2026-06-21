import 'app_locale.dart';

class AppStrings {
  const AppStrings(this.locale);

  final AppLocale locale;

  String _t(String tr, String en) => locale == AppLocale.tr ? tr : en;

  String get gameTitle => 'Ripple Rush';

  String get tagline => _t(
        'Dalgalara tam vuruş yap, combo kur',
        'Hit the ripple, build your combo',
      );

  String get howToPlay => _t('Nasıl oynanır?', 'How to play?');

  String get tapToStart => _t('Başlamak için dokun', 'Tap to start');

  String get record => _t('Rekor', 'Best');

  String get today => _t('Bugün', 'Today');

  String get combo => 'Combo';

  String comboCount(int n) => '$combo x$n';

  String get gameOverTitle => _t('Ripple Rush Durdu', 'Ripple Rush Stopped');

  String get bestComboLabel => _t('En iyi combo', 'Best combo');

  String get tapToReplay => _t('Tekrar oynamak için dokun', 'Tap to play again');
  String get finishButton => _t('Bitir', 'Finish');
  String get watchAdContinueButton => _t('Izle (+2 Can)', 'Watch (+2 Lives)');
  String get rewardAdNotReady => _t(
        'Reklam henuz hazir degil, lutfen biraz sonra tekrar deneyin.',
        'Reward ad is not ready yet, please try again shortly.',
      );
  String get startupAdInfo => _t(
        'Acilis reklami yukleniyor...',
        'Loading startup ad...',
      );

  String perfectHit(int combo) =>
      _t('MÜKEMMEL x$combo', 'PERFECT x$combo');

  String goodHit(int combo) => _t('İYİ x$combo', 'GOOD x$combo');

  String get missed => _t('KAÇTI', 'MISSED');

  String get trapHit => _t('TUZAK! Combo gitti', 'TRAP! Combo lost');

  String get gotIt => _t('Anladım', 'Got it');

  // Nasıl oynanır
  String get howPurpleTitle => _t('Mor halka', 'Purple ring');

  String get howPurpleBody => _t(
        'Merkezden dışa genişler. Turkuaz hedef çizgiye denk gelince dokun.',
        'Expands outward. Tap when it aligns with the teal target ring.',
      );

  String get howPerfectTitle => _t('Mükemmel & İyi', 'Perfect & Good');

  String get howPerfectBody => _t(
        'Tam denk = yüksek skor. Combo arttıkça puan çarpanı artar.',
        'Perfect timing = high score. Combo raises your point multiplier.',
      );

  String get howTrapTitle => _t('Pembe halka (tuzak)', 'Pink ring (trap)');

  String get howTrapBody => _t(
        'Dokunma, geçmesine izin ver. Dokunursan can gider ve combo sıfırlanır.',
        "Don't tap — let it pass. If you tap, you lose a life and your combo resets.",
      );

  String get howMissTitle => _t('Kaçırdın', 'Missed');

  String get howMissBody => _t(
        'Mor halkayı zamanında vuramazsan can gider, combo sıfırlanır.',
        'Fail to hit the purple ring in time and you lose a life and your combo.',
      );

  String get howLivesTitle => _t('Can & combo', 'Lives & combo');

  String get howLivesBody => _t(
        '3 canın var. Her 10 combo = +1 can (en fazla 3).',
        'You have 3 lives. Every 10 combo = +1 life (max 3).',
      );

  String recordTodayLine(int best, int todayScore) =>
      '$record: $best · $today: $todayScore';
}
