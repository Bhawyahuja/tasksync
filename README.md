# TaskSync

A simple Flutter todo app built using the JSONPlaceholder API.

This was created as part of an assignment, but I tried to structure it close to how I’d build a real
feature with clean separation of layers, BLoC for state management, API integration, and basic
offline support.

---

## Demo Login

```
Email: demo@tasksync.dev  
Password: password123
```

---

## How to Run

The project uses FVM with Flutter `3.41.6`.

```sh
.fvm/flutter_sdk/bin/flutter pub get
.fvm/flutter_sdk/bin/dart run build_runner build --delete-conflicting-outputs
.fvm/flutter_sdk/bin/flutter run
```

Optional checks:

```sh
.fvm/flutter_sdk/bin/flutter analyze
.fvm/flutter_sdk/bin/flutter test
```

Debug APK:

```
build/app/outputs/flutter-apk/app-debug.apk
```

---

## Features

* View todos (fetched from API + cached locally)
* Add new task
* Mark task as complete/incomplete
* Delete task (with confirmation)
* Search tasks
* Filter (All / Pending / Completed)
* Pull to refresh
* Offline support with local cache
* Optimistic updates for better UX
* Manual sync button
* Auto sync when connection is restored
* Basic mock login screen

---

## Project Structure

The project is divided into clear layers:

```
lib/
 ├── app/              → routing + app setup
 ├── core/             → shared utilities (network, helpers)
 ├── features/
 │    ├── auth/        → login
 │    └── tasks/
 │         ├── data/         → API + local storage
 │         ├── domain/       → entity + repository contract
 │         └── presentation/ → UI + BLoC
```

UI is split into smaller reusable widgets like:

* task list
* task tile
* add task bottom sheet
* skeleton loader

---

## BLoC Approach

`TaskBloc` manages all task-related logic:

* loading tasks
* adding tasks
* updating completion
* deleting tasks
* searching
* syncing pending changes

State is kept simple using a single `TaskState` with a status (loading/success/error) instead of
multiple complex states.

Some responsibilities were moved out of the BLoC to keep it clean:

* connectivity handling
* user-facing messages
* list mutation helpers (for optimistic updates)

---

## API Integration

Used JSONPlaceholder endpoints:

```
GET    /todos
POST   /todos
PATCH  /todos/:id
DELETE /todos/:id
```

Dio is used for networking with basic setup for:

* base URL
* error handling
* debug logs

---

## Offline Support

Implemented a simple offline-first approach:

* Todos are cached locally using `shared_preferences`
* UI updates immediately (optimistic updates)
* Changes are stored in a pending queue
* Sync is retried:

    * manually (sync button)
    * automatically when connection is restored

Since JSONPlaceholder doesn’t persist changes, local data is treated as the source of truth.

---

## Assumptions

* Login is mocked (no real authentication)
* Search is local
* JSONPlaceholder is treated as a non-persistent API
* `shared_preferences` is used for simplicity (can be replaced with Hive/Drift in real apps)

---

## Challenges

* JSONPlaceholder doesn’t actually persist writes, so local state handling was required
* Managing offline sync without overcomplicating the logic
* Keeping BLoC clean while handling multiple responsibilities
* Balancing UI polish with time constraints

---

## Notes

* Focus was on clean structure, readability, and handling real-world scenarios like offline support
* UI is kept simple but slightly styled for better usability

---

# Demo Link

https://drive.google.com/file/d/18bGQsLGndRKE3ISD9C_okgbyen7_E3Lv/view?usp=sharing

## Screenshots

![Login](assets/login.jpeg)
![Home Screen](assets/home.jpeg)
![Add Task](assets/add_task.jpeg)