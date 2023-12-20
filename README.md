# Byaheng San Pablo <img src="docs/logo.png" width="150">
 A mobile navigation application for tourists who want to travel San Pablo City

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Overview

"Byaheng SanPablo" is a comprehensive mobile application developed as a capstone project to enhance the tourism experience in San Pablo City, Laguna. The application focuses on providing users with invaluable information about the city's attractions, services, and real-time traffic conditions to optimize their travel experience.

## Features

### 1. Interactive Point of Interest Maps

Explore a detailed map of San Pablo City highlighting lakes, restaurants, farms, resorts, travel agencies, inns/motels, event venues, and hotels.

<img src="docs/interactive_map.png" alt="Interactive Maps" width="300">

### 2. Real-time Traffic Monitoring

Receive insights about traffic conditions and alternative routes to optimize travel within the city.

<img src="docs/traffic_monitoring.png" alt="Traffic Monitoring" width="300">

### 3. Personalized Experience

Customize your exploration by selecting specific locations or categories based on your interests.

<img src="docs/personalized_experience.png" alt="Personalized Experience" width="300">

### 4. Data Integration

Utilizes GPS, mapping APIs, and real-time data integration for traffic monitoring. Enriched with data from public traffic sources, user-generated content, and information contributed by local businesses.

<img src="docs/data_integration.png" alt="Data Integration" width="300">

## Getting Started

### Prerequisites

- Android Studio
- Dart
- Flutter
- Node.js
- npm (Node Package Manager)

### Installation

Provide step-by-step instructions on how to install and configure your project.

1. Clone the repository: `git clone https://github.com/obscuredx/ByahengSanPablo.git`
2. Navigate to the project directory: `cd ByahengSanPablo`
3. Install dependencies: `npm install`

## Usage

### Android Configuration

#### Mapbox Access Token

Mapbox APIs and vector tiles require a Mapbox account and API access token. Follow these steps to configure the Mapbox access token:

1. Add a new resource file called `mapbox_access_token.xml` at the following path: `<YOUR_FLUTTER_APP_ROOT>/android/app/src/main/res/values/mapbox_access_token.xml`.

2. Inside `mapbox_access_token.xml`, add the following content, replacing `ADD_MAPBOX_ACCESS_TOKEN_HERE` with your actual Mapbox access token. You can obtain an access token from the [Mapbox account page](https://account.mapbox.com/):

    ```xml
    <?xml version="1.0" encoding="utf-8"?>
    <resources xmlns:tools="http://schemas.android.com/tools">
        <string name="mapbox_access_token" translatable="false" tools:ignore="UnusedResources">ADD_MAPBOX_ACCESS_TOKEN_HERE</string>
    </resources>
    ```

#### App Permissions

Add the following permissions to the app-level Android Manifest (`android/app/src/main/AndroidManifest.xml`):

```xml
<manifest>
    ...
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    ...
</manifest>
```

#### MapBox Downloads Token
Add the MapBox Downloads token with the downloads:read scope to your gradle.properties file in the Android folder to enable downloading the MapBox binaries from the repository. To secure this token from getting checked into source control, you can add it to the gradle.properties of your GRADLE_HOME, which is usually at $USER_HOME/.gradle for Mac. Retrieve this token from your MapBox Dashboard. Review the Token Guide for more information about download tokens.

```
MAPBOX_DOWNLOADS_TOKEN=sk.XXXXXXXXXXXXXXX
```

After adding the above, your gradle.properties file may look something like this:

```
org.gradle.jvmargs=-Xmx1536M
android.useAndroidX=true
android.enableJetifier=true
MAPBOX_DOWNLOADS_TOKEN=sk.XXXXXXXXXXXXXXX
```

#### Update MainActivity.kt
Update MainActivity.kt to extend FlutterFragmentActivity instead of FlutterActivity. Otherwise, you may encounter the error: Caused by: java.lang.IllegalStateException: Please ensure that the hosting Context is a valid ViewModelStoreOwner.

```
// import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
}
```

#### Add Kotlin Platform Dependency
Add the following implementation platform to android/app/build.gradle:

```
implementation platform("org.jetbrains.kotlin:kotlin-bom:1.8.0")
```

These configurations ensure proper setup for Mapbox integration with your Flutter application on Android.

## Contributing

We welcome contributions, feedback, and collaboration to continuously improve and expand the functionalities of Byaheng SanPablo. Please follow the guidelines in [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under the [MIT License](LICENSE.md) - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

Give credit to any third-party libraries, tools, or resources that you used or were inspired by.
