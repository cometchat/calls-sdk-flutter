
<p align="center">
  <img alt="CometChat" src="https://assets.cometchat.io/website/images/logos/banner.png">
</p>

# Flutter Calls Sample App by CometChat

This is a reference application showcasing the integration of [CometChat's Flutter Calls SDK](https://www.cometchat.com/docs/calls/flutter/overview) in a Flutter project. It demonstrates how to implement real-time voice and video calling features with ease.

<p align="center">
  <img src="../../screenshots/showcase-mobile.png" alt="Mobile Showcase">
</p>


## Prerequisites

Sign up for a [CometChat](https://app.cometchat.com/) account to obtain your app credentials: _`App ID`_, _`Region`_, and _`Auth Key`_

- **Flutter SDK** 3.10.0 or higher
- **Dart SDK** 3.0.0 or higher

**Android**
- Android Studio (latest stable version)
- Android device or emulator with API level 26+

**iOS**
- Xcode (latest stable version)
- CocoaPods
- An iOS device or simulator with iOS 15.1 or above


## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/cometchat/calls-sdk-flutter.git
   ```

1. Change into the sample app's directory:
   ```sh
   cd sample-apps/cometchat-calls-sample-app-flutter
   ```

1. Install dependencies:
   ```sh
   flutter pub get
   ```

1. For iOS, install CocoaPods dependencies:
   ```sh
   cd ios
   pod install
   cd ..
   ```

1. `[Optional]` Configure CometChat credentials:
    - Open the `app_constants.dart` file located at `lib/app_constants.dart` and enter your CometChat _`appId`_, _`region`_, and _`authKey`_:
      ```dart
      class AppConstants {
        static const String appId = 'YOUR_APP_ID';
        static const String region = 'YOUR_REGION'; // us, eu, or in
        static const String authKey = 'YOUR_AUTH_KEY';
      }
      ```
    - Alternatively, you can enter your credentials on first launch via the in-app credentials screen.

1. Run the app on a device or emulator:
   ```sh
   flutter run
   ```


## Help and Support

For issues running the project or integrating with our Calls SDK, consult our [documentation](https://www.cometchat.com/docs/calls/flutter/overview) or create a [support ticket](https://help.cometchat.com/hc/en-us). You can also access real-time support via the [CometChat Dashboard](http://app.cometchat.com/).
