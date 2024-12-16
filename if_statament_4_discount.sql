if(
  inspection_make in ("TVS","Boxer","Honda"),
  CASE 
    WHEN b4s.days_diff >= 186
    THEN current_price * 0.10
    WHEN  b4s.days_diff >= 248
    THEN current_price * 0.15
    WHEN  b4s.days_diff >= 365
    THEN current_price * 0.20
    END new_price,
  CASE 
    WHEN b4s.days_diff >= 186
    THEN current_price * 0.10
    WHEN  b4s.days_diff >= 248
    THEN current_price * 0.15
    WHEN  b4s.days_diff >= 365
    THEN current_price * 0.20)

IF(inspection_make in ("TVS","Boxer","Honda"), 
  CASE 
    WHEN b4s.days_diff >= 186
    THEN current_price * 0.10
    WHEN  b4s.days_diff >= 248
    THEN current_price * 0.15
    WHEN  b4s.days_diff >= 365
    THEN current_price * 0.30
    END new_price,
 IF(vehicle_grading like "B%", 
    CASE 
    WHEN b4s.days_diff >= 186
    THEN current_price * 0.10
    WHEN  b4s.days_diff >= 248
    THEN current_price * 0.20
    WHEN  b4s.days_diff >= 365
    THEN current_price * 0.30
    END new_price, 
   IF(vehicle_grading like "C%", 
    CASE 
    WHEN b4s.days_diff >= 186
    THEN current_price * 0.15
    WHEN  b4s.days_diff >= 248
    THEN current_price * 0.25
    WHEN  b4s.days_diff >= 365
    THEN current_price * 0.30
    END new_price, 
   value_if_false)
))