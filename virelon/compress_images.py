"""
Resim Sıkıştırma Scripti
PNG resimlerini optimize eder ve boyutunu küçültür.
"""

from PIL import Image
import os

# Hedef klasörler
folders = [
    r"c:\Users\muham\Desktop\flutter-u - Kopya\virelon\assets\images\Origami",
    r"c:\Users\muham\Desktop\flutter-u - Kopya\virelon\assets\images\linocutart",
    r"c:\Users\muham\Desktop\flutter-u - Kopya\virelon\assets\images\Neon Noir",
    r"c:\Users\muham\Desktop\flutter-u - Kopya\virelon\assets\images\pixelart",
    r"c:\Users\muham\Desktop\flutter-u - Kopya\virelon\assets\images\cards",
]

# Hedef boyut (genişlik)
TARGET_WIDTH = 512  # Kart boyutu için yeterli

total_before = 0
total_after = 0

for folder in folders:
    if not os.path.exists(folder):
        print(f"⚠️ Klasör bulunamadı: {folder}")
        continue
    
    print(f"\n📁 {os.path.basename(folder)} işleniyor...")
    
    for filename in os.listdir(folder):
        if not filename.lower().endswith('.png'):
            continue
        
        filepath = os.path.join(folder, filename)
        
        # Önceki boyut
        before_size = os.path.getsize(filepath)
        total_before += before_size
        
        try:
            # Resmi aç
            img = Image.open(filepath)
            
            # RGBA mı kontrol et
            if img.mode == 'RGBA':
                # Alpha kanalını koru
                pass
            else:
                img = img.convert('RGBA')
            
            # Boyutlandır (orantılı)
            width, height = img.size
            if width > TARGET_WIDTH:
                ratio = TARGET_WIDTH / width
                new_height = int(height * ratio)
                img = img.resize((TARGET_WIDTH, new_height), Image.Resampling.LANCZOS)
            
            # Kaydet (optimize)
            img.save(filepath, 'PNG', optimize=True)
            
            # Sonraki boyut
            after_size = os.path.getsize(filepath)
            total_after += after_size
            
            reduction = (1 - after_size/before_size) * 100
            print(f"  ✅ {filename}: {before_size/1024/1024:.2f}MB → {after_size/1024/1024:.2f}MB ({reduction:.1f}% azaldı)")
            
        except Exception as e:
            print(f"  ❌ {filename}: Hata - {e}")
            total_after += before_size

print(f"\n{'='*50}")
print(f"📊 TOPLAM:")
print(f"   Önce:  {total_before/1024/1024:.2f} MB")
print(f"   Sonra: {total_after/1024/1024:.2f} MB")
print(f"   Kazanç: {(total_before-total_after)/1024/1024:.2f} MB ({(1-total_after/total_before)*100:.1f}%)")
print(f"{'='*50}")
