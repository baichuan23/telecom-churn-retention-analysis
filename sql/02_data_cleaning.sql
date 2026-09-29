USE telecom_churn;

-- 1. 查找缺失或格式异常的在网时长、月费，
--    以及非空但格式异常的累计费用
SELECT
    customerID,
    tenure,
    MonthlyCharges,
    TotalCharges
FROM raw_customers
WHERE
    tenure IS NULL
    OR TRIM(tenure) = ''
    OR TRIM(tenure) NOT REGEXP '^[0-9]+$'

    OR MonthlyCharges IS NULL
    OR TRIM(MonthlyCharges) = ''
    OR TRIM(MonthlyCharges) NOT REGEXP '^[0-9]+([.][0-9]+)?$'

    OR (
        TotalCharges IS NOT NULL
        AND TRIM(TotalCharges) <> ''
        AND TRIM(TotalCharges) NOT REGEXP '^[0-9]+([.][0-9]+)?$'
    );
    
    -- 2. 查看三个核心分类字段的取值和人数
SELECT
    'Contract' AS field_name,
    TRIM(Contract) AS category,
    COUNT(*) AS customer_count
FROM telecom_churn.raw_customers
GROUP BY TRIM(Contract)

UNION ALL

SELECT
    'InternetService' AS field_name,
    TRIM(InternetService) AS category,
    COUNT(*) AS customer_count
FROM telecom_churn.raw_customers
GROUP BY TRIM(InternetService)

UNION ALL

SELECT
    'PaymentMethod' AS field_name,
    TRIM(PaymentMethod) AS category,
    COUNT(*) AS customer_count
FROM telecom_churn.raw_customers
GROUP BY TRIM(PaymentMethod)

ORDER BY field_name, customer_count DESC;

-- 3. 预览数值转换，重点检查累计费用缺失的客户
SELECT
    customerID,
    CAST(TRIM(tenure) AS UNSIGNED) AS tenure_months,
    CAST(TRIM(MonthlyCharges) AS DECIMAL(10, 2)) AS monthly_charges,
    CAST(
        NULLIF(TRIM(TotalCharges), '')
        AS DECIMAL(10, 2)
    ) AS total_charges
FROM telecom_churn.raw_customers
WHERE TotalCharges IS NULL
   OR TRIM(TotalCharges) = '';
   
   -- 4. 根据原始表创建清洗后的客户表
CREATE TABLE telecom_churn.clean_customers AS
SELECT
    TRIM(customerID) AS customer_id,
    TRIM(gender) AS gender,
    TRIM(SeniorCitizen) AS senior_citizen,
    TRIM(Partner) AS partner,
    TRIM(Dependents) AS dependents,

    CAST(TRIM(tenure) AS UNSIGNED) AS tenure_months,

    TRIM(PhoneService) AS phone_service,
    TRIM(MultipleLines) AS multiple_lines,
    TRIM(InternetService) AS internet_service,
    TRIM(OnlineSecurity) AS online_security,
    TRIM(OnlineBackup) AS online_backup,
    TRIM(DeviceProtection) AS device_protection,
    TRIM(TechSupport) AS tech_support,
    TRIM(StreamingTV) AS streaming_tv,
    TRIM(StreamingMovies) AS streaming_movies,
    TRIM(Contract) AS contract,
    TRIM(PaperlessBilling) AS paperless_billing,
    TRIM(PaymentMethod) AS payment_method,

    CAST(TRIM(MonthlyCharges) AS DECIMAL(10, 2))
        AS monthly_charges,

    CAST(NULLIF(TRIM(TotalCharges), '') AS DECIMAL(10, 2))
        AS total_charges,

    TRIM(Churn) AS churn

FROM telecom_churn.raw_customers;

-- 5. 验证清洗后的记录数、唯一客户数和费用缺失数
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(
        CASE WHEN total_charges IS NULL THEN 1 ELSE 0 END
    ) AS missing_total_charges
FROM telecom_churn.clean_customers;

-- 6. 检查其余分类字段的取值
WITH category_values AS (
    SELECT 'gender' AS field_name, gender AS category
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'senior_citizen', senior_citizen
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'partner', partner
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'dependents', dependents
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'phone_service', phone_service
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'multiple_lines', multiple_lines
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'online_security', online_security
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'online_backup', online_backup
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'device_protection', device_protection
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'tech_support', tech_support
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'streaming_tv', streaming_tv
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'streaming_movies', streaming_movies
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'paperless_billing', paperless_billing
    FROM telecom_churn.clean_customers
    UNION ALL
    SELECT 'churn', churn
    FROM telecom_churn.clean_customers
)
SELECT
    field_name,
    category,
    COUNT(*) AS customer_count
FROM category_values
GROUP BY field_name, category
ORDER BY field_name, category;

-- 7. 创建客户属性表
CREATE TABLE telecom_churn.customer_profile AS
SELECT
    customer_id,
    gender,
    CAST(senior_citizen AS UNSIGNED) AS senior_citizen,
    partner,
    dependents,
    tenure_months
FROM telecom_churn.clean_customers;

-- 8. 将客户 ID 设置为主键
ALTER TABLE telecom_churn.customer_profile
ADD PRIMARY KEY (customer_id);

-- 9. 查看表结构
DESCRIBE telecom_churn.customer_profile;

-- 10. 创建客户服务表
CREATE TABLE telecom_churn.customer_services AS
SELECT
    customer_id,
    phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies
FROM telecom_churn.clean_customers;

-- 11. 将客户 ID 设置为主键
ALTER TABLE telecom_churn.customer_services
ADD PRIMARY KEY (customer_id);

-- 12. 验证客户服务表
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM telecom_churn.customer_services;