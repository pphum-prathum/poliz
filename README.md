# GoodPoliz – Automated UI & Integration Testing

GoodPoliz is a mobile and backend system designed to support police operations through AI-assisted decision-making, real-time alerts, and secure communication.

This project includes Flutter automated UI tests written with the **integration_test framework**, and executed on **Flutter Web (Chrome)** using the **Flutter Drive runner** and **ChromeDriver**.


## Core Features
- **Incident Importance Ranking**
- **Real-Time Emergency Alerts**
- **Traffic & Crime Data Dashboard**
- **Secure Chat Box for Officers**
- **Performance Analytics Reporting**

This README summarizes the **Unit Testing**, **System Testing**, and **Automated UI Testing** implemented for the project.

---

# 1. Unit Testing (Backend – Java Spring Boot)

Our backend unit tests are implemented using **JUnit**, **Mockito** with three unit test suites covering both controller and service layers.  
Each suite includes multiple test cases designed using input space partitioning and logic coverage techniques.

### Unit Test Suites Overview

#### **1. CrimeIncidentControllerTest**
Validates:
- `getCrimeIncidents(type)` filtering logic
- Treating `null`, blank, and "All Types" as “no filter”
- Returning only incidents matching a specific type (e.g., "Traffic Accident")
- Returning an empty list when no incident matches the requested type

Coverage:
![Dashboard Screenshot](statement_coverage/crimecontroller.jpg)

#### **2. IncidentServiceTest**
Validates:
- The importance score calculation in `addNewIncident(Incident)`
- How incident type, time of day, place, and notes (severity keywords) contribute to the final score
- Mapping from score → rank level (`LOW`, `MEDIUM`, `HIGH`) and `isRanked` / `isNew` flags
- Repository interaction for saving the enriched incident

Coverage:
![Dashboard Screenshot](statement_coverage/incidentservice.jpg)

#### **3. ChatControllerTest**
Validates:
- Sending messages between two users
- Creating a new chat if none exists
- Basic input validation for message text (empty vs non-empty)
- Handling failures when saving messages

Coverage:
![Dashboard Screenshot](statement_coverage/chatcontroller.jpg)

### Folder Structure
```text
test/
└── java
    └── com/example/demo
        ├── controller
        │   ├── ChatControllerTest.java
        │   └── CrimeIncidentControllerTest.java
        └── service
            └── IncidentServiceTest.java
```

# 2. System Testing (Manual Tests)

We performed manual system testing for three major workflows in the GoodPoliz mobile app.  
All detailed test cases (with IDs, steps, expected/actual results) are located in: 
```text
manual test case/
└──Test_suites_README.md
```

#### **Test Suite 1 — Secure Chat: User Search**
Covers:
- Searching for an existing user (happy path)
- Searching for a non-existent user (unhappy path)

Focus: list filtering and proper empty-state handling.

---

#### **Test Suite 2 — Incident Importance Ranking: Add & Rank**
Covers:
- Creating an incident with all required fields  
- Form validation when required fields are missing  

Focus: incident creation workflow and ranking logic.

---

#### **Test Suite 3 — Incident Importance Ranking: Search Incident**
Covers:
- Searching for existing incident types  
- Empty-state handling when no matching incidents exist  

Focus: filtering logic and correctness of displayed results.

---

### Requirement Traceability Matrix
Located in the same folder: 
```text
manual test case/
└──Traceability_matrix.README.md
```

# 3. Automated UI Testing (Flutter Integration Test + Flutter Drive Runner)

We implemented automated UI testing using:

- **integration_test** (main testing framework)
- **flutter_test** (WidgetTester utilities)
- **Flutter Drive (as the test runner for Web)**
- **ChromeDriver** (web automation)
- **Flutter Web (Chrome)**

Each automated test suite is directly based on its corresponding manual test suite.

### Automated Test Suites Overview

#### **1. search_chat_test.dart**
Automates the Secure Chat search workflow (TC_USER_SEARCH_01 and TC_USER_SEARCH_02):

- Logs in as `Nine` and navigates to the **Secure Chat** screen.
- TC_USER_SEARCH_01 (happy path):  
  - Enters `Ploy` into the search box  
  - Confirms the chat named **Ploy** appears in the ListView.
- TC_USER_SEARCH_02 (unhappy path):  
  - Enters `eiei`  
  - Confirms no chat results appear and the **“Not Found”** message is displayed.

#### **2. incident_importance_ranking_test.dart**
Automates the manual incident creation tests (TC_INCIDENT_ADD_01 and TC_INCIDENT_ADD_02):

- Logs in as `Earn` and navigates to the **AI Incident Ranking** page.
- Fills and submits the **Add New Incident** form for a Fire incident:
  - Happy path: all fields filled → new incident card `Fire @ ICT, Mahidol University` appears.
  - Unhappy path: Place left empty → validation message `Place is required` is shown.

#### **3. search_incident_test.dart**
Automates the incident search scenarios (TC_INCIDENT_SEARCH_01 and TC_INCIDENT_SEARCH_02):

- Logs in as `Earn` and navigates to the **AI Incident Ranking** page.
- TC_INCIDENT_SEARCH_01 (happy path):
  - Programmatically adds a Fire incident (`Fire @ ICT, Mahidol University`).
  - Enters `Fire` in the search field.
  - Confirms the Fire incident card appears in the filtered list.
- TC_INCIDENT_SEARCH_02 (no-match case):
  - Enters `Traffic Accident` in the search field.
  - Confirms the UI shows `Loaded: 0 incidents` (no incidents found).


### Folder Structure
```text
/automated_test_cases/
├── search_chat_test.dart
├── search_incident_test.dart
└── incident_importance_ranking_test.dart
```

---

## Running Automated UI Tests 
### **Start ChromeDriver**
Before running any test, ChromeDriver must be running.

```sh
chromedriver --port=4444
```

### **Search Chat Test**
```sh
flutter drive --driver automated_test_cases/search_chat_test.dart --target=automated_test_cases/search_chat_test.dart -d chrome
```

### **Search Incident Test**
```sh
flutter drive --driver automated_test_cases/search_incident_test.dart --target=automated_test_cases/search_incident_test.dart -d chrome
```

### **Add & Rank Test**
```sh
flutter drive --driver automated_test_cases/incident_importance_ranking_test.dart --target=automated_test_cases/incident_importance_ranking_test.dart -d chrome
```
