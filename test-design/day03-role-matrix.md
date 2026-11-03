# Day 3 — Role and permission matrix (self-administered, no EM send)

Use this with the OWASP Top 10 course (Broken Access Control) and the OWASP Authorization Cheat Sheet. The sandbox follows these rules on paper. **You will test them for real on Day 5**, so today you design the tests only.

| Action | merchant_admin | merchant_staff | support | courier |
|---|---|---|---|---|
| See own merchant's shipments | Yes | Yes | Yes (all merchants) | Only assigned |
| See another merchant's shipments | No (404) | No (404) | Yes | Only assigned |
| Create shipment | Yes | Yes | No (403) | No (403) |
| Change status of own merchant's shipment | Yes | Yes | No (403) | Only assigned, not Cancelled |
| Change status of another merchant's shipment | No (404) | No (404) | No (403) | Only assigned |
| Cancel a shipment | Yes | Yes | No | No (403) |

## Your task

Write the **negative and security** test cases for this matrix. For each case: the user, the request (method + path + body), the expected status code, and why it matters. Include at least:

1. Each role trying each action it must **not** be able to do.
2. **ID tampering:** a merchant user changing the shipment ID in the URL to another merchant's shipment, for both read and write. (Why is it a problem if read returns 404 but write returns 200?)
3. Token problems: missing, malformed, from a logged-out session, from a different user.
4. A courier changing a shipment that is not assigned to them.
5. A final-state shipment (Delivered) being moved back to an earlier state.

Mark each case **Critical / High / Medium / Low** and justify every Critical in one line (data exposure across merchants, money, or an action that cannot be undone).
