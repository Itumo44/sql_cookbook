SELECT
  l.id,
  l.Date_of_Action,
  l.Client_Name,
  l.Client_current_Mobile_No,
  l.Officer_1,
  l.Officer_2,
  UPPER(l.Plate_Number) Plate,
  l.Branch,
  l.Comment,
  m.client_name AS NameFromMifos,
  m.mobile_no AS PhonefromMifos,
  m.legal_status,
  m.account_no,
  l.acc_id
FROM
  `dwoperation.inventory_repo_ke.repo_ticket` AS l
LEFT JOIN
  `dwanalytics.analytics.list_x` AS m
ON
  m.registration_no=UPPER(l.Plate_Number)
WHERE
  l.Action_Type='Repossession'
  AND DATE_DIFF(CURRENT_DATE(), CAST(l.Timestamp AS DATE), MONTH) <= 6
ORDER BY
  l.Date_of_Action