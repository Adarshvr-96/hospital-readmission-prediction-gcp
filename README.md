# 🏥 Hospital Readmission Risk Prediction & Cost Impact Analysis (GCP)

## 📌 Project Overview

Hospital readmissions within 30 days significantly increase healthcare costs and indicate gaps in patient care.  
This project builds an **end-to-end cloud-based predictive analytics solution** using **BigQuery SQL and BigQuery ML** to:

- Predict patient readmission risk
- Quantify financial impact of readmissions
- Support data-driven operational and cost-saving decisions

> **Core focus:** Prediction is only valuable if it drives **business and cost impact**.

---

## 🎯 Business Problem

### Problem Statement

Hospitals face:
- High penalties for excess readmissions
- Increased operational costs
- Overcrowded facilities and staff strain

However, hospitals often **lack early identification** of patients likely to be readmitted.

### Business Goal

> Identify high-risk patients **before discharge**, intervene early, and **reduce avoidable readmission costs**.

---

## 🧠 Solution Approach

1. Prepare and clean patient encounter data in BigQuery
2. Engineer clinical and utilization features
3. Train a classification model using BigQuery ML
4. Evaluate model using recall-focused metrics
5. Apply probability thresholds aligned with business risk
6. Estimate preventable readmissions and cost savings

---

## 🧾 Dataset Overview

**Dataset:** Diabetes 130-US hospitals dataset  
**Size:** ~100,000 encounters  
**Target Variable:** `readmitted` (Yes / No)

### Key Feature Categories
- Demographics (age)
- Hospital utilization (inpatient, emergency visits)
- Treatment intensity (labs, medications)
- Diagnoses & specialties
- Diabetes medication changes

---

## 🛠️ Tech Stack

| Layer | Tools |
|-----|------|
| Cloud | Google Cloud Platform |
| Data | BigQuery |
| ML | BigQuery ML |
| Language | SQL |
| Version Control | GitHub |

---

## 🧪 Feature Engineering

- Converted categorical values to ML-compatible inputs
- Created utilization indicators for patient severity
- Prevented data leakage from post-discharge fields
- Standardized target label for readmission risk

---

## 🤖 Machine Learning Model

**Model Type:** Logistic Regression (BigQuery ML)

```sql
CREATE MODEL `healthcare_ds.readmission_model`
OPTIONS (
  model_type = 'logistic_reg',
  input_label_cols = ['readmitted']
) AS
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
FROM `healthcare_ds.patient_features`;
