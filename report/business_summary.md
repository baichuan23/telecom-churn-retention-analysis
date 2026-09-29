# From Churn Prediction to Retention Strategy
## Business summary

### Decision recommendation

Use the identified higher-risk, higher-monthly-value segment as a starting point for a controlled retention pilot. Validate current eligibility, assess experimental sample size, and measure incremental retention before expanding the campaign. Under the illustrative assumptions, retention must improve by approximately **6.29 percentage points versus no campaign** to break even.

### What the analysis found

The sample contains **7,043 customers**, of whom **1,869 (26.54%)** are labeled as churned. Churn is concentrated in several observable groups:

| Customer group | Observed churn rate | Business question to investigate |
|---|---:|---|
| Customers with 0–12 months of tenure | 47.44% | Are onboarding or early service experiences contributing to dissatisfaction? |
| Month-to-month contracts | 42.71% | What prevents customers from maintaining a longer relationship? |
| Fiber optic service | 41.89% | Do service quality, expectations, or pricing explain the higher observed churn? |
| Electronic check payment | 45.29% | Does this group differ in contract, tenure, or service characteristics? |

These groups overlap. Their rates cannot be added together, and the associations do not establish that changing a payment method, contract, or service will prevent churn.

### How customers were prioritized

A random forest classifier achieved **0.8422 ROC-AUC** and **0.6583 average precision** on the held-out test split. At the validation-selected threshold of **0.35**, test precision was **55.97%** and recall was **68.98%**. This supports risk ranking while leaving substantial false-positive and false-negative uncertainty.

Among the **5,174 non-churned customers**, the prioritization rule combined a model score of at least 0.35 with membership in the top 20% by monthly charges. It identified **205 priority candidates**:

- **3.96%** of active customers.
- **6.42%** of active monthly charges.
- **20,361.10** in combined monthly charges, or approximately **99.32 per customer**.

Monthly charges are a value proxy, not lifetime value. The segment is a candidate pool, not a count of customers who will churn or respond to an offer. Its scores include 108 training, 53 validation, and 44 test records; training-record scores are in-sample.

### Would a campaign pay for itself?

The scenarios assume contacting all 205 candidates at a total cost of **15 per contacted customer**, including 5 in contact cost and 10 in offer cost charged to every contacted customer. Total campaign cost is **3,075**. The contribution calculation assumes six months of retained charges, a 40% contribution margin, and a uniform incremental retention effect across candidates. Monetary amounts use the dataset's units.

| Incremental retention versus no campaign | Incremental contribution | Net benefit | ROI |
|---|---:|---:|---:|
| 2 percentage points | 977.33 | -2,097.67 | -68.22% |
| 5 percentage points | 2,443.33 | -631.67 | -20.54% |
| 10 percentage points | 4,886.66 | 1,811.66 | 58.92% |

The break-even improvement is approximately **6.29 percentage points**. The 5-point scenario loses money despite improving retention. The 10-point scenario is profitable under the assumptions, but its effect has not been observed or validated.

Calculation: `Incremental contribution = 20,361.10 × 6 × 0.40 × incremental retention`; `ROI = (incremental contribution − 3,075) / 3,075`.

### Proposed pilot and decision criteria

1. **Validate the candidate pool.** Check current customer status, contact eligibility, data freshness, and suitability of the proposed intervention. For operational scoring, address the inclusion of in-sample model scores.
2. **Test a specific intervention.** Investigate service issues and customer needs before defining an offer. Select a consistent treatment that can be evaluated, rather than assuming every higher-risk customer needs a discount.
3. **Design a randomized comparison.** Define the observation window, retention outcome, treatment/control allocation, minimum detectable effect, and required sample size in advance. The 205-customer pool may not provide sufficient statistical power; it is not automatically an adequately sized experiment.
4. **Measure incremental economics.** Compare retention between treatment and control groups, report uncertainty, and use actual contact costs, offer redemption costs, retained contribution, and treatment reach. A pilot holding out controls will have different expenditure from the all-205-contacted scenario above.
5. **Expand only with evidence.** Recalculate break-even using realized costs and margins. Require sufficiently convincing evidence of positive incremental net contribution; high churn risk alone does not justify rollout.

### Scope and limitations

This is a portfolio analysis of a sample, cross-sectional dataset. It does not predict churn within a specified future time horizon. Exploratory analysis viewed the full dataset before splitting, so the test set was not untouched by every exploratory decision. The model estimates churn propensity, not the causal effect of retention treatment. No campaign was executed, and no retained revenue, savings, or ROI were realized. The four-page Power BI report communicates descriptive patterns, prioritization, and illustrative economics; it is not evidence of operational deployment.
