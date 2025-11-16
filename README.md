# 🛒 ShelfMate (Android Application)

**ShelfMate** is a modern Android application built with **Flutter (Dart)** and powered by **Firebase**.  
It provides business managers with a secure, seamless, and efficient way to manage inventory directly from their mobile devices.  

With real-time product tracking, CRUD operations, and a responsive mobile-first UI, ShelfMate transforms inventory management into a transparent and accessible process on Android.

---

## ✨ Features

- **Full CRUD Operations**: Add, view, update, and delete products with details like SKU, quantity, and description.  
- **Real-Time Inventory Tracking**: Instant updates on stock levels using Firebase’s real-time database.  
- **Secure Authentication**: Firebase Authentication for login, registration, and role-based access.  
- **Mobile-First UI**: Built with Flutter for a native-like Android experience.  
- **Global State Management**: Efficient handling of product lists using Flutter’s `Provider` or `Riverpod`.  
- **Cross-Platform Ready**: Though focused on Android, the app can be extended to iOS and web with Flutter.  

---

## 🛠️ Tech Stack

| Category   | Technology          | Purpose                                                                 |
|------------|---------------------|-------------------------------------------------------------------------|
| **Frontend (Android)** | Dart + Flutter       | Cross-platform mobile UI for Android                                   |
| **Frontend (Android)** | Provider / Riverpod  | State management for authentication and product data                   |
| **Frontend (Android)** | Material Design      | Modern, responsive UI components                                       |
| **Backend**  | Firebase Authentication | Secure user login and role-based access                                |
| **Backend**  | Firebase Firestore / Realtime DB | Cloud database for storing product and inventory data                  |
| **Backend**  | Firebase Cloud Functions | Serverless functions for business logic and automation                 |
| **Backend**  | Firebase Hosting / Storage | Hosting assets and storing product images                              |

---

## 🔑 Architecture

- **Frontend (Android)**: Flutter app with reusable widgets, responsive layouts, and state management.  
- **Backend (Firebase)**: Authentication, Firestore/Realtime DB, and Cloud Functions for business logic.  
- **Data Flow**: Secure API calls and direct Firebase SDK integration for real-time updates.  

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)  
- Android Studio or VS Code with Flutter/Dart plugins  
- Firebase project set up in [Firebase Console](https://console.firebase.google.com/)  

---

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/shelfmate.git
cd shelfmate
```

---

### 2. Flutter Setup
```bash
flutter pub get
```

---

### 3. Firebase Setup
- Create a Firebase project in the Firebase Console.  
- Enable **Authentication** (Email/Password or Google Sign-In).  
- Enable **Firestore** or **Realtime Database**.  
- Download the `google-services.json` file and place it in your Flutter project under `/android/app/`.  

---

### 4. Run the App
```bash
flutter run
```

Runs on emulator or physical Android device.

---

## 🏃 Running the Application

- **Frontend (Android)**: Runs on emulator or physical Android device.  
- **Backend (Firebase)**: Hosted in the cloud, no local server setup required.  

---

## 🤝 Contributing

1. Fork the Project  
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)  
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)  
4. Push to the Branch (`git push origin feature/AmazingFeature`)  
5. Open a Pull Request  

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for more information.
