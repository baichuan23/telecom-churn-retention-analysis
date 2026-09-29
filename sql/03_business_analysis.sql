USE telecom_churn;

-- Q1. 样本的客户规模、流失率和平均月费是多少？
SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
    ) AS churned_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct,

    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges

FROM customer_master;

-- Q2. 不同合同类型的客户规模和流失情况如何？
SELECT
    contract,
    COUNT(*) AS total_customers,

    SUM(
        CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
    ) AS churned_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct,

    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges

FROM telecom_churn.customer_master

GROUP BY contract
ORDER BY churn_rate_pct DESC;

-- Q3. 不同在网时长群体的流失情况如何？
WITH tenure_groups AS (
    SELECT
        customer_id,
        churn,
        monthly_charges,

        CASE
            WHEN tenure_months <= 12 THEN '01: 0-12 months'
            WHEN tenure_months <= 24 THEN '02: 13-24 months'
            WHEN tenure_months <= 48 THEN '03: 25-48 months'
            ELSE '04: 49+ months'
        END AS tenure_group

    FROM telecom_churn.customer_master
)

SELECT
    tenure_group,
    COUNT(*) AS total_customers,

    SUM(
        CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
    ) AS churned_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct,

    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges

FROM tenure_groups
GROUP BY tenure_group
ORDER BY tenure_group;

-- Q4. 合同与在网时长组合下，哪些群体流失更突出？
WITH customer_groups AS (
    SELECT
        contract,
        churn,
        CASE
            WHEN tenure_months <= 12 THEN '01: 0-12 months'
            WHEN tenure_months <= 24 THEN '02: 13-24 months'
            WHEN tenure_months <= 48 THEN '03: 25-48 months'
            ELSE '04: 49+ months'
        END AS tenure_group
    FROM telecom_churn.customer_master
)

SELECT
    tenure_group,
    contract,
    COUNT(*) AS total_customers,

    SUM(
        CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
    ) AS churned_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM customer_groups
GROUP BY tenure_group, contract
ORDER BY tenure_group, churn_rate_pct DESC;

-- Q5. 不同网络服务类型的客户规模、流失和月费如何？
SELECT
    internet_service,
    COUNT(*) AS total_customers,

    SUM(
        CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
    ) AS churned_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct,

    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges

FROM telecom_churn.customer_master
GROUP BY internet_service
ORDER BY churn_rate_pct DESC;

-- Q6. 同一合同类型内，不同网络服务的流失率有何差异？
SELECT
    contract,
    internet_service,
    COUNT(*) AS total_customers,

    SUM(
        CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
    ) AS churned_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct,

    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges

FROM telecom_churn.customer_master

GROUP BY contract, internet_service
ORDER BY contract, churn_rate_pct DESC;

-- Q7. 不同支付方式的客户流失情况如何？
SELECT
    payment_method,
    COUNT(*) AS total_customers,

    SUM(
        CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
    ) AS churned_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct,

    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges

FROM telecom_churn.customer_master
GROUP BY payment_method
ORDER BY churn_rate_pct DESC;

-- Q8. 有网络服务的客户中，技术支持与流失有何关系？
SELECT
    internet_service,
    tech_support,
    COUNT(*) AS total_customers,

    SUM(
        CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
    ) AS churned_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM telecom_churn.customer_master

WHERE internet_service IN ('DSL', 'Fiber optic')

GROUP BY internet_service, tech_support
ORDER BY internet_service, churn_rate_pct DESC;

-- Q9. 有网络服务的客户中，网络安全服务与流失有何关系？
SELECT
    internet_service,
    online_security,
    COUNT(*) AS total_customers,

    SUM(
        CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
    ) AS churned_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM telecom_churn.customer_master

WHERE internet_service IN ('DSL', 'Fiber optic')

GROUP BY internet_service, online_security
ORDER BY internet_service, churn_rate_pct DESC;

-- Q10. 不同月费区间的客户流失情况如何？
WITH charge_groups AS (
    SELECT
        churn,
        monthly_charges,
        CASE
            WHEN monthly_charges < 35 THEN '01: Below 35'
            WHEN monthly_charges < 70 THEN '02: 35 to below 70'
            WHEN monthly_charges < 100 THEN '03: 70 to below 100'
            ELSE '04: 100 and above'
        END AS monthly_charge_group
    FROM telecom_churn.customer_master
)

SELECT
    monthly_charge_group,
    COUNT(*) AS total_customers,

    SUM(
        CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
    ) AS churned_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS churn_rate_pct,

    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges

FROM charge_groups
GROUP BY monthly_charge_group
ORDER BY monthly_charge_group;

-- Q11. 未流失的高月费客户主要集中在哪些群体？
SELECT
    contract,
    internet_service,
    COUNT(*) AS active_customers,

    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges,

    ROUND(SUM(monthly_charges), 2) AS monthly_charge_total

FROM telecom_churn.customer_master

WHERE churn = 'No'
  AND monthly_charges >= 70

GROUP BY contract, internet_service

HAVING COUNT(*) >= 50

ORDER BY monthly_charge_total DESC;

-- Q12. 未流失的按月光纤客户中，
-- 哪些客户的月费高于该群体平均月费？
SELECT
    customer_id,
    tenure_months,
    monthly_charges,
    tech_support,
    online_security,
    payment_method

FROM telecom_churn.customer_master

WHERE churn = 'No'
  AND contract = 'Month-to-month'
  AND internet_service = 'Fiber optic'

  AND monthly_charges > (
      SELECT AVG(monthly_charges)
      FROM telecom_churn.customer_master
      WHERE churn = 'No'
        AND contract = 'Month-to-month'
        AND internet_service = 'Fiber optic'
  )

ORDER BY monthly_charges DESC, customer_id
LIMIT 20;

-- Q13. 每个合同与网络组合中，月费最高的3位未流失客户是谁？
WITH ranked_customers AS (
    SELECT
        customer_id,
        contract,
        internet_service,
        tenure_months,
        monthly_charges,

        ROW_NUMBER() OVER (
            PARTITION BY contract, internet_service
            ORDER BY monthly_charges DESC, customer_id
        ) AS monthly_charge_rank

    FROM telecom_churn.customer_master
    WHERE churn = 'No'
)

SELECT
    contract,
    internet_service,
    customer_id,
    tenure_months,
    monthly_charges,
    monthly_charge_rank

FROM ranked_customers
WHERE monthly_charge_rank <= 3

ORDER BY contract, internet_service, monthly_charge_rank;

-- Q14. 未流失客户中，月费最高的前20%贡献了多少月费？
WITH ranked_active AS (
    SELECT
        customer_id,
        monthly_charges,

        ROW_NUMBER() OVER (
            ORDER BY monthly_charges DESC, customer_id
        ) AS charge_rank,

        COUNT(*) OVER () AS total_active_customers

    FROM telecom_churn.customer_master
    WHERE churn = 'No'
),

customer_tiers AS (
    SELECT
        customer_id,
        monthly_charges,

        CASE
            WHEN charge_rank <= CEIL(total_active_customers * 0.20)
                THEN 'Top 20%'
            ELSE 'Remaining customers'
        END AS charge_tier

    FROM ranked_active
)

SELECT
    charge_tier,
    COUNT(*) AS customer_count,

    ROUND(SUM(monthly_charges), 2) AS monthly_charge_total,

    ROUND(
        100.0 * SUM(monthly_charges)
        / SUM(SUM(monthly_charges)) OVER (),
        2
    ) AS monthly_charge_share_pct

FROM customer_tiers
GROUP BY charge_tier
ORDER BY monthly_charge_total DESC;

-- Q15. 至少100人的合同与时长组合，历史流失率如何排名？
WITH customer_groups AS (
    SELECT
        contract,
        churn,
        CASE
            WHEN tenure_months <= 12 THEN '01: 0-12 months'
            WHEN tenure_months <= 24 THEN '02: 13-24 months'
            WHEN tenure_months <= 48 THEN '03: 25-48 months'
            ELSE '04: 49+ months'
        END AS tenure_group
    FROM telecom_churn.customer_master
),

group_metrics AS (
    SELECT
        contract,
        tenure_group,
        COUNT(*) AS total_customers,

        SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) AS churned_customers,

        1.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*) AS churn_rate

    FROM customer_groups
    GROUP BY contract, tenure_group
    HAVING COUNT(*) >= 100
)

SELECT
    contract,
    tenure_group,
    total_customers,
    churned_customers,
    ROUND(100.0 * churn_rate, 2) AS churn_rate_pct,

    RANK() OVER (
        ORDER BY churn_rate DESC
    ) AS historical_churn_rank

FROM group_metrics
ORDER BY historical_churn_rank, contract, tenure_group;

-- Q16. 不同合同与时长组合中，未流失客户规模有多大？
WITH customer_groups AS (
    SELECT
        contract,
        churn,
        monthly_charges,
        CASE
            WHEN tenure_months <= 12 THEN '01: 0-12 months'
            WHEN tenure_months <= 24 THEN '02: 13-24 months'
            WHEN tenure_months <= 48 THEN '03: 25-48 months'
            ELSE '04: 49+ months'
        END AS tenure_group
    FROM telecom_churn.customer_master
)

SELECT
    contract,
    tenure_group,
    COUNT(*) AS total_customers,

    ROUND(
        100.0 * SUM(
            CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS historical_churn_rate_pct,

    SUM(
        CASE WHEN churn = 'No' THEN 1 ELSE 0 END
    ) AS active_customers,

    ROUND(
        SUM(
            CASE WHEN churn = 'No'
                 THEN monthly_charges
                 ELSE 0
            END
        ),
        2
    ) AS active_monthly_charge_total

FROM customer_groups
GROUP BY contract, tenure_group
HAVING COUNT(*) >= 100
ORDER BY historical_churn_rate_pct DESC;

-- Q17. 未流失客户中，三个关注特征如何重叠？
WITH customer_flags AS (
    SELECT
        customer_id,
        monthly_charges,

        CASE WHEN contract = 'Month-to-month'
             THEN 1 ELSE 0 END AS is_month_to_month,

        CASE WHEN tenure_months <= 12
             THEN 1 ELSE 0 END AS is_short_tenure,

        CASE WHEN internet_service = 'Fiber optic'
             THEN 1 ELSE 0 END AS is_fiber

    FROM telecom_churn.customer_master
    WHERE churn = 'No'
)

SELECT
    is_month_to_month,
    is_short_tenure,
    is_fiber,
    COUNT(*) AS active_customers,

    ROUND(AVG(monthly_charges), 2) AS avg_monthly_charges,

    ROUND(SUM(monthly_charges), 2) AS monthly_charge_total

FROM customer_flags

GROUP BY
    is_month_to_month,
    is_short_tenure,
    is_fiber

ORDER BY
    is_month_to_month DESC,
    is_short_tenure DESC,
    is_fiber DESC;