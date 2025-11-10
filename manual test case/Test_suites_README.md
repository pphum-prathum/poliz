
# Project Name: Good Poliz

## Test Case 1
**Test Case ID:** TC_USER_SEARCH_01  
**Test Priority:** High  
**Module Name:** GoodPoliz: Secure Chat — User Search  
**Test Title:** Search for user "Ploy" (Happy Path)  
**Description:** Test the search functionality in the secure chat. After logging in and navigating to the chat page, the user enters "Ploy" into the search box and checks if the system displays the corresponding chat. Verify the appearance of the "Ploy" chat in the results.

**Test Designed by:** SuperShine  
**Test Designed date:** 10/11/2025  
**Test Executed by:** SuperShine  
**Test Execution date:** 10/11/2025

---

### Pre-conditions
- Users can log in and access the **Secure Chat** page.
- The chat with the name **Ploy** exists.

### Dependencies
Login page, Chat list page, Secure Chat page

| Step | Test Steps | Test Data | Expected Result | Actual Result | Status (Pass/Fail) | Notes |
|---:|---|---|---|---|---|---|  
| 1 | Log in and navigate to **Secure Chat**. | Email/Pass: **Nine / Nine** | System logs in successfully and navigates to the secure chat page. | Pass |  |  
| 2 | Enter "Ploy" in the **search box**. | `Ploy` | The system displays a chat with the name **Ploy** in the search results. | Pass |  |  

### Post-conditions
The **Ploy** chat appears in the search results.

---

## Test Case 2
**Test Case ID:** TC_USER_SEARCH_02  
**Test Priority:** High  
**Module Name:** GoodPoliz: Secure Chat — User Search  
**Test Title:** Search for a non-existent user "eiei" (Unhappy Path)  
**Description:** Test the search functionality when searching for a user that does not exist in the chat list. Enter "eiei" into the search box and verify that no results are returned and the "Not Found" message appears.

**Test Designed by:** SuperShine  
**Test Designed date:** 10/11/2025  
**Test Executed by:** SuperShine  
**Test Execution date:** 10/11/2025

---

### Pre-conditions
- Users can log in and access the **Secure Chat** page.

### Dependencies
Login page, Chat list page, Secure Chat page

| Step | Test Steps | Test Data | Expected Result | Actual Result | Status (Pass/Fail) | Notes |
|---:|---|---|---|---|---|---|  
| 1 | Log in and navigate to **Secure Chat**. | Email/Pass: **Nine / Nine** | System logs in successfully and navigates to the secure chat page. | Pass |  |  
| 2 | Enter "eiei" in the **search box**. | `eiei` | No chats appear, and the message "Not Found" is displayed. | Pass |  |  

### Post-conditions
No chat with the name "eiei" is found, and the "Not Found" message appears.

---

