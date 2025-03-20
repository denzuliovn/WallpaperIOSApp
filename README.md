# 📱 iOS Application

## 📌 Project Overview
This is an iOS application built with:
- **Language**: Swift
- **UI Framework**: Storyboard
- **Networking**: Alamofire
- **API**: Pixabay API

## 🚀 Getting Started
Follow these steps to set up and run the project.

### 🔧 Prerequisites
Ensure you have the following installed:
- [Xcode](https://developer.apple.com/xcode/)
- CocoaPods (for managing dependencies)

---

## 🛠️ Setup & Installation

### 1️⃣ Clone the Repository
```sh
git clone https://github.com/your-repository.git
cd your-project-folder
```

### 2️⃣ Install Dependencies
```sh
pod install
```
Make sure to always open the `.xcworkspace` file instead of `.xcodeproj`.

### 3️⃣ Configure API Key
Sign up at [Pixabay](https://pixabay.com/api/docs/) to get an API key and add it to your project:
1. Open `Info.plist`.
2. Add a new key: `PixabayAPIKey` with your API key as the value.

### 4️⃣ Run the App
Open Xcode and select your target device, then run:
```sh
Cmd + R
```

---

## 📜 Features
- Fetch and display images from Pixabay API.
- Search functionality for images.
- Smooth networking with Alamofire.
- User-friendly UI built with Storyboard.

---

## 🛠️ Dependencies
The project uses the following dependencies:
- [Alamofire](https://github.com/Alamofire/Alamofire) - for network requests
- [Kingfisher](https://github.com/onevcat/Kingfisher) (optional) - for image caching

To install dependencies, use:
```sh
pod install
```

---

## 📝 Notes
- Ensure you have an active internet connection.
- Check your API key if images are not loading.

---

## 📌 Author
Developed by **Denzulio Tran**

