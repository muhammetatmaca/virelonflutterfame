import 'package:flutter/material.dart';

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
        return ['• Kart Değiştir (1)', '• Sorgu Yap', '• Hırsızlığı Blokla'];
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
  String get displayName {
    switch (this) {
      case GameAction.income: return 'Gelir';
      case GameAction.foreignAid: return 'Dış Yardım';
      case GameAction.coup: return 'Darbe';
      case GameAction.tax: return 'Vergi (Dük)';
      case GameAction.assassinate: return 'Suikast (Suikastçı)';
      case GameAction.steal: return 'Çalma (Yüzbaşı)';
      case GameAction.exchange: return 'Değişim (Elçi)';
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
  investigation,     // Engizisyoncu sorgu yapıyor
  kayyumBidding,     // Çoklu Kayyum - Avukatlar ilan ediliyor
  gameOver           // Oyun bitti
}

enum PlayerIdeology {
  reformist,  // Reform (mavi bayrak)
  statist     // Devlet (kırmızı bayrak)
}

extension IdeologyExtension on PlayerIdeology {
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
