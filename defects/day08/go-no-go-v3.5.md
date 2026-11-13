## Part 4 — Release decision memo (one page)

**To:** Product Manager — ParcelPoint App  
**From:** QA / Test Engineering  
**Subject:** v3.5 Android + iOS — **NO-GO at current evidence level**  
**Decision needed:** Within one hour, ahead of Monday's 40-courier pilot

**Coverage and gaps:** 
Passed: Android TC-31 (block Delivered without photo), TC-32 (Delivered with photo), and TC-36 (login/route/scan smoke on both platforms). TC-34 signature-pad retest passed **on iPhone 14 only**, even though PP-455 specifically concerns **iPad**; the affected device is not verified. **Not executed:** Android TC-33 photo upload on 3G (blocked by lack of throttling tool), and iOS TC-35 blocking delivery without photo. No iOS positive photo-upload test is listed, nor is offline recovery validated.

**Risks, highest first:** 
1. **iOS delivery without photo may remain possible**: mandatory proof-of-delivery rule unverified, risking unsupported deliveries. 
2. **PP-461 (High severity / Medium priority), Android offline upload retries indefinitely with no message**: couriers may be stuck and not know how to recover, delaying deliveries and generating support contacts. 
3. **3G upload untested**: pilot couriers with poor connectivity may face failures or long waits. 
4. **PP-455 iPad fix unverified on iPad**: signature pad may still freeze on affected hardware. 
5. **PP-463 (Low/Low)** stretched thumbnail: cosmetic, low release risk.

**Recommendation and conditions:** 
**No-go for an unrestricted Android+iOS pilot now.** Reconsider **go with named risks** only after iOS TC-35 passes, the PP-455 fix passes on an iPad, Android photo upload is exercised under constrained/offline conditions with a clear recovery path, and PM/engineering explicitly accept any residual PP-461 risk with mitigation, monitoring, rollback/feature-disable criteria, and courier guidance. A known indefinite retry should not be silently waived.

**PM options and ownership:** 
**Option A:** delay both platforms until gates pass (QA recommendation). 
**Option B:** pilot a restricted platform/device cohort only if that cohort passes mandatory photo and connectivity checks, with written exceptions and rollback triggers. 
**Option C:** proceed with full pilot despite gaps, explicitly accepting the named risks; QA does **not** recommend it. **PM/Product Owner owns the business release decision**, with engineering owning technical readiness and fixes; QA reports evidence and residual risk. Security/compliance owners should approve exceptions if proof-of-delivery is a control requirement.

**Next 60 minutes:** 
Run iOS TC-35 immediately and add a positive iOS photo-delivery test; retest PP-455 on an actual iPad; use OS/network shaping or a real weak network to run TC-33 (otherwise keep it blocked); reproduce PP-461, document recovery and collect logs; confirm device scope, mitigation, pilot monitoring and rollback owner; update the sign-off matrix and send a time-stamped decision request to PM.