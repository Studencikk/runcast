# RunCast

Aplikacja mobilna do planowania treningów biegowych na podstawie aktualnej prognozy pogody.

## Opis

RunCast pobiera dane pogodowe i jakości powietrza dla Krakowa i na ich podstawie ocenia komfort treningu w trzech porach dnia: rano, popołudniu i wieczorem. Aplikacja pozwala też dopasować trasę biegową do warunków atmosferycznych oraz zapisać profil biegacza z tygodniowym celem kilometrowym.

## Funkcje

- **Ekran główny** – trzy okna treningowe (Rano / Popołudnie / Wieczór) z procentową oceną komfortu
- **Szczegóły** – godzinowa prognoza temperatury, wiatru i opadów, poziom smogu PM2.5/PM10, porada dotycząca ubioru
- **Trasy** – lista tras z tagami offline, Smart Matcher dopasowujący trasę do warunków, możliwość dodania nowej trasy
- **Profil** – imię, poziom zaawansowania, tygodniowy cel kilometrów zapisywany lokalnie w Hive

## Technologie

- **Flutter** – framework UI
- **http** – zapytania REST do Open-Meteo API
- **Hive CE** – lokalna baza danych (trasy, profil użytkownika)
- **Firebase Analytics** – śledzenie eventów (`manual_refresh`, `route_selected`, `save_profile`)
- **Firebase Crashlytics** – zbieranie błędów i crashy

## API

- **Pogoda:** `https://api.open-meteo.com/v1/forecast` – temperatura, wiatr, opady (24h)
- **Smog:** `https://air-quality-api.open-meteo.com/v1/air-quality` – PM2.5, PM10 (24h)

## Uruchomienie

1. Sklonuj repozytorium
2. Zainstaluj zależności:
   ```bash
   flutter pub get
   ```
3. Uruchom aplikację:
   ```bash
   flutter run
   ```
