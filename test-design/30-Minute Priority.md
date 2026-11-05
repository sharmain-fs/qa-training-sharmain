## Priority	Test Case ID	Test Scenario	Why It's Risky
**1	TC-PP501-FEE-004	Standard, 11.1 kg → PHP 150**	
    Money: Incorrect rounding of the weight surcharge could cause repeated overcharging or undercharging.

**2	TC-PP501-EP-002	Standard, 5 kg → PHP 120**	
    Used often: A failure in basic Standard booking could affect many customers.

**3	TC-PP501-EP-005	Express, 25 kg → Rejected**	
    Hard to undo: Accepting an overweight Express shipment could create fulfillment problems after booking.

**4	TC-PP501-DT-007	SameDay, 15 kg, Davao City → Rejected**	
    Customer-visible: Allowing SameDay in an unsupported city could result in delivery promises the company cannot fulfill.

**5	TC-PP501-FEE-006	Express, 20 kg → PHP 370**	
    Money and boundary risk: Incorrect handling of the Express weight limit could reject valid bookings or calculate incorrect charges.