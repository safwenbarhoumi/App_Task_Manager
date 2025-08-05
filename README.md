# Task Manager Application

A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:
```bash
flutter run
```

## 📁 Project Structure

```
flutter_app/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities and services
│   │   └── utils/      # Utility classes
│   ├── presentation/   # UI screens and widgets
│   │   └── splash_screen/ # Splash screen implementation
│   ├── routes/         # Application routing
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, fonts, etc.)
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```
## 📦 Deployment

Build the application for production:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

## 🐳 Docker & Docker Compose

This project supports containerization and web deployment using Docker and Docker Compose. You can build and run your Flutter web application in a container for easy testing, development, and deployment.

### 📋 Docker Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (Engine and CLI)
- [Docker Compose](https://docs.docker.com/compose/install/) (v1.27+ recommended)
- (Optional) Familiarity with [Flutter Web](https://docs.flutter.dev/platform-integration/web)

### 🛠️ Docker Installation

1. **Install Docker**  
   Follow the official [Docker installation guide](https://docs.docker.com/get-docker/) for your platform.

2. **Install Docker Compose**  
   Refer to the [Docker Compose installation guide](https://docs.docker.com/compose/install/).

3. **Verify Installation**  
   ```bash
   docker --version
   docker-compose --version
   ```

### 📦 Docker Build

Build the Docker image for your Flutter web app using the provided `Dockerfile`:

```bash
docker build -t flutter_web_app .
```

### 🚀 Docker Run

Run the container and expose the web server:

```bash
docker run -p 9000:9000 flutter_web_app
```

Access your Flutter web app at [http://localhost:9000](http://localhost:9000).

### ⚙️ Docker Compose Usage

For multi-service setups or easier development, use the included `docker-compose.yml`:

1. **Build & Run with Compose**
   ```bash
   docker-compose up --build
   ```
   This command builds the image and starts the container. Your app will be available at [http://localhost:9000](http://localhost:9000).

2. **Stopping Containers**
   ```bash
   docker-compose down
   ```

### 🛠️ Docker Compose Configuration

The `docker-compose.yml` contains:

```yaml
version: "3.8"
services:
  flutter_web:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "9000:9000"
    volumes:
      - .:/app
    environment:
      - PUB_HOSTED_URL=https://pub.flutter-io.cn
      - FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
    restart: unless-stopped
```

- **build**: Builds your app using the Dockerfile.
- **ports**: Maps port 9000 (container) to 9000 (host).
- **volumes**: Mounts your app directory for live development (optional; remove for production).
- **environment**: Sets Flutter-specific environment variables, helpful for China mirrors.

### 📁 Project Structure (Docker Context)

Ensure your project files (including Dockerfile and server script) are at the root level for Docker to build correctly:

```
flutter_app/
├── Dockerfile
├── docker-compose.yml
├── server/
│   └── server.sh
├── lib/
├── assets/
└── ...
```

### 🚦 Troubleshooting

- Make sure your server script (`server/server.sh`) is executable and serves the `build/web` directory.
- If you change source code and use volumes, rebuild with `docker-compose up --build`.
- Check logs with `docker logs <container_id>` for debugging.

---

