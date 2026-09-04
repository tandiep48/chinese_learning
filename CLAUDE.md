# Project Overview

E-learning mobile application focused on Chinese language education for iOS and Android.
**Important Architecture Note:** This is the mobile frontend for the YiChinese platform, built with Flutter, which consumes the backend API (Flask/PostgreSQL).

# Tech Stack

- **Framework:** Flutter (Dart)
- **Target Platforms:** iOS, Android
- **Backend API:** Python (Flask) located in the `Learning/` folder.

# Global Execution Rules

Strictly adhere to the following workflow, coding, and communication constraints:

## 1. Pre-Execution & Strategy (Think Before Doing)

Do not blindly write code. Analyze the request and ask for clarification if you are unsure about:

- **1.1 Feature Intent:** What exactly the requested feature is supposed to achieve.
- **1.2 Implementation:** The technical strategy for executing the feature in Flutter.
- **1.3 Duplication/Conflicts:** If the new feature seems to already exist or conflicts with existing functionality in the codebase.
- **1.4 Dependencies:** If the implementation requires third-party packages (from pub.dev) that may need human setup, API keys, or iOS/Android specific native configurations (e.g., Info.plist, AndroidManifest.xml).

## 2. Coding Standards & Output

- **2.1 No Conversational Filler:** Output only the code. Do not explain every action, provide summaries for each item, or narrate your thought process. Only provide explanations if explicitly asked to do so.
- **2.2 Performance & Readability:** Ensure the code is highly performant and readable for human review. Use `const` constructors where possible to optimize Flutter widget rebuilds.
- **2.3 Automated Testing:** Do not write test cases for each new feature you write unless explicitly requested, as testing may be done manually by the user initially.
- **2.4 Housekeeping:** Clean up unneeded items, dead code, and unused imports within the specific folder you are working on.
- **2.5 State Management:** Be mindful of the state management approach being used. Follow existing patterns if present.

## 3. Git & Version Control Constraints

- **3.1 Branching:** All work in the `chinese_learning/` folder must be done on the development branch (e.g., `dev`).
- **3.2 Pull Requests:** Only pull the latest code on these branches when explicitly instructed by the user.
- **3.3 No Committing:** Do not commit code after completing a task. Keep the changes uncommitted so the user can review the results first.

## 4. UI/UX and Layout Standards (Flutter)

When working in the `chinese_learning` Flutter app, strictly follow these design rules:

- **4.1 Centralized Theming:** Utilize `ThemeData` (e.g., `theme.dart`) for defining colors, typography, and component styles. Avoid hardcoding hex colors or text styles directly in individual widgets.
- **4.2 Component Spacing & Layout:** Use standardized spacing values. Rely on standard layout widgets like `Column`, `Row`, `Stack`, and `Flex` for structural page layouts, and `Padding` / `SizedBox` for spacing.
- **4.3 Responsive Design:** Ensure the app looks good on various iOS and Android screen sizes, handling safe areas (`SafeArea`) appropriately. Implement responsive layouts for larger screens (tablets) if required.
- **4.4 UI Consistency:** Extract reusable widgets (e.g., custom buttons, cards, dialogs) into a shared `widgets/` or `components/` directory instead of duplicating code.
- **4.5 Loading & Empty States:** Utilize appropriate loading indicators (e.g., `CircularProgressIndicator` or skeleton loaders) for async operations, and ensure clear, accessible empty states when API queries return no data.

# Project Structure

```text
chinese_learning/
├── android/            # Android specific project files
├── ios/                # iOS specific project files
├── lib/
│   ├── main.dart       # Entry point of the Flutter application
│   └── ...             # (Structure to be expanded with screens, widgets, models, services)
├── pubspec.yaml        # Flutter dependencies and assets configuration
└── test/               # Automated tests
```
