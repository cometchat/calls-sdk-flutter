<p align="center">
  <img alt="CometChat" src="https://assets.cometchat.io/website/images/logos/banner.png">
</p>

# CometChat Flutter Calls SDK

The CometChat Calls SDK enables real-time voice and video calling capabilities in your Flutter application. Built on top of WebRTC, it provides a complete calling solution with built-in UI components and extensive customization options.

<p align="center">
  <img src="./screenshots/showcase-mobile.png" alt="Mobile Showcase">
</p>

---

## Getting Started

To set up the CometChat Calls SDK and utilize CometChat for your calling functionality, you'll need to follow these steps:

1. Registration: Go to the [CometChat Dashboard](https://app.cometchat.com/) and sign up for an account.
2. After registering, log into your CometChat account and create a new app. Once created, CometChat will generate an Auth Key and App ID for you. Keep these credentials secure as you'll need them later.
3. Check the [Key Concepts](https://www.cometchat.com/docs/fundamentals/key-concepts) to understand the basic components of CometChat.

## 📦 Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  cometchat_calls_sdk: ^5.0.4
```

### Requirements

| Platform | Minimum |
|----------|---------|
| iOS      | 15.1    |
| Android  | API 26 (Android 8.0) |

> **iOS 15.1 is required from 5.0.4 onward** (previously 13.0). The underlying
> native Calls SDK ships an XCFramework that requires 15.1, so a lower
> deployment target in your `Podfile` will resolve but then fail to build.

For the full setup guide, refer to our [official documentation](https://www.cometchat.com/docs/calls/flutter/overview).

## 🚀 Explore the Sample App

Dive straight into our sample app to see the CometChat Calls SDK in action.

- [Flutter Sample App](sample-apps/cometchat-calls-sample-app-flutter#readme)

---

## Help and Support

For issues running the project or integrating with our UI Kits, consult our [documentation](https://www.cometchat.com/docs) or create a [support ticket](https://help.cometchat.com/hc/en-us) or seek real-time support via the [CometChat Dashboard](https://app.cometchat.com/).
