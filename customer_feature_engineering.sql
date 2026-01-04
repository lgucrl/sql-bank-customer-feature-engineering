/* 
Analysis of a bank's customers


This project aims to create a denormalized table containing a series of indicators (features) derived from 
tables available in a bank database, which represent the behaviors and financial activities of customers, 
using MySQL.

The database ("bank") consists of the following tables and columns:
    •	customer: contains personal information about customers (columns: customer_id, customer_name, customer_surname, 
        customer_birth_date).
    •	account: contains information about accounts held by customers (columns: account_id, customer_id, account_type_id).
    •	account_type: describes the different types of accounts available (columns: account_type_id, account_type_desc).
    •	transaction_type: contains the transaction types that can occur on accounts (columns: transaction_type_id, 
        transaction_type_desc, transaction_sign).
    •	transactions: contains details of transactions made by customers on various accounts (columns: transaction_date, 
        transaction_type_id, amount, account_id).

Specifically, the indicators will be obtained for each individual customer and will include:
    A.	Basic indicators:
        1.	Customer age.
    B.	Indicators on transactions:
        2.	Number of outgoing transactions on all accounts.
        3.	Number of incoming transactions on all accounts.
        4.	Total outgoing transacted amount on all accounts.
        5.	Total incoming transacted amount on all accounts.
    C.	Indicators on accounts:
        6.	Total number of accounts held.
        7.	Number of accounts held by type (one indicator per account type).
    D.	Indicators on transactions by account type:
        8.	Number of outgoing transactions by account type (one indicator per account type).
        9.	Number of incoming transactions by account type (one indicator per account type).
        10.	Outgoing transacted amount by account type (one indicator per account type).
        11.	Incoming transacted amount by account type (one indicator per account type).


The output will not be a physical or a temporary table but the result of a unique SELECT query, by using a combination 
of CASE and multiple JOIN statements.
 */


/* First, the "bank" database is set to be used by default. */

USE bank;


/* Before proceeding with the creation of indicators, all tables contained in the databes are visualized. */

SELECT * FROM customer;
SELECT * FROM account;
SELECT * FROM account_type;
SELECT * FROM transaction_type;
SELECT * FROM transactions;


/* 
Considering the structure of the tables, in order to apply the CASE function to obtain the different indicators 
based on specific conditions, it is necessary to apply a series of LEFT JOIN functions to combine data contained in
the single tables. 

In particular, the "customer" table is first joined with the "account" table by using the "customer_id" column.

Then, the "account_id" column is used to join the "transactions" table, which is required to obtained all indicators 
on transactions. 

The "account_type" table is not strictly necessary, as the "account" table contains the information on account type 
("account_type_id"), but it will be joined to use the "account_type_desc" column as condition, making the code more
easily readable.

The "transaction_type" table will not be joined, as the condition to distinguish outgoing and incoming transactions 
can be obtained from the "amount" column in the "transactions" table by considering negative and positive values. The
"transaction_sign" column in the "transaction_type" table could also be used as condition, but it is not assumed to improve 
the code in terms of readability.

All indicators on accounts and transactions are calculated using the aggregation functions COUNT or SUM. The indicator 
on the customer age is calculated using the TIMESTAMPDIFF() function. To make sure that all indicators are calculated 
for each individual customer, the GROUP BY statement is used to group the results of aggregate functions by the "customer_id"
column, referring to the customer IDs, and the "age" column, referring to the calculated ages associated with each 
customer.

The results of the following SELECT query contain all indicators described above: 
*/


SELECT
customer.customer_id,
-- 1. Customer age
TIMESTAMPDIFF(year, customer.customer_birth_date, CURRENT_DATE()) as age,
-- 2. Number of outgoing transactions on all accounts
count(CASE WHEN transactions.amount < 0 THEN transactions.amount ELSE null END) n_outgoing_transactions,
-- 3. Number of incoming transactions on all accounts
count(CASE WHEN transactions.amount > 0 THEN transactions.amount ELSE null END) n_incoming_transactions,
-- 4. Total outgoing transacted amount on all accounts
sum(CASE WHEN transactions.amount < 0 THEN transactions.amount ELSE null END) tot_outgoing_transacted,
-- 5. Total incoming transacted amount on all accounts
sum(CASE WHEN transactions.amount > 0 THEN transactions.amount ELSE null END) tot_incoming_transacted,
-- 6. Total number of accounts held
count(DISTINCT account.account_id) tot_n_accounts,
-- 7. Number of accounts held by type 
count(DISTINCT CASE WHEN account_type.account_type_desc = 'Basic account' THEN account.account_id ELSE null END) n_basic_accounts,
count(DISTINCT CASE WHEN account_type.account_type_desc = 'Business account' THEN account.account_id ELSE null END) n_business_accounts,
count(DISTINCT CASE WHEN account_type.account_type_desc = 'Private account' THEN account.account_id ELSE null END) n_private_accounts,
count(DISTINCT CASE WHEN account_type.account_type_desc = 'Family account' THEN account.account_id ELSE null END) n_family_accounts,
-- 8. Number of outgoing transactions by account type
count(CASE WHEN (transactions.amount < 0 AND account_type.account_type_desc = 'Basic account') THEN transactions.amount ELSE null END) n_outgoing_transactions_basic,
count(CASE WHEN (transactions.amount < 0 AND account_type.account_type_desc = 'Business account') THEN transactions.amount ELSE null END) n_outgoing_transactions_business,
count(CASE WHEN (transactions.amount < 0 AND account_type.account_type_desc = 'Private account') THEN transactions.amount ELSE null END) n_outgoing_transactions_private,
count(CASE WHEN (transactions.amount < 0 AND account_type.account_type_desc = 'Family account') THEN transactions.amount ELSE null END) n_outgoing_transactions_family,
-- 9. Number of incoming transactions by account type 
count(CASE WHEN (transactions.amount > 0 AND account_type.account_type_desc = 'Basic account') THEN transactions.amount ELSE null END) n_incoming_transactions_basic,
count(CASE WHEN (transactions.amount > 0 AND account_type.account_type_desc = 'Business account') THEN transactions.amount ELSE null END) n_incoming_transactions_business,
count(CASE WHEN (transactions.amount > 0 AND account_type.account_type_desc = 'Private account') THEN transactions.amount ELSE null END) n_incoming_transactions_private,
count(CASE WHEN (transactions.amount > 0 AND account_type.account_type_desc = 'Family account') THEN transactions.amount ELSE null END) n_incoming_transactions_family,
-- 10. Outgoing transacted amount by account type
sum(CASE WHEN (transactions.amount < 0 AND account_type.account_type_desc = 'Basic account') THEN transactions.amount ELSE null END) outgoing_transacted_basic,
sum(CASE WHEN (transactions.amount < 0 AND account_type.account_type_desc = 'Business account') THEN transactions.amount ELSE null END) outgoing_transacted_business,
sum(CASE WHEN (transactions.amount < 0 AND account_type.account_type_desc = 'Private account') THEN transactions.amount ELSE null END) outgoing_transacted_private,
sum(CASE WHEN (transactions.amount < 0 AND account_type.account_type_desc = 'Family account') THEN transactions.amount ELSE null END) outgoing_transacted_family,
-- 11. Incoming transacted amount by account type
sum(CASE WHEN (transactions.amount > 0 AND account_type.account_type_desc = 'Basic account') THEN transactions.amount ELSE null END) incoming_transacted_basic,
sum(CASE WHEN (transactions.amount > 0 AND account_type.account_type_desc = 'Business account') THEN transactions.amount ELSE null END) incoming_transacted_business,
sum(CASE WHEN (transactions.amount > 0 AND account_type.account_type_desc = 'Private account') THEN transactions.amount ELSE null END) incoming_transacted_private,
sum(CASE WHEN (transactions.amount > 0 AND account_type.account_type_desc = 'Family account') THEN transactions.amount ELSE null END) incoming_transacted_family

FROM customer
LEFT JOIN account ON customer.customer_id = account.customer_id
LEFT JOIN transactions ON account.account_id = transactions.account_id
LEFT JOIN account_type ON account.account_type_id = account_type.account_type_id
GROUP BY 1,2;


/* 
The output of the query is a denormalized table with 27 features and 200 samples (corresponding to the number of 
customers in the bank database). This table can be used as input for the training of machine learning models aimed at
different kind of tasks, including prediction of customer behavior and preferences.
*/
