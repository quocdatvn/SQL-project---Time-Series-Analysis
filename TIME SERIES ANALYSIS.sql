/*
--TIME SERIES ANALYSIS--

-- Data set: Paytm
-- Description about data: Paytm is an Indian multinational financial technology company. It specializes in digital payment system, e-commerce and financial services. Paytm wallet is a secure and RBI (Reserve Bank of India)-approved digital/mobile wallet that provides a myriad of financial features to fulfill every consumer’s payment needs. Paytm wallet can be topped up through UPI (Unified Payments Interface), internet banking, or credit/debit cards. Users can also transfer money from a Paytm wallet to recipient’s bank account or their own Paytm wallet. -- 
-- Below is a small database of payment transactions from 2019 to 2020 of Paytm Wallet. The database includes 6 tables:
-- fact_transaction: Store information of all types of transactions: Payments, Top-up, Transfers, Withdrawals--
-- dim_scenario: Detailed description of transaction types
-- dim_payment_channel: Detailed description of payment methods
-- dim_platform: Detailed description of payment devices
-- dim_status: Detailed description of the results of the transaction

-- Link download dataset: https://drive.google.com/drive/folders/1zLCSSH4vpw-xVsHXKNJFGniCsJ4M1xjT?usp=sharing

--Task: Select only these sub-categories in the list (Electricity, Internet and Water), you need to calculate the number of successful paying customers for each month (from 2019 to 2020). Then find the percentage change from the first month (Jan 2019) for each subsequent month.--
-- Skills used: Joins, CTE, Sub Queries, Aggregate Functions, Converting Data Types
*/
with sum_tab as (
      select year(transaction_time) as year 
      , month(transaction_time) as month
      , count (distinct customer_id) as number_customer
      , (SELECT COUNT (DISTINCT customer_id) FROM dbo.fact_transaction_2019
          left join dbo.dim_scenario
          on dbo.fact_transaction_2019.scenario_id=dbo.dim_scenario.scenario_id
          WHERE category = 'Billing' AND status_id = 1  AND YEAR (transaction_time) = 2019 AND MONTH (transaction_time) = 1
          AND sub_category IN ('Electricity', 'Internet', 'Water')) AS starting_point
      from dbo.fact_transaction_2019
      left join dbo.dim_scenario
      on dbo.fact_transaction_2019.scenario_id=dbo.dim_scenario.scenario_id
      where category='billing' and status_id=1 and sub_category in ('electricity','internet','water')
      group by year(transaction_time), month(transaction_time)
    UNION
      select year(transaction_time) as year 
      , month(transaction_time) as month
      , count (distinct customer_id)  as number_customer
      , (SELECT COUNT (DISTINCT customer_id) FROM dbo.fact_transaction_2019
          left join dbo.dim_scenario
          on dbo.fact_transaction_2019.scenario_id=dbo.dim_scenario.scenario_id
          WHERE category = 'Billing' AND status_id = 1  AND YEAR (transaction_time) = 2019 AND MONTH (transaction_time) = 1
          AND sub_category IN ('Electricity', 'Internet', 'Water')) AS starting_point
      from dbo.fact_transaction_2020
      left join dbo.dim_scenario
      on dbo.fact_transaction_2020.scenario_id=dbo.dim_scenario.scenario_id
      where category='billing' and status_id=1 and sub_category in ('electricity','internet','water')
      group by year(transaction_time), month(transaction_time)
)
select *
, FORMAT((number_customer-starting_point)*1.0/starting_point,'p') AS diff_pct
from sum_tab
