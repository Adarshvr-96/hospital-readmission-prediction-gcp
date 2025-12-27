SELECT * FROM `ml-project-482013.Health123.detailed_table` LIMIT 1000

--- count of readmitted ---
-- false = 0 (not readmitted)
-- true = 1 (readmitted)

select 
  readmitted, count(*) as cnt
from `Health123.detailed_table`
group by readmitted
order by cnt desc

-- creating view for ml --


CREATE OR REPLACE VIEW `ml-project-482013.Health123.vw_readmission_scored` AS
SELECT
  *,
  predicted_readmitted_label AS predicted_readmitted
FROM ML.PREDICT(
  MODEL `ml-project-482013.Health123.readmission_model`,
  (
    SELECT
      age,
      time_in_hospital,
      n_lab_procedures,
      n_procedures,
      n_medications,
      n_outpatient,
      n_inpatient,
      n_emergency,
      medical_specialty,
      diag_1,
      diag_2,
      diag_3,
      glucose_test,
      A1Ctest,
      change,
      diabetes_med,
      readmitted
    FROM `ml-project-482013.Health123.detailed_table`
  )
);



SELECT *
FROM ML.PREDICT(
  MODEL `ml-project-482013.Health123.readmission_model`,
  (
    SELECT *
    FROM `ml-project-482013.Health123.detailed_table`
    LIMIT 5
  )
);



CREATE OR REPLACE VIEW `ml-project-482013.Health123.vw_readmission_scored` AS
SELECT
  *,
  predicted_readmitted_label_probs[OFFSET(1)].prob AS readmission_probability
FROM ML.PREDICT(
  MODEL `ml-project-482013.Health123.readmission_model`,
  (
    SELECT
      age,
      time_in_hospital,
      n_lab_procedures,
      n_procedures,
      n_medications,
      n_outpatient,
      n_inpatient,
      n_emergency,
      medical_specialty,
      diag_1,
      diag_2,
      diag_3,
      glucose_test,
      A1Ctest,
      change,
      diabetes_med,
      readmitted
    FROM `ml-project-482013.Health123.detailed_table`
  )
);


select * from `ml-project-482013.Health123.vw_readmission_scored`



WITH thresholds AS (
  SELECT 0.3 AS threshold UNION ALL
  SELECT 0.4 UNION ALL
  SELECT 0.5 UNION ALL
  SELECT 0.6 UNION ALL
  SELECT 0.7
)

SELECT
  t.threshold,

  COUNTIF(readmitted = TRUE  AND readmission_probability >= t.threshold) AS true_positive,
  COUNTIF(readmitted = FALSE AND readmission_probability >= t.threshold) AS false_positive,
  COUNTIF(readmitted = FALSE AND readmission_probability <  t.threshold) AS true_negative,
  COUNTIF(readmitted = TRUE  AND readmission_probability <  t.threshold) AS false_negative

FROM `ml-project-482013.Health123.vw_readmission_scored` s
CROSS JOIN thresholds t
GROUP BY t.threshold
ORDER BY t.threshold;

--------------------------------------------------------
 -- TP → correctly flagged high-risk patients

 -- FP → false alarms (extra cost)

 -- FN → missed readmissions (high risk!)

 -- TN → safe discharges


   --- False negatives are more dangerous than false positives
--------------------------------------------------------

-- precision and recall calculation


WITH cm AS (
  SELECT
    t.threshold,
    COUNTIF(readmitted = True AND readmission_probability >= t.threshold) AS tp,
    COUNTIF(readmitted = False AND readmission_probability >= t.threshold) AS fp,
    COUNTIF(readmitted = True AND readmission_probability <  t.threshold) AS fn
  FROM `ml-project-482013.Health123.vw_readmission_scored` s
  CROSS JOIN (
    SELECT 0.3 AS threshold UNION ALL
    SELECT 0.4 UNION ALL
    SELECT 0.5 UNION ALL
    SELECT 0.6 UNION ALL
    SELECT 0.7
  ) t
  GROUP BY t.threshold
)

SELECT
  threshold,
  SAFE_DIVIDE(tp, tp + fp) AS precision,
  SAFE_DIVIDE(tp, tp + fn) AS recall,
  SAFE_DIVIDE(2 * tp, 2 * tp + fp + fn) AS f1_score
FROM cm
ORDER BY threshold;




--- Cost & Business Impact Analysis -----------

  -- Why this step matters?
  
  -- The model works: The threshold (0.4) makes sense medically
  
  -- Now the business asks: If we use this model, how much money do we save?
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

WITH flagged AS (
  SELECT
    COUNT(*) AS flagged_patients
  FROM `ml-project-482013.Health123.vw_readmission_scored`
  WHERE readmission_probability >= 0.4
    AND readmitted = TRUE
)
SELECT
  flagged_patients,
  flagged_patients * 0.25 AS preventable_readmissions,
  flagged_patients * 0.25 * 10000 AS estimated_cost_savings_usd
FROM flagged;



















