# Shopora

A feature-rich, beautiful, and highly responsive E-Commerce application built with Flutter, Firebase, and GetX. Shopora provides a seamless shopping experience with real-time cart synchronization, secure authentication, and a dynamic product catalog.

## ✨ Features

*   **Robust Authentication**: Secure email/password login and registration powered by Firebase Auth.
*   **Dynamic Product Catalog**: Browse, search, and filter products fetched from a remote REST API. Includes advanced filtering (by category, price, rating) and sorting capabilities.
*   **Real-time Cart & Wishlist**: Add products to your cart or wishlist. State is managed seamlessly using GetX and synchronized with Cloud Firestore.
*   **Checkout & Address Management**: Full checkout flow including multiple delivery addresses, promo codes, and a simulated payment gateway.
*   **Profile & Notifications**: Manage user profile details, change passwords, and receive in-app notifications for order updates.
*   **Responsive UI/UX**: Built with a custom, scalable design system featuring rich micro-animations, clean typography, and a modern aesthetic.

## 🏗️ Architecture & Tech Stack

This project follows a strict **Feature-First Architecture** combined with the **Repository Pattern** to ensure high scalability and maintainability.

*   **Framework**: [Flutter](https://flutter.dev/)
*   **State Management & Routing**: [GetX](https://pub.dev/packages/get)
*   **Backend & Database**: [Firebase](https://firebase.google.com/) (Auth & Cloud Firestore)
*   **Networking**: `http` package (fetching products from DummyJSON API)
*   **Architecture Pattern**: MVC + Repository (Feature-based folder structure)

### Folder Structure

```
lib/
│
├── app/                  # App-wide configurations
│   ├── bindings/         # Global dependency injections
│   ├── routes/           # Named route definitions and pages
│   └── theme/            # Centralized colors, typography, and theme
│
├── core/                 # Shared resources across features
│   ├── constants/        # API endpoints, assets, strings
│   ├── utils/            # Helper functions (e.g., Snackbars, formatters)
│   └── widgets/          # Reusable UI components (Buttons, TextFields, Shimmers)
│
├── data/                 # Data layer
│   ├── models/           # Data models with fromJson/toJson methods
│   └── repositories/     # Abstracts data sources (Firebase, REST APIs)
│
└── features/             # Feature modules (The core of the app)
    ├── address/          # Address management views & controllers
    ├── auth/             # Login, Register, Forgot Password
    ├── cart/             # Cart management
    ├── checkout/         # Order placement and payment selection
    ├── home/             # Main landing dashboard
    ├── order/            # Order history and success screens
    ├── product/          # Product listing, filtering, and details
    └── profile/          # User profile and settings
```

## 🚀 Getting Started

### Prerequisites

*   Flutter SDK (stable channel)
*   Dart SDK
*   A Firebase Project

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/shopora.git
    cd shopora
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**
    *   Create a project in the [Firebase Console](https://console.firebase.google.com/).
    *   Enable **Authentication** (Email/Password).
    *   Enable **Cloud Firestore** and update your security rules.
    *   Connect your Flutter app to Firebase using the FlutterFire CLI or by manually adding `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).

4.  **Run the App**
    ```bash
    flutter run
    ```

## 🛡️ Best Practices Implemented

*   **Absolute Package Imports**: Clean and unambiguous imports using `package:shopora/...`.
*   **Lazy Dependency Injection**: GetX `Bindings` are used to load controllers into memory only when their respective views are pushed to the navigation stack.
*   **Optimistic UI Updates**: Instant UI feedback on actions (like adding to cart) before server confirmation, ensuring a snappy user experience.
*   **Memory Management**: Proper disposal of `TextEditingControllers` and `ScrollControllers` to prevent memory leaks.
*   **Strict Form Validation**: Real-time Regex and format validations on sensitive inputs (Names, Phones, Postal Codes).

## 📝 License

This project is licensed under the MIT License.
