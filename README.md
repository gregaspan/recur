# 🌟 Recur

Welcome to the **Recur**! This Flutter application, powered by Firebase, helps users build and maintain habits by tracking daily progress, visualizing performance over time, and integrating with their calendars for enhanced planning. 🚀
![recur](https://github.com/user-attachments/assets/75630c8f-190a-4226-9806-b0760b20d9ce)

---

## 📚 Table of Contents

1. [Features](#features)  
2. [Getting Started](#getting-started)  
   - [Prerequisites](#prerequisites)  
   - [Installation](#installation)  
3. [Screens and UI](#screens-and-ui)  
4. [Database Schema](#database-schema)  
5. [Key Functionalities](#key-functionalities)  
6. [License](#license)  

---

## 🌟 Features

- **User Authentication**: Secure login and signup with Firebase Authentication. 🔒  
- **Daily Habit Tracking**: View, update, and monitor your habits daily. 📅  
- **Progress Visualization**: Analyze your performance with weekly overviews and calendar tracking. 📊  
- **Gamification**: Join challenges and stay motivated! 🏆  
- **Google Calendar Integration**: Sync habits via an `.ics` calendar subscription. 📤  

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed ([installation guide](https://docs.flutter.dev/get-started/install)).  
- Firebase account set up ([Firebase Console](https://console.firebase.google.com/)).  
- A working Google Calendar `.ics` link configuration for integration.

### Installation

1. Clone the repository:  
   ```bash
   git clone https://github.com/gregaspan/recur.git
   ```

2. Install dependencies:  
   ```bash
   flutter pub get
   ```

3. Set up Firebase:  
   - Add the `google-services.json` file (for Android) or `GoogleService-Info.plist` (for iOS) to your project.  

4. Run the app:  
   ```bash
   flutter run
   ```

---

## 🖼 Screens and UI

| Screen                      | Description                                                                                   |
|-----------------------------|-----------------------------------------------------------------------------------------------|
| **Login Screen**            | Secure login and signup options for users.                                                   |
| **Your Habits for Today**   | View and update habits for the current day, grouped by status (Ongoing, Completed, Failed).   |
| **Habit Detail Screen**     | Dive into specific habits, view logs, and update progress.                                    |
| **Add New Habit**           | Easily create new habits with custom frequency, reminders, and types.                        |
| **Dashboard**               | Get an overview of your habit progress and motivational stats.                               |
| **Weekly Progress Overview**| Visualize your weekly habit completion rates and trends.                                      |
| **Calendar View**           | Track long-term trends and daily habit statuses.                                             |
| **Settings**                | Manage account details, sync via `.ics` calendar links, and customize the app.               |
| **Challenges**              | Join fun challenges to stay motivated and build consistency.                                 |


![Simulator Screenshot - iPhone 15 Pro - 2025-01-20 at 14.00.19.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/a9f7a5f1-3709-4ef3-824d-ea000f2d11f4/74eb853c-1d52-44b8-a986-a56cfc74e126/Simulator_Screenshot_-_iPhone_15_Pro_-_2025-01-20_at_14.00.19.png)

![Simulator Screenshot - iPhone 15 Pro - 2025-01-20 at 14.01.50.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/a9f7a5f1-3709-4ef3-824d-ea000f2d11f4/c940e296-286f-4f55-a26c-6581c3f2b100/Simulator_Screenshot_-_iPhone_15_Pro_-_2025-01-20_at_14.01.50.png)

![Simulator Screenshot - iPhone 15 Pro - 2025-01-20 at 14.05.25.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/a9f7a5f1-3709-4ef3-824d-ea000f2d11f4/f924568d-d1ba-437c-bd73-7700558446ba/Simulator_Screenshot_-_iPhone_15_Pro_-_2025-01-20_at_14.05.25.png)

![Simulator Screenshot - iPhone 15 Pro - 2025-01-20 at 14.06.34.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/a9f7a5f1-3709-4ef3-824d-ea000f2d11f4/7b70777d-a209-4918-853b-ce0b4cbc5cd5/Simulator_Screenshot_-_iPhone_15_Pro_-_2025-01-20_at_14.06.34.png)

![Simulator Screenshot - iPhone 15 Pro - 2025-01-20 at 14.07.02.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/a9f7a5f1-3709-4ef3-824d-ea000f2d11f4/f346c66e-ee15-4752-9e9f-e6ef9ee1ee69/Simulator_Screenshot_-_iPhone_15_Pro_-_2025-01-20_at_14.07.02.png)

![Simulator Screenshot - iPhone 15 Pro - 2025-01-20 at 14.07.06.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/a9f7a5f1-3709-4ef3-824d-ea000f2d11f4/58c71e2f-183b-41d8-b2f5-0fce3ee3fd47/Simulator_Screenshot_-_iPhone_15_Pro_-_2025-01-20_at_14.07.06.png)

![Simulator Screenshot - iPhone 15 Pro - 2025-01-20 at 14.07.31.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/a9f7a5f1-3709-4ef3-824d-ea000f2d11f4/32db04b8-2364-4c82-bafd-74c0e5b8c223/Simulator_Screenshot_-_iPhone_15_Pro_-_2025-01-20_at_14.07.31.png)

![Simulator Screenshot - iPhone 15 Pro - 2025-01-20 at 14.07.51.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/a9f7a5f1-3709-4ef3-824d-ea000f2d11f4/08fb88fb-663b-496c-b079-033773f12f12/Simulator_Screenshot_-_iPhone_15_Pro_-_2025-01-20_at_14.07.51.png)

![Simulator Screenshot - iPhone 15 Pro - 2025-01-20 at 14.08.04.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/a9f7a5f1-3709-4ef3-824d-ea000f2d11f4/7a908c95-ae64-45d5-bcf4-101481b20e25/Simulator_Screenshot_-_iPhone_15_Pro_-_2025-01-20_at_14.08.04.png)

![Simulator Screenshot - iPhone 15 Pro - 2025-01-20 at 14.11.16.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/a9f7a5f1-3709-4ef3-824d-ea000f2d11f4/ae96151f-e58c-43c2-895e-9c643a48d3b1/Simulator_Screenshot_-_iPhone_15_Pro_-_2025-01-20_at_14.11.16.png)

---

## 🗎 Database Schema

The app uses Firebase Firestore for storing data. Below is the schema:

- **Users**:  
  - `id`: Unique user ID  
  - `name`: User's name  
  - `email`: User's email address  

- **Habits**:  
  - `id`: Unique habit ID  
  - `user_id`: ID of the user who owns the habit  
  - `habit_name`: Name of the habit  
  - `start_date`: Start date of the habit  
  - `end_date`: End date of the habit (if applicable)  
  - `is_active`: Boolean indicating if the habit is currently active  
  - `reminder_time`: Time for habit reminders  
  - `google_calendar_event_id`: Associated event ID for Google Calendar  

- **Logs**:  
  - `id`: Unique log ID  
  - `habit_id`: ID of the associated habit  
  - `log_date`: Date of the habit log  
  - `status`: Status of the habit on the logged date  

![Database Schema Diagram](link_to_schema_image)

---

## 🛠️ Key Functionalities

- **Habit Tracking**: Log daily progress and review past entries.  
- **Progress Reports**: Weekly insights, calendar heatmaps, and streak counters.  
- **Challenges**: Engage with pre-made or custom challenges to boost motivation.  
- **Google Calendar Sync**: Subscribe to `.ics` calendars to integrate habits seamlessly.  

---

## 🔖 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

