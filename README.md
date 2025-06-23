# Flutter Weather App 🌦️

A simple and elegant weather app built with Flutter. It provides real-time weather data, hourly forecasts, and additional information for any city.

## Demo

![App Demo](demo.gif)

---

## 🚀 Features

- **Dynamic UI:** The UI provides a rich, at-a-glance view of the current weather.
- **City Search:** Search for any city in the world to get its weather forecast.
- **Hourly Forecast:** See a 5-hour forecast with temperature and weather conditions.
- **Additional Details:** Get extra info on humidity, wind speed, and precipitation.
- **Dynamic Icons:** Icons change based on the weather conditions (e.g., sunny, clouds, rain, snow).
- **Pull-to-Refresh:** Easily refresh the weather data with a simple gesture.

---

## 🛠️ Built With

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![OpenWeather](https://img.shields.io/badge/OpenWeather-EB6E4B?style=for-the-badge&logo=openweathermap&logoColor=white)

---

## ⚙️ Setup and Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/flutter-weather-app.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd flutter-weather-app
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Create your `secrets.dart` file:**
    - In the `lib` folder, create a new file named `secrets.dart`.
    - Add your OpenWeatherMap API key to it like so:
      ```dart
      // lib/secrets.dart
      const openWeatherAPIKey = "YOUR_API_KEY_HERE";
      ```
5.  **Run the app:**
    ```bash
    flutter run
    ```

---