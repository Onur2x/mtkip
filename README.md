# Tren Kalkış Takip (Web / Mobil PWA)

Android + iOS'ta link ile çalışan web uygulaması.

## İçerik
- `index.html` : ana uygulama (görseldeki tablo: Dinlenme | PAR | İlk Kalkış | BOS | Son Kalkış | Tur Süresi)
- `manifest.webmanifest`, `sw.js` : telefona "Ana Ekrana Ekle" ile tam ekran kurulum için

## GitHub ile yayınlama (ücretsiz link)
1. github.com'da yeni repo aç (örn `tren-takip`)
2. Bu klasördeki 3 dosyayı yükle (Add file > Upload files)
3. Settings > Pages > Branch: `main` / `/ (root)` > Save
4. 1-2 dk sonra link hazır: `https://kullaniciadi.github.io/tren-takip/`
5. Bu linki personele at. Android (Chrome) ve iPhone (Safari) ile açıp:
   - Android: ⋮ > "Ana ekrana ekle"
   - iPhone: Paylaş > "Ana Ekrana Ekle"

## Supabase kurulumu (sadece sen, bir kez)
1. supabase.com'da proje aç > SQL Editor > `supabase_schema.sql` içeriğini çalıştır (gruplar + örnek görev 6 gelir). Bunu SADECE SEN yaparsın, personel yapmaz.
2. Project Settings > API'den `URL` + `anon public` key'i al (`service_role`'u kimseyle paylaşma).
3. `supabase-config.js` dosyasını aç, URL ve anon key'i yaz, GitHub'a yükle.
4. Bitti: linki açan personel HİÇBİR AYAR GİRMEZ — sadece Görev No yazar, tablo otomatik dolar. Ayarlar'daki URL/key alanları yedek içindir.
5. Güvenlik: RLS açık, app SADECE SELECT yapar, yazma kodu yok. Veri girişi Supabase panelinden.
- Üstte Hat No (23) ve Vardiya (07:30-16:30)
- Tabloda sarı = sonraki tur, yeşil = aktif tur, soluk = geçen
- "Kalan / Toplam Tur", "Geri Sayım", "Toplam Süre / Ç.Oranı" otomatik
- Ayarlardan uyarı süresi (varsayılan 5 dk önce ses + titreşim + bildirim)
- Veri > JSON alanından yeni seferleri yapıştırıp "Veriyi Uygula"
