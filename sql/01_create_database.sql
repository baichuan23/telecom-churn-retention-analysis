-- 1. 检查数据库服务器版本
SELECT VERSION() AS mysql_version;

-- 2. 创建项目数据库
CREATE DATABASE IF NOT EXISTS telecom_churn
    CHARACTER SET utf8mb4;

-- 3. 将它设为当前使用的数据库
USE telecom_churn;

-- 4. 确认当前数据库
SELECT DATABASE() AS current_database;

-- 5. 创建原始数据表，保留 CSV 中的原始字段
CREATE TABLE telecom_churn.raw_customers (
    customerID VARCHAR(255),
    gender VARCHAR(255),
    SeniorCitizen VARCHAR(255),
    Partner VARCHAR(255),
    Dependents VARCHAR(255),
    tenure VARCHAR(255),
    PhoneService VARCHAR(255),
    MultipleLines VARCHAR(255),
    InternetService VARCHAR(255),
    OnlineSecurity VARCHAR(255),
    OnlineBackup VARCHAR(255),
    DeviceProtection VARCHAR(255),
    TechSupport VARCHAR(255),
    StreamingTV VARCHAR(255),
    StreamingMovies VARCHAR(255),
    Contract VARCHAR(255),
    PaperlessBilling VARCHAR(255),
    PaymentMethod VARCHAR(255),
    MonthlyCharges VARCHAR(255),
    TotalCharges VARCHAR(255),
    Churn VARCHAR(255)
);

-- 6. 检查表结构
DESCRIBE telecom_churn.raw_customers;

-- 检查失败的导入是否已写入数据
SELECT COUNT(*) AS imported_rows
FROM telecom_churn.raw_customers;

SELECT COUNT(*) AS imported_rows
FROM telecom_churn.raw_customers;



-- 7. 检查记录数、唯一客户数和缺失客户 ID
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT NULLIF(TRIM(customerID), '')) AS unique_customers,
    SUM(
        CASE
            WHEN customerID IS NULL OR TRIM(customerID) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_customer_ids
FROM telecom_churn.raw_customers;

-- 8. 检查流失标签及对应客户数量
SELECT
    Churn,
    COUNT(*) AS customer_count
FROM telecom_churn.raw_customers
GROUP BY Churn;

-- 9. 查找历史累计费用缺失的客户
SELECT
    customerID,
    tenure,
    MonthlyCharges,
    TotalCharges,
    Churn
FROM telecom_churn.raw_customers
WHERE TotalCharges IS NULL
   OR TRIM(TotalCharges) = '';

