# BUG-006 — Invalid Authentication Token Returns 403 Instead of 401 Unauthorized

**Environment:**
- Sandbox Version: v3.4.0
- User/Role: Unauthenticated user (invalid-token caller)

**Request:**
```http
GET /api/shipments/{id}
Authorization: Bearer invalid.token.value
```

**Expected:**

The API should return `401 Unauthorized` when an invalid authentication token is provided.

**README rule:** Authentication: no token → 401. Invalid or expired token → 401.

**Actual:** The API returned `403 Forbidden` instead of the expected `401 Unauthorized`. The existing Postman test incorrectly asserted `403 Forbidden`, causing the test to pass despite violating the README rule.

**Severity:** Low 
**Priority:** High

**Evidence:**
- **Test Case:** AUTH-02 — Invalid Authentication Token
- **Expected HTTP Status:** `401 Unauthorized`
- **Actual HTTP Status:** `403 Forbidden`
- **Postman Test Result:** Passed under the incorrect `403` assertion. ![alt text](<BUG 006_Evidence.png>)
- **Supporting Evidence:** Attach Postman response and test-result screenshots.
- **Additional Verification:** Compare the invalid-token response body with the missing-token response and confirm no protected data is returned.

**Impact:** The API violates its documented authentication contract. Clients may incorrectly interpret an authentication failure as a permissions issue. The incorrect Postman assertion also hides the defect as a false-positive test result.
