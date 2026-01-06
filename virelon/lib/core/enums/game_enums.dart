import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Kart Tema Seçimi
enum GameCardTheme {
  classic,    // Klasik (Varsayılan)
  pixelart,   // Pixel Art
  neonnoir,   // Neon Noir
  origami,    // Origami
  linocutart, // Linocut Art
}

extension GameCardThemeX on GameCardTheme {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case GameCardTheme.classic: return l10n.themeClassic;
      case GameCardTheme.pixelart: return l10n.themePixelArt;
      case GameCardTheme.neonnoir: return l10n.themeNeonNoir;
      case GameCardTheme.origami: return l10n.themeOrigami;
      case GameCardTheme.linocutart: return l10n.themeLinocutArt;
    }
  }

  String get displayName {
    switch (this) {
      case GameCardTheme.classic: return 'Klasik';
      case GameCardTheme.pixelart: return 'Pixel Art';
      case GameCardTheme.neonnoir: return 'Neon Noir';
      case GameCardTheme.origami: return 'Origami';
      case GameCardTheme.linocutart: return 'Linocut Art';
    }
  }

  String get folderName {
    switch (this) {
      case GameCardTheme.classic: return 'cards';
      case GameCardTheme.pixelart: return 'pixelart';
      case GameCardTheme.neonnoir: return 'Neon Noir';
      case GameCardTheme.origami: return 'Origami';
      case GameCardTheme.linocutart: return 'linocutart';
    }
  }

  Color get accentColor {
    switch (this) {
      case GameCardTheme.classic: return Colors.amber;
      case GameCardTheme.pixelart: return Colors.cyan;
      case GameCardTheme.neonnoir: return Colors.pinkAccent;
      case GameCardTheme.origami: return Colors.teal;
      case GameCardTheme.linocutart: return Colors.brown;
    }
  }
  
  IconData get icon {
    switch (this) {
      case GameCardTheme.classic: return Icons.style;
      case GameCardTheme.pixelart: return Icons.grid_4x4;
      case GameCardTheme.neonnoir: return Icons.nightlight;
      case GameCardTheme.origami: return Icons.filter_vintage;
      case GameCardTheme.linocutart: return Icons.brush;
    }
  }
}

enum Character {
  duke,       // Dük
  assassin,   // Suikastçı
  countess,   // Kontes
  captain,    // Yüzbaşı
  ambassador, // Elçi
  inquisitor, // Engizisyoncu
  avukat,     // Avukat
  gazeteci    // Gazeteci
}

enum GameAction {
  income,        // Gelir (+1)
  foreignAid,    // Dış Yardım (+2) - Dük engelleyebilir
  coup,          // Darbe (-7)
  tax,           // Vergi (+3) - Dük
  assassinate,   // Suikast (-3) - Suikastçı
  steal,         // Çalma (+2) - Yüzbaşı
  exchange,      // Kart Değişimi - Elçi
  embezzle,      // Zimmete Geçirme (Treasury'den al) - Plus
  investigate,   // Sorgu - Inquisitor
  convertSelf,   // Taraf Değiştirme (Kendi) - Plus
  convertOther,  // Taraf Değiştirme (Başka) - Plus
  kayyum,        // Avukat hamlesi
  manipulate     // Gazeteci hamlesi
}

extension CharacterX on Character {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case Character.duke: return l10n.duke;
      case Character.assassin: return l10n.assassin;
      case Character.countess: return l10n.contessa;
      case Character.captain: return l10n.captain;
      case Character.ambassador: return l10n.ambassador;
      case Character.inquisitor: return l10n.inquisitor;
      case Character.avukat: return l10n.lawyer;
      case Character.gazeteci: return l10n.journalist;
    }
  }

  String get displayName {
    switch (this) {
      case Character.duke: return 'Dük';
      case Character.assassin: return 'Suikastçı';
      case Character.countess: return 'Kontes';
      case Character.captain: return 'Yüzbaşı';
      case Character.ambassador: return 'Elçi';
      case Character.inquisitor: return 'Engizisyoncu';
      case Character.avukat: return 'Avukat';
      case Character.gazeteci: return 'Gazeteci';
    }
  }

  String get assetPath => 'assets/images/cards/${this.name}.png';

  Color get color {
    switch (this) {
      case Character.duke: return Colors.purple;
      case Character.assassin: return Colors.black87;
      case Character.countess: return Colors.redAccent;
      case Character.captain: return Colors.blue;
      case Character.ambassador: return Colors.green;
      case Character.inquisitor: return Colors.orange;
      case Character.avukat: return Colors.brown;
      case Character.gazeteci: return Colors.teal;
    }
  }

  IconData get icon {
    switch (this) {
      case Character.duke: return Icons.verified_user;
      case Character.assassin: return Icons.adb;
      case Character.countess: return Icons.favorite;
      case Character.captain: return Icons.security;
      case Character.ambassador: return Icons.compare_arrows;
      case Character.inquisitor: return Icons.search;
      case Character.avukat: return Icons.balance;
      case Character.gazeteci: return Icons.newspaper;
    }
  }

  List<String> localizedAbilities(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case Character.duke:
        return [l10n.abilityDukeTax, l10n.abilityDukeBlock];
      case Character.assassin:
        return [l10n.abilityAssassinAssassinate, l10n.abilityAssassinTarget];
      case Character.countess:
        return [l10n.abilityCountessNone, l10n.abilityCountessBlock];
      case Character.captain:
        return [l10n.abilityCaptainSteal, l10n.abilityCaptainBlock];
      case Character.ambassador:
        return [l10n.abilityAmbassadorExchange, l10n.abilityAmbassadorBlock];
      case Character.inquisitor:
        return [l10n.abilityInquisitorExamine, l10n.abilityInquisitorExchange, l10n.abilityInquisitorBlock];
      case Character.avukat:
        return [l10n.abilityLawyerKayyum, l10n.abilityLawyerBlockAssas, l10n.abilityLawyerBlockPress];
      case Character.gazeteci:
        return [l10n.abilityJournalistManipulate, l10n.abilityJournalistDistribute];
    }
  }

  /// Karakterin yetenekleri (Kart altında gösterilecek)
  List<String> get abilities {
    switch (this) {
      case Character.duke:
        return ['• Vergi Al (+3)', '• Dış Yardımı Blokla'];
      case Character.assassin:
        return ['• Suikast Yap (-3)', '• Hedefi Etkisiz Hale Getir'];
      case Character.countess:
        return ['• Özel Yetenek Yok', '• Suikastı Blokla'];
      case Character.captain:
        return ['• Para Çal (+2)', '• Hırsızlığı Blokla'];
      case Character.ambassador:
        return ['• Kart Değiştir (2)', '• Hırsızlığı Blokla'];
      case Character.inquisitor:
        return ['• Sorgu Yap', '• Kart Değiştir (1)', '• Hırsızlığı Blokla'];
      case Character.avukat:
        return ['• Kayyum Al', '• Suikastı Blokla', '• Baskıyı Blokla'];
      case Character.gazeteci:
        return ['• Manipülasyon Yap', '• 3 Kart Dağıt'];
    }
  }
}

extension GameActionX on GameAction {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case GameAction.income: return l10n.income;
      case GameAction.foreignAid: return l10n.foreignAid;
      case GameAction.coup: return l10n.coup;
      case GameAction.tax: return l10n.tax;
      case GameAction.assassinate: return l10n.assassinate;
      case GameAction.steal: return l10n.steal;
      case GameAction.exchange: return l10n.exchange;
      case GameAction.investigate: return l10n.investigate;
      case GameAction.embezzle: return l10n.embezzle;
      case GameAction.convertSelf: return l10n.convert;
      case GameAction.convertOther: return l10n.distribute;
      case GameAction.kayyum: return l10n.trustee;
      case GameAction.manipulate: return l10n.manipulate;
    }
  }

  String get displayName {
    switch (this) {
      case GameAction.income: return 'Gelir';
      case GameAction.foreignAid: return 'Dış Yardım';
      case GameAction.coup: return 'Darbe';
      case GameAction.tax: return 'Vergi (Dük)';
      case GameAction.assassinate: return 'Suikast (Suikastçı)';
      case GameAction.steal: return 'Çalma (Yüzbaşı)';
      case GameAction.exchange: return 'Değişim';
      case GameAction.investigate: return 'Sorgu (Engizisyoncu)';
      case GameAction.embezzle: return 'Zimmet (Kara Para)';
      case GameAction.convertSelf: return 'Dönüşüm (Taraf Değiş)';
      case GameAction.convertOther: return 'Taraf Değiştirme';
      case GameAction.kayyum: return 'Kayyum (Avukat)';
      case GameAction.manipulate: return 'Manipüle (Gazeteci)';
    }
  }
}

enum GamePhase {
  setup,             // Oyun kurulumu (Pass & Play ekranı)
  shuffling,         // Shuffle animasyonu (Online mode)
  assigningRoles,    // Roller dağıtılıyor (Shuffle animasyon + Sırayla gösterme)
  turnTransition,    // Cihazı devretme ekranı ("Sıra Ahmet'te")
  actionDeclaration, // Oyuncu hamle seçiyor
  actionPending,     // Hamle yapıldı, diğerleri bekliyor (Blok/Meydan Okuma)
  blockingWindow,    // Biri blokladı, hamle sahibi bekliyor (Meydan Okuma)
  challengeVerification, // Kart gösterme ekranı
  victimHandover,    // Kurban kart seçecek
  resolution,        // Sonuç ekranı (kim ne kaybetti)
  exchange,          // Kart değişimi yapan oyuncu kart seçecek
  manipulation,      // Gazeteci kart dağıtımı yapacak
  investigationHandover,   // Telefonu hedefe ver (Pass & Play)
  investigationCardSelect, // Hedef kart seçecek (Engizisyoncu sorgusu)
  investigationReturn,     // Telefonu geri ver (Pass & Play)
  investigation,     // Engizisyoncu sorgu yapıyor (kartı gördü)
  kayyumBidding,     // Çoklu Kayyum - Avukatlar ilan ediliyor
  gameOver           // Oyun bitti
}

enum PlayerIdeology {
  reformist,  // Reform (mavi bayrak)
  statist     // Devlet (kırmızı bayrak)
}

extension IdeologyExtension on PlayerIdeology {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case PlayerIdeology.reformist: return l10n.ideologyReformist;
      case PlayerIdeology.statist: return l10n.ideologyStatist;
    }
  }

  String get displayName {
    switch (this) {
      case PlayerIdeology.reformist: return 'Reformist';
      case PlayerIdeology.statist: return 'Devletçi';
    }
  }
  
  Color get color {
    switch (this) {
      case PlayerIdeology.reformist: return Colors.blue; 
      case PlayerIdeology.statist: return Colors.red;
    }
  }
  
  IconData get icon {
    switch (this) {
      case PlayerIdeology.reformist: return Icons.flag;
      case PlayerIdeology.statist: return Icons.flag;
    }
  }
  
  String get assetPath {
    switch (this) {
      case PlayerIdeology.reformist: return 'assets/images/cards/reform.png';
      case PlayerIdeology.statist: return 'assets/images/cards/Devlet.png';
    }
  }
}
