# From Churn Prediction to Retention Strategy

Identifying high-value customers at risk using SQL, Python, machine learning, and Power BI.

## Business question

Which customer groups show elevated churn, which current customers should be prioritized for a retention pilot, and what incremental retention improvement would make that pilot financially worthwhile?

This portfolio project connects descriptive analysis, churn classification, customer prioritization, and illustrative campaign economics. It does not report a deployed campaign or realized business impact.

## Executive findings

- The dataset contains **7,043 customers**, including **1,869 churned customers (26.54%)**.
- Observed churn is higher among month-to-month customers (**42.71%**) and customers with 0–12 months of tenure (**47.44%**). These are associations, not causal effects.
- A random forest achieved **0.8422 ROC-AUC** and **0.6583 average precision** on the held-out test split. At the validation-selected threshold of **0.35**, test precision was **55.97%** and recall was **68.98%**.
- Among **5,174 non-churned customers**, **205** met both the higher-risk and higher-monthly-value criteria. They represent **3.96%** of active customers and **6.42%** of active monthly charges.
- Under the specified cost and contribution assumptions, the illustrative campaign breaks even at approximately **6.29 percentage points** of incremental retention versus no campaign. A 5-point scenario remains unprofitable; a 10-point scenario produces approximately **58.92% ROI**.

## Data and preparation

Source: IBM Telco Customer Churn sample dataset, available in the IBM repository:
https://github.com/IBM/telco-customer-churn-on-icp4d/blob/master/data/Telco-Customer-Churn.csv

The source contains 21 columns. Customer ID is an identifier and churn is the target, leaving 19 candidate predictors. Eleven missing total-charge values occur among customers with zero tenure. These records are retained; numerical imputation is fitted within the modeling pipeline using training data.

Tools: MySQL, SQL, Python, pandas, scikit-learn, Jupyter, and Power BI Desktop.

## Analytical workflow

1. Import and validate the customer data in MySQL.
2. Analyze churn by contract, tenure, internet service, and payment method using SQL and Python.
3. Compare logistic regression and random forest pipelines.
4. Select the classification threshold using validation data and evaluate on the held-out test split.
5. Segment non-churned customers by model score and monthly charges.
6. Calculate campaign scenarios and a retention/cost sensitivity grid.
7. Present findings in a four-page Power BI report.

## Model evaluation

The data was stratified into training, validation, and test splits of 60%, 20%, and 20%, using random seed 42. Split sizes were 4,225, 1,409, and 1,409. Preprocessing was fitted on the training split: median numerical imputation, categorical encoding, and numerical scaling for logistic regression.

The selected random forest used 300 trees, maximum depth 10, and minimum leaf size 5. It remained fitted on training data for the reported test evaluation. The threshold of 0.35 was selected from the tested validation thresholds using F1.

| Held-out test metric | Result |
|---|---:|
| ROC-AUC | 0.8422 |
| Average precision | 0.6583 |
| Precision at threshold 0.35 | 55.97% |
| Recall at threshold 0.35 | 68.98% |
| F1 | 0.6180 |
| Brier score | 0.1361 |
| True positives / false positives | 258 / 203 |
| True negatives / false negatives | 832 / 116 |

The threshold favors greater churn identification at the cost of additional false positives. It is not an economically optimized campaign threshold.

## Customer prioritization

Active customers are defined here as records with `churn = No`. Higher risk means `model_score >= 0.35`. Higher value means the top 20% of active customers by monthly charges, with customer ID used to break ties. Monthly charges are a value proxy, not customer lifetime value.

| Segment | Customers | Customer share | Monthly charge share |
|---|---:|---:|---:|
| Higher risk / High value | 205 | 3.96% | 6.42% |
| Higher risk / Other value | 681 | 13.16% | 14.15% |
| Lower risk / High value | 830 | 16.04% | 27.25% |
| Lower risk / Other value | 3,458 | 66.83% | 52.18% |

Shares may not sum to exactly 100% because of rounding. The 205 priority candidates have combined monthly charges of 20,361.10. The exported candidate list retains split labels: 108 training, 53 validation, and 44 test records. Scores on training records are in-sample; the full candidate list is an illustrative prioritization exercise, not an independently validated deployment list.

## Illustrative retention economics

Assumptions:

- Contact all 205 candidates.
- Charge 15 per contacted customer: 5 contact cost plus 10 offer cost, applied to every contacted customer.
- Use six contribution months and a 40% contribution margin.
- Apply a uniform assumed incremental retention effect across candidates.
- Treat incremental retention as an absolute percentage-point improvement versus no campaign, not a relative reduction in churn or the predicted model score.

All monetary amounts use the dataset's monetary units.

`Campaign cost = 205 × 15 = 3,075`

`Incremental contribution = 20,361.10 × 6 × 40% × incremental retention`

`ROI = (Incremental contribution − campaign cost) / campaign cost`

| Scenario | Incremental retention | Campaign cost | Incremental contribution | Net benefit | ROI |
|---|---:|---:|---:|---:|---:|
| Low uplift | 2 percentage points | 3,075.00 | 977.33 | -2,097.67 | -68.22% |
| Base uplift | 5 percentage points | 3,075.00 | 2,443.33 | -631.67 | -20.54% |
| High uplift | 10 percentage points | 3,075.00 | 4,886.66 | 1,811.66 | 58.92% |

Break-even incremental retention is `3,075 / (20,361.10 × 6 × 40%)`, approximately **6.29 percentage points**. Sensitivity analysis varies cost per contacted customer from 5 to 25 and incremental retention from 2 to 12 percentage points.

## Business recommendations

1. Use the 205 higher-risk, higher-value records as a candidate pool for a controlled pilot, subject to current eligibility and data validation.
2. Investigate service experience and contract flexibility among short-tenure and month-to-month customers. Observed differences do not establish that changing a contract or adding a service will reduce churn.
3. Randomize eligible customers into treatment and control groups, define the retention observation window in advance, and assess sample size before launch. A pool of 205 may be insufficient to detect the required effect reliably.
4. Measure incremental retention, actual campaign cost, and contribution rather than comparing model scores alone. Scale only if measured incremental economics justify the program.

## Power BI report

| Page | Purpose |
|---|---|
| Churn Overview | Portfolio KPIs, contract and tenure patterns, and filters |
| Churn Patterns | Internet service, payment method, technical support, and online security comparisons |
| Customer Prioritization | Active customer segments and priority candidate details |
| Retention Scenarios | Scenario economics, break-even retention, and ROI sensitivity |

Use the locally opening report as the authoritative dashboard. Verify visual formats and filter states before exporting screenshots or PDF. In particular, ROI sensitivity cells must display percentages rather than rounded integers.

## Project organization

| Directory | Contents |
|---|---|
| `data/raw/` | Original source data |
| `data/processed/` | Cleaned data, predictions, segment exports, and scenario outputs |
| `sql/` | Import, validation, and business analysis queries |
| `notebooks/` | Exploratory analysis, modeling, and retention strategy notebooks |
| `models/` | Saved model pipeline and metadata |
| `dashboard/` | Power BI report and optional PDF export |
| `images/` | Analysis charts and dashboard screenshots |
| `report/` | Business summary and supporting documentation |

Key generated outputs include `active_customer_segments.csv`, `priority_customer_candidates.csv`, `customer_segment_summary.csv`, `customer_segment_by_split.csv`, `priority_customer_profile.csv`, `retention_roi_scenarios.csv`, `retention_roi_sensitivity.csv`, and `retention_scenario_assumptions.json`.

## Reproduction and handoff

1. Obtain the source data and place it in `data/raw/`.
2. Run the SQL import and analysis scripts using local database settings.
3. Run the exploratory notebook, followed by `notebooks/02_churn_model.ipynb` and `notebooks/03_retention_strategy.ipynb`. Update local file paths as needed.
4. Confirm the split assignments, model metadata, and exported tables before refreshing Power BI.
5. Open the working PBIX in Power BI Desktop and update its CSV source paths to the local `data/processed/` directory.

A clean-environment rerun and dependency manifest still need to be verified against the local project before public release. This README summarizes the recorded project results; it is not evidence of a new end-to-end rerun.

## Limitations

- This is a sample, cross-sectional dataset. The model does not estimate churn within a defined future time horizon.
- Exploratory analysis viewed the full dataset before splitting, so the test set was not untouched by all exploratory decisions.
- Risk scores indicate churn propensity, not responsiveness to retention treatment. No uplift model or causal treatment effect was estimated.
- Full-portfolio prioritization includes in-sample training scores and should be regenerated with an appropriate scoring design for operational use.
- Revenue, margin, duration, and retention-effect assumptions are illustrative. No campaign was run and no savings or incremental revenue were realized.
- Local paths, dependencies, dashboard refresh, and exported display formats require a final handoff check.
