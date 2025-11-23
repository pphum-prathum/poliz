
# Project Name: Good Poliz

## Test Suite 1 – Secure Chat: User Search
**Test Case IDs:** TC_USER_SEARCH_01 , TC_USER_SEARCH_02  

---

### Test Case 1
**Test Case ID:** TC_USER_SEARCH_01  
**Test Priority:** High  
**Module Name:** GoodPoliz: Secure Chat — User Search  
**Test Title:** Search for user "Ploy" (Happy Path)  
**Description:** Test the search functionality in the secure chat. After logging in and navigating to the chat page, the user enters "Ploy" into the search box and checks if the system displays the corresponding chat. Verify the appearance of the "Ploy" chat in the results.

**Test Designed by:** SuperShine  
**Test Designed date:** 10/11/2025  
**Test Executed by:** SuperShine  
**Test Execution date:** 10/11/2025

**Pre-conditions**
- Users can log in and access the **Secure Chat** page.
- The chat with the name **Ploy** exists.

**Dependencies**
Login page, Dashboard/Home page, Chat list page, Secure Chat page

| Step | Test Steps | Test Data | Expected Result | Actual Result | Status (Pass/Fail) | Notes |
|---:|---|---|---|---|---|---|  
| 1 | Log in and navigate to **Secure Chat**. | Email/Pass: **Nine / Nine** | System logs in successfully and navigates to the secure chat page. | System logs in successfully and navigates to the secure chat page. | Pass |  |  
| 2 | Enter "Ploy" in the **search box**. | `Ploy` | The system displays a chat with the name **Ploy** in the search results. | The system displays a chat with the name **Ploy** in the search results. | Pass |  |  

**Post-conditions**
The **Ploy** chat appears in the search results.

---

### Test Case 2
**Test Case ID:** TC_USER_SEARCH_02  
**Test Priority:** High  
**Module Name:** GoodPoliz: Secure Chat — User Search  
**Test Title:** Search for a non-existent user "eiei" (Unhappy Path)  
**Description:** Test the search functionality when searching for a user that does not exist in the chat list. Enter "eiei" into the search box and verify that no results are returned and the "Not Found" message appears.

**Test Designed by:** SuperShine  
**Test Designed date:** 10/11/2025  
**Test Executed by:** SuperShine  
**Test Execution date:** 10/11/2025

**Pre-conditions**
- Users can log in and access the **Secure Chat** page.

**Dependencies**
Login page, Dashboard/Home page, Chat list page, Secure Chat page

| Step | Test Steps | Test Data | Expected Result | Actual Result | Status (Pass/Fail) | Notes |
|---:|---|---|---|---|---|---|  
| 1 | Log in and navigate to **Secure Chat**. | Email/Pass: **Nine / Nine** | System logs in successfully and navigates to the secure chat page. | System logs in successfully and navigates to the secure chat page. | Pass |  |  
| 2 | Enter "eiei" in the **search box**. | `eiei` | No chats appear, and the message "Not Found" is displayed. | No chats appear, and the message "Not Found" is displayed. | Pass |  |  

**Post-conditions**
No chat with the name "eiei" is found, and the "Not Found" message appears.

---

## Test Suite 2 – Incident Importance Ranking (Add & Rank Incident)
**Test Case IDs:** TC_INCIDENT_ADD_02 , TC_INCIDENT_ADD_01  

---

### Test Case 1
**Test Case ID:** TC_INCIDENT_ADD_01  
**Test Priority:** High  
**Module Name:** GoodPoliz: Incident Importance Ranking  
**Test Title:** Create new Fire incident with all required fields (Happy Path)  
**Description:** Verify that a user can create a new incident with all required fields (Type, Place, Time). After submitting the form, the system saves the incident, calculates the importance score using the heuristic rules, and displays the incident in the list with rank **High**.

**Test Designed by:** SuperShine  
**Test Designed date:** 10/11/2025  
**Test Executed by:** SuperShine  
**Test Execution date:** 10/11/2025  

**Pre-conditions**
- User can log in to the **GoodPoliz** system.
- User has successfully navigated to the **Incident Importance Ranking** page.
- The **Add New Incident** form is visible.

**Dependencies**
Login page, Dashboard/Home page, Incident Importance Ranking page, Backend incident API

| Step | Test Steps | Test Data | Expected Result | Actual Result | Status (Pass/Fail) | Notes |
|---:|---|---|---|---|---|---|
| 1 | Log in and click **"AI Incident Ranking"** from the main menu to open the Incident Importance Ranking page. | Email/Pass: **Earn / Earn** | System logs in successfully navigates to the the Incident Importance Ranking page with the Add New Incident form. | System logs in successfully navigates to the the Incident Importance Ranking page with the Add New Incident form. | Pass |  |
| 2 | In the **Type** field, select incident type. | `Fire` | The **Type** field accepts and shows `Fire`. | The **Type** field accepts and shows `Fire`. | Pass |  |
| 3 | In the **Place** field, enter the incident location. | `ICT, Mahidol University` | The **Place** field accepts and shows `ICT, Mahidol University`. | The **Place** field accepts and shows `ICT, Mahidol University`. | Pass |  |
| 4 | In the **Time** field, enter the incident time. | `06/11/2025 10:30` | The **Time** field accepts and shows `06/11/2025 10:30` in the correct format. | The **Time** field accepts and shows `06/11/2025 10:30` in the correct format. | Pass |  |
| 5 | In the **Note** field, enter additional details. | `Smoke coming from 3rd floor, possible fire.` | The **Note** field accepts and shows the entered text. | The **Note** field accepts and shows the entered text. | Pass |  |
| 6 | Click the **Add & Rank Incident** button. | – | System validates all fields, saves the incident, calculates the score, and shows the new incident in the list with rank **High**. | System validates all fields, saves the incident, calculates the score, and shows the new incident in the list with rank **High**. | Pass |  |

**Post-conditions**
- A new incident with type **Fire** at **ICT, Mahidol University** and time **06/11/2025 10:30** is stored in the system.
- The incident appears in the incident list with its importance rank displayed as **High**.

---

### Test Case 2
**Test Case ID:** TC_INCIDENT_ADD_02  
**Test Priority:** High  
**Module Name:** GoodPoliz: Incident Importance Ranking  
**Test Title:** Fail to create incident when Place field is empty  
**Description:** Verify that the system prevents creating a new incident when the required **Place** field is left empty. The system must show an error message and must not save the incident.

**Test Designed by:** SuperShine  
**Test Designed date:** 10/11/2025  
**Test Executed by:** SuperShine  
**Test Execution date:** 10/11/2025  

**Pre-conditions**
- User can log in to the **GoodPoliz** system.
- User has successfully navigated to the **Incident Importance Ranking** page.
- The **Add New Incident** form is visible.

**Dependencies**
Login page, Dashboard/Home page, Incident Importance Ranking page, Frontend form validation

| Step | Test Steps | Test Data | Expected Result | Actual Result | Status (Pass/Fail) | Notes |
|---:|---|---|---|---|---|---|
| 1 | Log in and click **"AI Incident Ranking"** from the main menu to open the Incident Importance Ranking page. | Email/Pass: **Earn / Earn** | System logs in successfully and navigate to the Incident Importance Ranking page with the Add New Incident form. | System logs in successfully and navigate to the Incident Importance Ranking page with the Add New Incident form. | Pass |  |
| 2 | In the **Type** field, select incident type. | `Fire` | The **Type** field accepts and shows `Fire`. | The **Type** field accepts and shows `Fire`. | Pass |  |
| 3 | Leave the **Place** field empty. | *(empty)* | The **Place** field remains empty. | The **Place** field remains empty. | Pass |  |
| 4 | In the **Time** field, enter the incident time. | `06/11/2025 10:30` | The **Time** field accepts and shows `06/11/2025 10:30` in the correct format. | The **Time** field accepts and shows `06/11/2025 10:30` in the correct format. | Pass |  |
| 5 | In the **Note** field, enter additional details. | `Smoke coming from 3rd floor, possible fire.` | The **Note** field accepts and shows the entered text. | The **Note** field accepts and shows the entered text. | Pass |  |
| 6 | Click the **Add & Rank Incident** button. | – | System does **not** submit the form. A snackbar/message appears with text `Place is required`. No new incident is saved; the incident list remains unchanged. | System does not submit the form. A snackbar/message appears with text `Place is required`. No new incident is saved; the incident list remains unchanged. | Pass |  |

**Post-conditions**
- No new incident is created in the system.
- The user is clearly informed that the **Place** field is required before an incident can be created.

---

## Test Suite 3 – Incident Importance Ranking: Search Incident
**Test Case IDs:** TC_INCIDENT_SEARCH_01, TC_INCIDENT_SEARCH_02  

---

### Test Case 1
**Test Case ID:** TC_INCIDENT_SEARCH_01  
**Test Priority:** High  
**Module Name:** GoodPoliz: Incident Importance Ranking — Search  
**Test Title:** Search incident by type "Fire" (Happy Path)  
**Description:** After adding at least one incident with type "Fire", verify that using the search box on the AI Incident Ranking page with input "Fire" filters the list and displays the corresponding incident(s).

**Test Designed by:** SuperShine  
**Test Designed date:** 10/11/2025  
**Test Executed by:** SuperShine  
**Test Execution date:** 10/11/2025  

**Pre-conditions**
- User can log in to the **GoodPoliz** system.
- At least one incident with **Type = "Fire"** already exists (e.g., created from Test Suite 2 – Add & Rank Incident).
- The **AI Incident Ranking** menu item is available.
- Backend for incidents is running and reachable.

**Dependencies**
Login page, Dashboard/Home page, AI Incident Ranking page, Incident list, Search box

| Step | Test Steps | Test Data | Expected Result | Actual Result | Status (Pass/Fail) | Notes |
|---:|---|---|---|---|---|---|
| 1 | Log in and click **"AI Incident Ranking"** from the main menu to open the Incident Importance Ranking page. | Email/Pass: **Earn / Earn** | System logs in successfully and displays the Incident Importance Ranking page with the incident list and search box. | System logs in successfully and displays the Incident Importance Ranking page with the incident list and search box. | Pass |  |
| 2 | In the **search box** above the incident list, enter `Fire`. | `Fire` | The search box accepts `Fire`, and the incident list is filtered to show only incidents whose data contains "Fire". At least one incident with **Type = "Fire"** is visible, and the footer shows **Loaded: N incidents** (N ≥ 1). The message *“No incidents found (or Backend disconnected).”* is **not** shown. | The search box accepts `Fire`, the list shows only the Fire incident(s), and the footer shows **Loaded: 1 incident**. No "No incidents found" message is displayed. | Pass |  |

**Post-conditions**
- The list on the Incident Importance Ranking page is filtered to show only incident(s) whose type includes **"Fire"**.
- The user can clearly see the Fire incident previously added.

---

### Test Case 2
**Test Case ID:** TC_INCIDENT_SEARCH_02  
**Test Priority:** Medium  
**Module Name:** GoodPoliz: Incident Importance Ranking — Search  
**Test Title:** Search incident by type "Traffic Accident" (No matching incident)  
**Description:** Verify that when the user searches with a type that does not match any existing incident (e.g., "Traffic Accident"), the incident list becomes empty and the **“No incidents found”** message is displayed.

**Test Designed by:** SuperShine  
**Test Designed date:** 10/11/2025  
**Test Executed by:** SuperShine  
**Test Execution date:** 10/11/2025  

**Pre-conditions**
- User can log in to the **GoodPoliz** system.
- No incident with **Type = "Traffic Accident"** exists in the system.
- At least one other incident (e.g., "Fire") in the system (to know the list is not empty).
- The **AI Incident Ranking** menu item is available.
- Backend for incidents is running and reachable.

**Dependencies**
Login page, Dashboard/Home page, AI Incident Ranking page, Incident list, Search box

| Step | Test Steps | Test Data | Expected Result | Actual Result | Status (Pass/Fail) | Notes |
|---:|---|---|---|---|---|---|
| 1 | Log in and click **"AI Incident Ranking"** from the main menu to open the Incident Importance Ranking page. | Email/Pass: **Earn / Earn** | System logs in successfully and displays the Incident Importance Ranking page with the incident list and search box. | System logs in successfully and displays the Incident Importance Ranking page with the incident list and search box. | Pass |  |
| 2 | In the **search box** above the incident list, enter `Traffic Accident`. | `Traffic Accident` | The search box accepts `Traffic Accident`. The incident list becomes empty, the text **“No incidents found** is displayed, and the footer shows **Loaded: 0 incidents**. No incident rows are shown. | The list becomes empty, the message “No incidents found (or Backend disconnected).” is displayed, and the footer shows **Loaded: 0 incidents**. No incident rows are shown. | Pass |  |

**Post-conditions**
- No incident is displayed for the search query **"Traffic Accident"**.
- The user sees a clear empty-state message instead of incorrect or stale data.

---
