/* 
Analysis of a bank's customers


This project aims to create a denormalized table containing a series of indicators (features) derived from 
tables available in a bank database, which represent the behaviors and financial activities of customers, 
using MySQL.

The database ("banca") consists of the following tables and columns:
    •	cliente: contains personal information about customers (columns: id_cliente, nome, cognome, data_nascita).
    •	conto: contains information about accounts held by customers (columns: id_conto, id_cliente, id_tipo_conto).
    •	tipo_conto: describes the different types of accounts available (columns: id_tipo_conto, desc_tipo_conto).
    •	tipo_transazione: contains the transaction types that can occur on accounts (columns: id_tipo_transazione, 
        desc_tipo_trans, segno).
    •	transazioni: contains details of transactions made by customers on various accounts (columns: data, 
        id_tipo_trans, importo, id_conto).

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


/* First, the database "banca" is set to be used by default. */

USE banca;


/* Before proceeding with the creation of indicators, all tables contained in the databes are visualized. */

SELECT * FROM cliente;
SELECT * FROM conto;
SELECT * FROM tipo_conto;
SELECT * FROM tipo_transazione;
SELECT * FROM transazioni;


/* 
Considering the structure of the tables, in order to apply the CASE function to obtain the different indicators 
based on specific conditions, it is necessary to apply a series of LEFT JOIN functions to combine data contained in
the single tables. 

In particular, the table "cliente" is first joined with the table "conto" by using the column "id_cliente".

Then, the column "id_conto" is used to join the table "transazioni", which is required to obtained all indicators 
on transactions. 

The table "tipo_conto" is not strictly necessary, as the table "conto" contains the information on account type 
("id_tipo_conto"), but it will be joined to use the column "desc_tipo_conto" as condition, making the code more
easily readable.

The table "tipo_transazione" will not be joined, as the condition to distinguish outgoing and incoming transactions 
can be obtained from the column "importo" in the table "transazioni" by considering negative and positive values. The
column "segno" in the table "tipo_transazione" could also be used as condition, but it is not assumed to improve the
code in terms of readability.

All indicators on accounts and transactions are calculated using the aggregation functions COUNT or SUM. The indicator 
on the customer age is calculated using the TIMESTAMPDIFF() function. To make sure that all indicators are calculated 
for each individual customer, the GROUP BY statement is used to group the results of aggregate functions by the column 
"id_cliente", referring to the customer IDs, and the column "età", referring to the calculated ages associated with each 
customer.

The results of the following SELECT query contain all indicators described above: 
*/


SELECT
cliente.id_cliente,
-- 1. Customer age
TIMESTAMPDIFF(year, cliente.data_nascita, CURRENT_DATE()) as età,
-- 2. Number of outgoing transactions on all accounts (1: 54)
count(CASE WHEN transazioni.importo < 0 THEN transazioni.importo ELSE null END) n_transazioni_uscita,
-- 3. Number of incoming transactions on all accounts (1: 7)
count(CASE WHEN transazioni.importo > 0 THEN transazioni.importo ELSE null END) n_transazioni_entrata,
-- 4. Total outgoing transacted amount on all accounts
sum(CASE WHEN transazioni.importo < 0 THEN transazioni.importo ELSE null END) tot_transato_uscita,
-- 5. Total incoming transacted amount on all accounts
sum(CASE WHEN transazioni.importo > 0 THEN transazioni.importo ELSE null END) tot_transato_entrata,
-- 6. Total number of accounts held
count(DISTINCT conto.id_conto) n_conti_tot,
-- 7. Number of accounts held by type 
count(DISTINCT CASE WHEN tipo_conto.desc_tipo_conto = 'Conto Base' THEN conto.id_conto ELSE null END) n_conti_base,
count(DISTINCT CASE WHEN tipo_conto.desc_tipo_conto = 'Conto Business' THEN conto.id_conto ELSE null END) n_conti_business,
count(DISTINCT CASE WHEN tipo_conto.desc_tipo_conto = 'Conto Privati' THEN conto.id_conto ELSE null END) n_conti_privati,
count(DISTINCT CASE WHEN tipo_conto.desc_tipo_conto = 'Conto Famiglie' THEN conto.id_conto ELSE null END) n_conti_famiglie,
-- 8. Number of outgoing transactions by account type
count(CASE WHEN (transazioni.importo < 0 AND tipo_conto.desc_tipo_conto = 'Conto Base') THEN transazioni.importo ELSE null END) n_transaz_uscita_base,
count(CASE WHEN (transazioni.importo < 0 AND tipo_conto.desc_tipo_conto = 'Conto Business') THEN transazioni.importo ELSE null END) n_transaz_uscita_business,
count(CASE WHEN (transazioni.importo < 0 AND tipo_conto.desc_tipo_conto = 'Conto Privati') THEN transazioni.importo ELSE null END) n_transaz_uscita_privati,
count(CASE WHEN (transazioni.importo < 0 AND tipo_conto.desc_tipo_conto = 'Conto Famiglie') THEN transazioni.importo ELSE null END) n_transaz_uscita_famiglie,
-- 9. Number of incoming transactions by account type 
count(CASE WHEN (transazioni.importo > 0 AND tipo_conto.desc_tipo_conto = 'Conto Base') THEN transazioni.importo ELSE null END) n_transaz_entrata_base,
count(CASE WHEN (transazioni.importo > 0 AND tipo_conto.desc_tipo_conto = 'Conto Business') THEN transazioni.importo ELSE null END) n_transaz_entrata_business,
count(CASE WHEN (transazioni.importo > 0 AND tipo_conto.desc_tipo_conto = 'Conto Privati') THEN transazioni.importo ELSE null END) n_transaz_entrata_privati,
count(CASE WHEN (transazioni.importo > 0 AND tipo_conto.desc_tipo_conto = 'Conto Famiglie') THEN transazioni.importo ELSE null END) n_transaz_entrata_famiglie,
-- 10. Outgoing transacted amount by account type
sum(CASE WHEN (transazioni.importo < 0 AND tipo_conto.desc_tipo_conto = 'Conto Base') THEN transazioni.importo ELSE null END) transato_uscita_base,
sum(CASE WHEN (transazioni.importo < 0 AND tipo_conto.desc_tipo_conto = 'Conto Business') THEN transazioni.importo ELSE null END) transato_uscita_business,
sum(CASE WHEN (transazioni.importo < 0 AND tipo_conto.desc_tipo_conto = 'Conto Privati') THEN transazioni.importo ELSE null END) transato_uscita_privati,
sum(CASE WHEN (transazioni.importo < 0 AND tipo_conto.desc_tipo_conto = 'Conto Famiglie') THEN transazioni.importo ELSE null END) transato_uscita_famiglie,
-- 11. Incoming transacted amount by account type
sum(CASE WHEN (transazioni.importo > 0 AND tipo_conto.desc_tipo_conto = 'Conto Base') THEN transazioni.importo ELSE null END) transato_entrata_base,
sum(CASE WHEN (transazioni.importo > 0 AND tipo_conto.desc_tipo_conto = 'Conto Business') THEN transazioni.importo ELSE null END) transato_entrata_business,
sum(CASE WHEN (transazioni.importo > 0 AND tipo_conto.desc_tipo_conto = 'Conto Privati') THEN transazioni.importo ELSE null END) transato_entrata_privati,
sum(CASE WHEN (transazioni.importo > 0 AND tipo_conto.desc_tipo_conto = 'Conto Famiglie') THEN transazioni.importo ELSE null END) transato_entrata_famiglie

FROM cliente
LEFT JOIN conto ON cliente.id_cliente = conto.id_cliente
LEFT JOIN transazioni ON conto.id_conto = transazioni.id_conto
LEFT JOIN tipo_conto ON conto.id_tipo_conto = tipo_conto.id_tipo_conto
GROUP BY 1,2;


/* 
The output of the query is a denormalized table with 27 features and 200 samples (corresponding to the number of 
customers in the bank database). This table can be used as input for the training of machine learning models aimed at
different kind of tasks, including prediction of customer behavior and preferences.
*/