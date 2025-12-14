# VIRELON - Karakter ve Hamle Rehberi

Bu dosya, oyundaki karakterlerin orijinal Coup rehberiyle eşleşmesini gösterir.

## 📋 KARAKTER EŞLEŞTİRMELERİ

| Virelon (Kod) | Türkçe İsim | Rehberdeki İsim | Hamle/Özellik | Mod |
|---------------|-------------|-----------------|---------------|-----|
| `duke` | Dük | **İş Adamı (Holding)** | Vergi: Kasadan 3 altın al | Normal |
| `assassin` | Suikastçı | **Subay** | Baskı: 3 altın öde, birini öldür | Normal |
| `countess` | Kontes | **Aktivist** | Baskıyı engelle (Suikastı blokla) | Normal |
| `captain` | Yüzbaşı | **Bürokrat (Yakışıklı)** | Bir oyuncudan 2 altın çal | Normal |
| `ambassador` | Elçi | **Politikacı (Dükral)** | Kart değişimi (Çöp Sağlama) | Normal |
| `inquisitor` | Engizisyoncu | **Engizisyoncu** | Sorgu: Rakibin kartını gör | Normal |
| `avukat` | Avukat | **Avukat** | Kayyum: Ölen oyuncunun parasını al | PLUS |
| `gazeteci` | Gazeteci | **Gazeteci** | Manipülasyon: Kart dağıtımı | PLUS |

## 🎮 TEMEL HAMLELER (Tüm Oyuncular)

| Virelon (Kod) | Türkçe İsim | Rehberdeki İsim | Açıklama |
|---------------|-------------|-----------------|----------|
| `income` | Gelir | **Vergi Destek** | +1 altın al |
| `foreignAid` | Dış Yardım | **Uluslararası Destek** | +2 altın al (Duke bloklar) |
| `coup` | Darbe | **Entrika** | 7 altın öde, birini öldür (bloklanamaz) |

## 🌟 PLUS MOD ÖZEL HAMLELER

| Virelon (Kod) | Türkçe İsim | Rehberdeki İsim | Açıklama |
|---------------|-------------|-----------------|----------|
| `convertSelf` | Dönüşüm (Kendi) | **Dönüşüm** | 1 altın öde, kendi ideolojini değiştir |
| `convertOther` | Baskı (Başkası) | **Baskı** | 2 altın öde, başkasının ideolojisini değiştir |
| `embezzle` | Zimmet | **Kara Para** | İş adamı olmadığını iddia et, havuzdan al |
| `investigate` | Sorgu | **Sorgu** | Engizisyoncu: Rakibin kartını gör |
| `kayyum` | Kayyum | **Kayyum** | Avukat: Ölen oyuncunun parasını al |
| `manipulate` | Manipülasyon | **Manipülasyon** | Gazeteci: Kart dağıtımı yap |

## 🛡️ BLOKLAMA KURALLARI

| Hamle | Bloklanabilir mi? | Kim Bloklar? | Rehberdeki Karşılık |
|-------|-------------------|--------------|---------------------|
| Foreign Aid (Dış Yardım) | ✅ Evet | Duke (Dük) | İş Adamı |
| Steal (Çalma) | ✅ Evet | Captain, Ambassador, Inquisitor | Bürokrat, Politikacı, Engizisyoncu |
| Assassinate (Suikast) | ✅ Evet | Countess, Avukat | Aktivist, Avukat |
| Manipulate (Manipülasyon) | ✅ Evet | Gazeteci | Gazeteci |
| Tax (Vergi) | ❌ Hayır | - | - |
| Exchange (Değişim) | ❌ Hayır | - | - |
| Coup (Darbe) | ❌ Hayır | - | - |

## ⚠️ MEYDAN OKUMA KURALLARI

1. **Herhangi bir karakter iddiası** meydan okunabilir
2. **Meydan okuma kazanırsa**: İddia eden bir kart kaybeder
3. **Meydan okuma kaybederse**: Meydan okuyan bir kart kaybeder
4. **Kart gösterme**: Doğru kart gösterilirse, deste karıştırılır ve yeni kart çekilir

## 🎯 İDEOLOJİ SİSTEMİ (PLUS MOD)

- **Reformist** (Mavi Bayrak): `reform.png`
- **Statist** (Kırmızı Bayrak): `Devlet.png`

**Kural**: Aynı ideolojiye sahip oyuncular birbirlerine "kırmızı hamleler" yapamaz.

## 📝 NOTLAR

- **Subay karakteri**: Rehberde var, kodda yok (Assassin ile aynı)
- **Normal Mod**: 6 temel karakter (Duke, Assassin, Countess, Captain, Ambassador, Inquisitor)
- **PLUS Mod**: +2 karakter (Avukat, Gazeteci) + İdeoloji sistemi + Özel hamleler
- **Para Havuzu**: PLUS modda "Kara Para" için kullanılır
- **Treasury**: Oyun içi ortak para havuzu

---

**Son Güncelleme**: 13 Aralık 2024
**Versiyon**: 1.0
