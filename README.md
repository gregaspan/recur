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

