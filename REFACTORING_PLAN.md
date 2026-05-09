# Demo/Prod Mode Refactoring Plan

## Overview

This refactoring separates Demo Mode and Production Mode by introducing abstract service interfaces, consolidating providers, and removing scattered `if (MockConfig.isMockMode)` branching from all screens.

## Status

**Completed: 8/15 phases (53%)**
**Pending: 7/15 phases (47%)**
**Estimated Time Remaining: ~15-20 minutes**

---

## Architecture Change

### Before (Current - Broken)

```
Screen (login_screen.dart)
  |
  +--> if (mock) MockAuthProvider   else AuthProvider
  |    | (calls MockAuthService)    | (calls Amplify directly)
  |
  v
UI rebuilds
```

**Problems:**
- `if (MockConfig.isMockMode)` scattered across ~10+ screen files (~50+ occurrences)
- No shared interface between mock and real services
- Inconsistent patterns (some use services, some call Amplify directly)
- Two parallel provider hierarchies with no common contract

### After (Target - Clean)

```
main.dart (ONLY place that decides mode)
  |
  +--> isDemoMode ? MockAuthService() : AmplifyAuthService()
  +--> isDemoMode ? MockComplaintService() : AmplifyComplaintService()
  +--> isDemoMode ? MockNotificationService() : AmplifyNotificationService()
  |
  v
AuthProvider (single class, takes AuthService via constructor)
  |
  v
Screen (NO branching, always calls context.read<AuthProvider>())
```

**Benefits:**
- Single provider per domain (no mock/real split)
- One place to switch between Demo and Prod
- All screens use same `context.read<AuthProvider>()` call
- Proper dependency injection
- Easy to add new backends

---

## Files Inventory

### Phase 1-3: Service Layer (COMPLETED ✅)

| Action | File | Status |
|--------|------|--------|
| Create interface | `lib/services/auth_service.dart` | ✅ DONE |
| Create interface | `lib/services/complaint_service.dart` | ✅ DONE |
| Create interface | `lib/services/notification_service_interface.dart` | ✅ DONE |
| Create real impl | `lib/services/amplify_auth_service.dart` | ✅ DONE |
| Create real impl | `lib/services/amplify_complaint_service.dart` | ✅ DONE |
| Update mock impl | `lib/services/mock/mock_auth_service.dart` | ✅ DONE (implements AuthService) |
| Update mock impl | `lib/services/mock/mock_complaint_service.dart` | ✅ DONE (implements ComplaintService) |
| Update mock impl | `lib/services/mock/mock_notification_service.dart` | ✅ DONE (implements NotificationServiceInterface) |
| Update real impl | `lib/services/notification_service.dart` | ✅ DONE (implements NotificationServiceInterface) |

### Phase 4: Consolidate Providers (COMPLETED ✅)

| Old Files | New File | Status |
|-----------|----------|--------|
| `providers/auth_provider.dart` + `providers/mock/mock_auth_provider.dart` | `providers/auth_provider.dart` (consolidated) | ✅ DONE |
| `providers/complaint_provider.dart` + `providers/mock/mock_complaint_provider.dart` | `providers/complaint_provider.dart` (consolidated) | ✅ DONE |
| `providers/notification_provider.dart` + `providers/mock/mock_notification_provider.dart` | `providers/notification_provider.dart` (consolidated) | ✅ DONE |
| Deleted: `providers/mock/mock_auth_provider.dart` | — | ✅ DELETED |
| Deleted: `providers/mock/mock_complaint_provider.dart` | — | ✅ DELETED |
| Deleted: `providers/mock/mock_notification_provider.dart` | — | ✅ DELETED |

### Phase 5-8: Update Screens (COMPLETED ✅)

| Screen | Lines Removed | Status |
|--------|--------------|--------|
| `screens/auth/splash_screen.dart` | ~20 lines | ✅ DONE |
| `screens/auth/login_screen.dart` | ~15 lines | ✅ DONE |
| `screens/auth/otp_screen.dart` | ~15 lines | ✅ DONE |
| `screens/home_screen.dart` | ~20 lines | ✅ DONE |

---

## Remaining Work (Phases 9-15)

### Phase 9: Update Profile Tab
**File:** `screens/home/tabs/profile_tab.dart`
**Lines to Remove:** ~30 lines
**Changes:**
- Remove `if (MockConfig.isMockMode)` branching in `Consumer`
- Remove `if (MockConfig.isMockMode)` branching in `Consumer<ComplaintProvider>`
- Remove `if (MockConfig.isMockMode)` branching in `_showLogoutDialog`
- Always use `context.read<AuthProvider>()`
- Always use `context.read<ComplaintProvider>()`
- Remove imports: `providers/mock/mock_auth_provider.dart`, `providers/mock/mock_complaint_provider.dart`
- Keep imports: `providers/auth_provider.dart`, `providers/complaint_provider.dart`

### Phase 10: Update Complaints Tab
**File:** `screens/home/tabs/complaints_tab.dart`
**Lines to Remove:** ~20 lines
**Changes:**
- Remove `if (MockConfig.isMockMode)` branching in `_loadComplaints`
- Remove `if (MockConfig.isMockMode)` branching in `build` (double Consumer)
- Always use `context.read<AuthProvider>()`
- Always use `context.read<ComplaintProvider>()`
- Remove imports: `providers/mock/mock_auth_provider.dart`, `providers/mock/mock_complaint_provider.dart`

### Phase 11: Update History Tab
**File:** `screens/home/tabs/history_tab.dart`
**Lines to Remove:** ~20 lines
**Changes:**
- Remove `if (MockConfig.isMockMode)` branching in `_loadComplaints`
- Remove `if (MockConfig.isMockMode)` branching in `_getFilteredComplaints`
- Remove `if (MockConfig.isMockMode)` branching in `build` (double Consumer)
- Always use `context.read<AuthProvider>()`
- Always use `context.read<ComplaintProvider>()`
- Remove imports: `providers/mock/mock_auth_provider.dart`, `providers/mock/mock_complaint_provider.dart`

### Phase 12: Update File Complaint Screen
**File:** `screens/complaint/file_complaint_screen.dart`
**Lines to Remove:** ~30 lines
**Changes:**
- Remove `if (MockConfig.isMockMode)` branching in `_submitComplaint`
- Always use `context.read<AuthProvider>()`
- Always use `context.read<ComplaintProvider>()`
- Remove imports: `providers/mock/mock_auth_provider.dart`, `providers/mock/mock_complaint_provider.dart`

### Phase 13: Update Notification List Screen
**File:** `screens/notification_list_screen.dart`
**Lines to Remove:** ~25 lines
**Changes:**
- Remove `if (MockConfig.isMockMode)` branching in `_loadNotifications`
- Remove `if (MockConfig.isMockMode)` branching in `build` (double Consumer)
- Remove `if (MockConfig.isMockMode)` branching in `_buildNotificationTile`
- Always use `context.read<NotificationProvider>()`
- Remove imports: `providers/mock/mock_notification_provider.dart`

### Phase 14: Update Create Notification Screen
**File:** `screens/admin/create_notification_screen.dart`
**Lines to Remove:** ~25 lines
**Changes:**
- Remove `if (MockConfig.isMockMode)` branching in `_sendNotification`
- Always use `context.read<AuthProvider>()`
- Always use `context.read<NotificationProvider>()`
- Remove imports: `providers/mock/mock_auth_provider.dart`, `providers/mock/mock_notification_provider.dart`

### Phase 15: Update Widgets
**Files:** `widgets/notification_bell.dart`, `widgets/developer_tools.dart`
**Lines to Remove:** ~40 lines total
**Changes:**
- Remove `if (MockConfig.isMockMode)` branching in both widgets
- Always use `context.read<NotificationProvider>()`, `context.read<AuthProvider>()`, etc.
- Remove imports: `providers/mock/mock_*.dart`

### Phase 16: Update main.dart (FINAL STEP)
**File:** `main.dart`
**Lines to Add:** ~20 lines (simplified provider registration)
**Changes:**
- Simplify `_getProviders()` to inject services based on mode
- Only place where `MockConfig.isMockMode` is checked
- Register single providers with service injection

---

## Summary Statistics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Provider classes | 8 (4 real + 4 mock) | 4 | -50% |
| Service interfaces | 0 | 3 | +3 |
| Service implementations | 5 (1 real + 4 mock) | 8 | +3 |
| `if (MockConfig.isMockMode)` | ~50 occurrences | 1 | -98% |
| Files modified | — | ~15 | — |
| New files | — | 5 | — |
| Deleted files | — | 3 | — |

---

## Testing Checklist

After completing all phases:

- [ ] App starts in Demo Mode (mock providers)
- [ ] Login with User Demo works
- [ ] Login with Admin Demo works
- [ ] OTP verification works
- [ ] Home screen loads without errors
- [ ] Profile tab displays correctly
- [ ] Complaints tab displays correctly
- [ ] History tab displays correctly
- [ ] Can file a new complaint
- [ ] Notifications work
- [ ] Logout works instantly
- [ ] No "Could not find correct Provider" errors

---

## Notes

1. **Singleton pattern used:** `_MockProviders` singleton in main.dart ensures consistent provider instances
2. **Service injection:** All providers take service interfaces via constructor
3. **No breaking changes:** All screens still use `context.read<AuthProvider>()` etc., no UI changes needed
4. **MockConfig unchanged:** `isMockMode` flag stays in place, only read from main.dart

---

## Rollback Plan

If needed, revert to previous commit. All changes are in separate files that can be easily reverted.
