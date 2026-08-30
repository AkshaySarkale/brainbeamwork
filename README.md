# 🛍️ Shopora

Shopora is a Flutter-based e-commerce application developed as part of a technical assignment.

The application demonstrates a complete basic shopping flow with Firebase Authentication, Firestore, REST API integration, GetX state management, product browsing, search, filtering, sorting, wishlist, cart, checkout, orders, notifications, and profile management.

---



## 📋 Project Overview

Shopora provides a simple and user-friendly shopping experience where users can:

* Create an account and log in
* Browse products and categories
* Search for products
* Filter and sort products
* View product details
* Add products to wishlist
* Add products to cart
* Manage cart quantities
* Manage delivery addresses
* Complete the checkout flow
* Place orders
* View order history
* Receive order notifications
* Manage their profile

---

## ✨ Features

### 🔐 Authentication

* User Registration
* Email & Password Login
* Forgot Password
* Logout
* Firebase Authentication
* Persistent Authentication Session
* Form Validation
* Firebase Error Handling

### 🏠 Home

* User Greeting
* Product Categories
* Popular Products
* Product Search
* Quick Product Navigation

### 🛍️ Products

* Product Listing
* Product Details
* Category Filtering
* Search
* Price Filtering
* Rating Filtering
* Stock Filtering
* Product Sorting
* Pagination
* Loading States
* Empty States
* Error Handling

### ❤️ Wishlist

* Add Product to Wishlist
* Remove Product from Wishlist
* Wishlist Persistence
* User-specific Wishlist

### 🛒 Cart

* Add Product to Cart
* Increase Quantity
* Decrease Quantity
* Remove Product
* Cart Total Calculation
* User-specific Cart
* Cart Persistence

### 📦 Checkout

* Delivery Address Management
* Add Address
* Edit Address
* Delete Address
* Select Delivery Address
* Order Summary
* Place Order

### 📋 Orders

* Order Creation
* Order History
* Order Details
* Order Status
* Order Items
* Order Total
* Order Date

### 🔔 Notifications

* Order Notifications
* Notification List
* Read/Unread Status
* Mark as Read
* Mark All as Read
* Delete Notifications

### 👤 Profile

* View Profile
* Edit Profile
* Account Information
* Password Management
* Logout

---

## 🛠️ Tech Stack

| Technology              | Usage                                               |
| ----------------------- | --------------------------------------------------- |
| Flutter                 | Application Development                             |
| Dart                    | Programming Language                                |
| GetX                    | State Management, Navigation & Dependency Injection |
| Firebase Authentication | User Authentication                                 |
| Cloud Firestore         | User & Application Data                             |
| DummyJSON               | Product REST API                                    |
| HTTP                    | REST API Communication                              |
| Material 3              | UI Design                                           |
| Android                 | Mobile Platform                                     |
| Web                     | Web Platform                                        |

---

## 🏗️ Project Architecture

Shopora follows a simple feature-based architecture designed to keep the project easy to understand and maintain.

```text
lib/
│
├── app/
│   ├── bindings/
│   ├── routes/
│   └── theme/
│
├── core/
│   ├── constants/
│   ├── utils/
│   └── widgets/
│
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── features/
│   ├── auth/
│   ├── splash/
│   ├── home/
│   ├── product/
│   ├── category/
│   ├── cart/
│   ├── wishlist/
│   ├── checkout/
│   ├── orders/
│   ├── address/
│   ├── notification/
│   └── profile/
│
└── main.dart
```

### Data Flow

```text
UI / Views
    ↓
GetX Controllers
    ↓
Repositories
    ↓
Firebase / REST API
```

---

## 🔥 Firebase Integration

Firebase is used for authentication and user-specific application data.

### Firebase Authentication

Used for:

* Registration
* Login
* Logout
* Password Reset
* Session Management

### Cloud Firestore

Used for:

* User Profiles
* Addresses
* Cart
* Wishlist
* Orders
* Notifications

User-specific data is associated with the authenticated Firebase UID.

---

## 🌐 REST API

Shopora uses **DummyJSON** as the product data source.

The REST API is used for:

* Product Listing
* Product Details
* Categories
* Product Search
* Pagination

The API response is converted into Dart models before being used by the application.

```text
DummyJSON API
      ↓
Repository
      ↓
Product Model
      ↓
GetX Controller
      ↓
UI
```

---

## 🔄 Application Flow

### Authentication Flow

```text
Splash
   │
   ├── User Logged In
   │       ↓
   │      Home
   │
   └── User Not Logged In
           ↓
         Login
           ↓
        Register
```

### Shopping Flow

```text
Home
 ↓
Products
 ↓
Search / Filter / Sort
 ↓
Product Details
 ↓
Add to Wishlist / Cart
 ↓
Cart
 ↓
Checkout
 ↓
Select Address
 ↓
Place Order
 ↓
Order Created
 ↓
Notification
 ↓
Order History
```

---

## 📸 App Demo

<p align="center">
  <img src="assets/demo.mp4" alt="App Demo Video" width="300" />
</p>

---

### Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Git
* Firebase Project

Check Flutter installation:

```bash
flutter doctor
```

---

### 1. Clone the Repository

```bash
git clone https://github.com/AkshaySarkale/brainbeamwork.git
```

Navigate to the project:

```bash
cd shopora
```

---

### 2. Install Dependencies

```bash
flutter pub get
```

---

### 3. Firebase Configuration

Configure the project with your Firebase project.

Required Firebase services:

* Firebase Authentication
* Cloud Firestore

Make sure the required Firebase configuration files are available for the target platform.

---

### 4. Run the Application

```bash
flutter run
```

---

## 🧪 Development & Testing

Format the project:

```bash
dart format lib
```

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

---

## 📦 Build

### Android Debug APK

```bash
flutter build apk --debug
```

### Android Release APK

```bash
flutter build apk --release
```

### Web

```bash
flutter build web
```

---

## 🔒 Data & Security

Firebase Authentication is used to manage authenticated users.

Firestore user-related data is associated with the authenticated user's UID.

The application is designed so that user-specific information such as:

* Cart
* Wishlist
* Addresses
* Orders
* Notifications
* Profile

is associated with the respective authenticated user.

Sensitive credentials should not be committed to the repository.

---

## 📁 Main Modules

| Module         | Responsibility                                                    |
| -------------- | ----------------------------------------------------------------- |
| Authentication | Login, registration, password reset and logout                    |
| Home           | Dashboard and product discovery                                   |
| Products       | Product listing, details, search, filters, sorting and pagination |
| Categories     | Category browsing and filtering                                   |
| Wishlist       | Wishlist management                                               |
| Cart           | Cart items and quantity management                                |
| Address        | Delivery address management                                       |
| Checkout       | Order summary and order placement                                 |
| Orders         | Order history and details                                         |
| Notifications  | Order-related notifications                                       |
| Profile        | User profile and account management                               |

---

## 🎨 UI & UX

The application uses **Material 3** components and follows a consistent design throughout the application.

The UI includes:

* Responsive layouts
* Reusable widgets
* Loading indicators
* Empty states
* Error states
* Form validation
* User-friendly feedback
* Consistent spacing and typography

The application supports both **Android and Web**.

---

## 📌 Project Status

**Status: Completed**

The current implementation includes the complete basic e-commerce shopping flow from authentication and product browsing to cart, checkout, order management, and notifications.

---

## 👨‍💻 Developer

**Akshay**

Flutter Developer

Built using:

```text
Flutter • Dart • GetX • Firebase • Firestore • REST API
```

---

## 📄 License

This project was developed as part of a **technical assignment** and is intended for demonstration and evaluation purposes.
