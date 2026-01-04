# Feature Engineering of a bank's customers with MySQL

This project builds a **single, denormalized dataset** of a bank's customers from a relational banking database using **MySQL**. The goal is to obtain behavioral and financial activity indicators (features) from multiple tables including data on customers, their accounts, and their transactions. The resulting output can be used for advanced data analytics and machine learning tasks. The full project is implemented in the [`customer_feature_engineering.sql`](https://github.com/lgucrl/sql-bank-customer-feature-engineering/blob/main/customer_feature_engineering.sql) file.

---

## Database

The project uses a MySQL database (**`bank`**), contained in the [`banking_db.sql`](https://github.com/lgucrl/sql-bank-customer-feature-engineering/blob/main/banking_db.sql) file, which is composed of five tables:

- **`customer`**: customer personal information  
  - Columns: `customer_id`, `customer_name`, `customer_surname`, `customer_birth_date`
- **`account`**: accounts owned by customers  
  - Columns: `account_id`, `customer_id`, `account_type_id`
- **`account_type`**: reference table of account types
  - Columns: `account_type_id`, `account_type_desc` (Basic, Business, Private, Family)
- **`transaction_type`**: reference table of transaction types
  - Columns: `transaction_type_id`, `transaction_type_desc`, `transaction_sign`
- **`transactions`**: transactions made by individual accounts
  - Columns: `transaction_date`, `transaction_type_id`, `amount`, `account_id`

For this project transactions are classified as **outgoing** when `amount < 0` and **incoming** when `amount > 0`. The result of the project is a **denormalized table with 27 features** and **200 rows** (one per customer), which is not stored as a physical or temporary table, but is produced as the result of a single `SELECT` query.

---

## Objectives and Methods

1. **Exploring the database schema**  
   All tables in the `bank` database are inspected to understand fields and relationships before feature engineering.

2. **Creation of customer-level features**  
   The query output is designed to aggregate all account and transaction information at the `customer_id` level using `GROUP BY`.

3. **Obtaining demographic indicators**  
   **Customer age** is calculated with `TIMESTAMPDIFF(year, customer_birth_date, CURRENT_DATE())`.

4. **Obtaining global transaction indicators**  
   Overall **counts** and **total amounts** for incoming vs outgoing transactions are calculated across all accounts using `COUNT` / `SUM` with `CASE WHEN`.

5. **Obtaining account ownership indicators**  
   The **total number of accounts** and **counts by account type** (including Basic, Business, Private, Family) are computed using `COUNT(DISTINCT ...)` with conditional `CASE` logic.

6. **Obtaining transaction indicators by account type**  
   Per-account-type metrics are obtained for:
   - number of **incoming** transactions
   - number of **outgoing** transactions
   - **incoming** total amount
   - **outgoing** total amount   
   
   The metrics are implemented using conditional aggregation with `CASE` and joins to `account_type` to improve readability.

7. **Combining data across tables**  
   `customer`, `account`, `transactions` and `account_type` tables are joined using `LEFT JOIN`, so ensuring that customers without transactions/accounts remain represented.
   
