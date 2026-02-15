<h1>To-Do-List App</h1>

<p>The To-Do-List App is an iOS productivity application developed using Swift and UIKit (Storyboard-based). The app allows users to create, manage, categorize, search, and schedule reminders for tasks.</p>

## Table of Contents

&nbsp;&nbsp;&nbsp;&nbsp;[Features](#features)<br/>
&nbsp;&nbsp;&nbsp;&nbsp;[Compatibility](#compatibility)<br/>
&nbsp;&nbsp;&nbsp;&nbsp;[Setup Instructions](#setup-instructions)<br/>
&nbsp;&nbsp;&nbsp;&nbsp;[Architecture](#architecture)<br/>
&nbsp;&nbsp;&nbsp;&nbsp;[Prototype](#prototype)<br/>
&nbsp;&nbsp;&nbsp;&nbsp;[Data Persistence](#data-persistence)<br/>
&nbsp;&nbsp;&nbsp;&nbsp;[Notifications](#notifications)<br/>
&nbsp;&nbsp;&nbsp;&nbsp;[References](#references)<br/>

---

## Features

- Create, edit, and delete to-do items.
- Mark tasks as complete or incomplete.
- Assign due dates using a Date Picker.
- Visual highlighting for:
  - Overdue tasks (red)
  - Upcoming tasks within 24 hours (orange)
- Enable or disable reminder notifications using a switch.
- Local notifications via `UNUserNotificationCenter`.
- Categorize tasks into:
  - Work
  - Personal
  - Other
- Automatic grouping into sections:
  - Work
  - Personal
  - Other
  - Completed
- Search functionality:
  - Filter by title
  - Filter by notes
  - Filter by category keyword
- Share task details using `UIActivityViewController`.
- Local data persistence using Property List encoding.
  
---

## Compatibility

The app is compatible with both iPads and iPhones and has been tested across multiple screen sizes.

- **iPad Air 11-inch (M3)**: Main testing device for iPad compatibility.
- **iPhone 16 Pro**: Main testing device for iPhone compatibility.

Both devices are running on **iOS 18**.

---

## Setup Instructions

1. **Clone the Repository**
   - Open Xcode.
   - Select *Clone Git Repository*.
   - Enter the repository URL:
     ```
     https://github.com/alshabbaqf-bot/ToDoList.git
     ```
   - Choose a local directory and clone.

2. **Open the Project**
   - Open the `.xcodeproj` file in Xcode.

3. **Select Simulator**
   - Choose an iPhone or iPad simulator (e.g., iPhone 16 Pro or iPad Air 11-inch).

4. **Run the App**
   - Press ⌘R or click the Run button.
   - Allow notification permission when prompted.

---

## Architecture

The app follows the **Model-View-Controller (MVC)** architectural pattern.

### Model
- `ToDo` struct
- `ToDoCategory` enum
- Business logic for data persistence and notification identifiers

### View
- Storyboard-based UI
- Custom `ToDoCell`
- Segmented control for category selection
- UISearchController for filtering

### Controller
- `ToDoTableViewController`
- `ToDoDetailTableViewController`
- Handles:
  - Navigation
  - Data updates
  - Section grouping
  - Search filtering
  - Notification scheduling

---

## Prototype

A simple high-fidelity prototype was created in Figma before development to outline the application layout and user flow.

The prototype includes:

- Home screen with categorized and completed task sections
- Add / Edit task screen
- Reminder toggle interaction
- Due date selection interface

**Figma Prototype (Public Link):**  
```
https://www.figma.com/design/j7HdbQSpazXIPcTkg8sgPa/To-Do-List?m=auto&t=oefiTIv2d9qreOpg-1
```
---

## Data Persistence

Tasks are stored locally using:

- `Codable`
- `PropertyListEncoder`
- `PropertyListDecoder`

Data is saved to the app’s Documents directory as a `.plist` file.

---

## Notifications

Local notifications are implemented using:

- `UNUserNotificationCenter`
- Calendar-based triggers
- Unique task identifiers (`UUID`)

Notifications:
- Trigger at the task’s due date
- Are automatically cancelled if:
  - Task is marked complete
  - Task is deleted
  - Reminder switch is turned off

---

## References

- Apple Developer Documentation
- Swift Documentation
- UIKit Framework Documentation
- UNUserNotificationCenter Documentation
- SF Symbols
