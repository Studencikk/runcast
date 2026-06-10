import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class HourlyWeather {
  final int hour;
  final double temperature;
  final double windSpeed;
  final int precipitationProbability;

  HourlyWeather({
    required this.hour,
    required this.temperature,
    required this.windSpeed,
    required this.precipitationProbability,
  });
}

class AirQuality {
  final double pm25;
  final double pm10;

  AirQuality({required this.pm25, required this.pm10});

  String get label {
    if (pm25 <= 12) return 'Dobry';
    if (pm25 <= 35) return 'Umiarkowany';
    return 'Zły';
  }
}

class WeatherData {
  final List<HourlyWeather> hourly;
  final AirQuality airQuality;

  WeatherData({required this.hourly, required this.airQuality});

  List<HourlyWeather> getWindowHours(int startHour, int endHour) {
    return hourly
        .where((h) => h.hour >= startHour && h.hour < endHour)
        .toList();
  }

  int calculateComfort(int startHour, int endHour) {
    final hours = getWindowHours(startHour, endHour);
    if (hours.isEmpty) return 0;

    double score = 100;

    final avgTemp = hours.map((h) => h.temperature).reduce((a, b) => a + b) / hours.length;
    final avgWind = hours.map((h) => h.windSpeed).reduce((a, b) => a + b) / hours.length;
    final avgRain = hours.map((h) => h.precipitationProbability).reduce((a, b) => a + b) / hours.length;

    // Temperatura
    if (avgTemp > 28) score -= 30;
    else if (avgTemp > 22) score -= 15;
    else if (avgTemp < 0) score -= 30;
    else if (avgTemp < 5) score -= 10;

    // Wiatr
    if (avgWind >= 30) score -= 35;
    else if (avgWind >= 20) score -= 20;
    else if (avgWind >= 10) score -= 5;

    // Deszcz
    if (avgRain >= 70) score -= 30;
    else if (avgRain >= 40) score -= 15;
    else if (avgRain >= 20) score -= 5;

    // Smog
    if (airQuality.pm25 > 35) score -= 15;
    else if (airQuality.pm25 > 12) score -= 5;

    return score.clamp(0, 100).toInt();
  }

  String comfortLabel(int score) {
    if (score >= 80) return 'Idealne warunki';
    if (score >= 60) return 'Dobre warunki';
    if (score >= 40) return 'Przeciętne warunki';
    return 'Słabe warunki';
  }
}

class WeatherService {
  static const double _lat = 50.06;
  static const double _lon = 19.94;

  Future<WeatherData> fetchAll() async {
    try {
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$_lat&longitude=$_lon'
        '&hourly=temperature_2m,wind_speed_10m,precipitation_probability'
        '&forecast_days=1',
      );

      final airUrl = Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality'
        '?latitude=$_lat&longitude=$_lon'
        '&hourly=pm10,pm2_5',
      );

      final responses = await Future.wait([
        http.get(weatherUrl),
        http.get(airUrl),
      ]);

      if (responses[0].statusCode != 200 || responses[1].statusCode != 200) {
        throw Exception('Błąd pobierania danych pogodowych');
      }

      final weatherJson = jsonDecode(responses[0].body);
      final airJson = jsonDecode(responses[1].body);

      final times = weatherJson['hourly']['time'] as List;
      final temps = weatherJson['hourly']['temperature_2m'] as List;
      final winds = weatherJson['hourly']['wind_speed_10m'] as List;
      final rains = weatherJson['hourly']['precipitation_probability'] as List;

      final List<HourlyWeather> hourlyList = [];
      for (int i = 0; i < times.length; i++) {
        final timeStr = times[i] as String;
        final hour = int.parse(timeStr.substring(11, 13));
        hourlyList.add(HourlyWeather(
          hour: hour,
          temperature: (temps[i] as num).toDouble(),
          windSpeed: (winds[i] as num).toDouble(),
          precipitationProbability: (rains[i] as num).toInt(),
        ));
      }

      final pm25Values = airJson['hourly']['pm2_5'] as List;
      final pm10Values = airJson['hourly']['pm10'] as List;

      final validPm25 = pm25Values.whereType<num>().toList();
      final validPm10 = pm10Values.whereType<num>().toList();

      final avgPm25 = validPm25.isEmpty
          ? 0.0
          : validPm25.map((e) => e.toDouble()).reduce((a, b) => a + b) / validPm25.length;
      final avgPm10 = validPm10.isEmpty
          ? 0.0
          : validPm10.map((e) => e.toDouble()).reduce((a, b) => a + b) / validPm10.length;

      return WeatherData(
        hourly: hourlyList,
        airQuality: AirQuality(pm25: avgPm25, pm10: avgPm10),
      );
    } catch (e, stack) {
      await FirebaseCrashlytics.instance.recordError(e, stack);
      rethrow;
    }
  }
}
