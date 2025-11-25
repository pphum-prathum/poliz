# GoodPoliz – Automated UI & Integration Testing

This project includes **Flutter automated UI tests** using  
**Flutter Drive + ChromeDriver + Flutter Web**.


---

## Running Automated UI Tests (Flutter Drive + Chrome)

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
