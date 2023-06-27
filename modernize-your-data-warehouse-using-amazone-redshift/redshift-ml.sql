-- Training Data
-- CREATE TABLE bank_details_training(
--    age numeric,
--    jobtype varchar,
--    marital varchar,
--    education varchar,
--    "default" varchar,
--    housing varchar,
--    loan varchar,
--    contact varchar,
--    month varchar,
--    day_of_week varchar,
--    duration numeric,
--    campaign numeric,
--    pdays numeric,
--    previous numeric,
--    poutcome varchar,
--    emp_var_rate numeric,
--    cons_price_idx numeric,     
--    cons_conf_idx numeric,     
--    euribor3m numeric,
--    nr_employed numeric,
--    y boolean ) ;

-- COPY bank_details_training from 's3://redshift-downloads/redshift-ml/workshop/bank-marketing-data/training_data/' REGION 'us-east-1' IAM_ROLE default CSV IGNOREHEADER 1 delimiter ';';

-- Inference Data
-- CREATE TABLE bank_details_inference(
--    age numeric,
--    jobtype varchar,
--    marital varchar,
--    education varchar,
--    "default" varchar,
--    housing varchar,
--    loan varchar,
--    contact varchar,
--    month varchar,
--    day_of_week varchar,
--    duration numeric,
--    campaign numeric,
--    pdays numeric,
--    previous numeric,
--    poutcome varchar,
--    emp_var_rate numeric,
--    cons_price_idx numeric,     
--    cons_conf_idx numeric,     
--    euribor3m numeric,
--    nr_employed numeric,
--    y boolean ) ;

-- COPY bank_details_inference from 's3://redshift-downloads/redshift-ml/workshop/bank-marketing-data/inference_data/' REGION 'us-east-1' IAM_ROLE default CSV IGNOREHEADER 1 delimiter ';';

-- Create a model

-- DROP MODEL model_bank_marketing;

-- CREATE MODEL model_bank_marketing
-- FROM (
-- SELECT    
--    age ,
--    jobtype ,
--    marital ,
--    education ,
--    "default" ,
--    housing ,
--    loan ,
--    contact ,
--    month ,
--    day_of_week ,
--    duration ,
--    campaign ,
--    pdays ,
--    previous ,
--    poutcome ,
--    emp_var_rate ,
--    cons_price_idx ,     
--    cons_conf_idx ,     
--    euribor3m ,
--    nr_employed ,
--    y
-- FROM
--     bank_details_training )
--     TARGET y
-- FUNCTION func_model_bank_marketing
-- IAM_ROLE default
-- SETTINGS (
--   S3_BUCKET 'testanalytics-0542',
--   MAX_RUNTIME 3600
--   )
-- ;


-- show model model_bank_marketing;

--Inference/Accuracy on inference data

WITH infer_data
 AS (
    SELECT  y as actual, func_model_bank_marketing(age,jobtype,marital,education,"default",housing,loan,contact,month,day_of_week,duration,campaign,pdays,previous,poutcome,emp_var_rate,cons_price_idx,cons_conf_idx,euribor3m,nr_employed) AS predicted,
     CASE WHEN actual = predicted THEN 1::INT
         ELSE 0::INT END AS correct
    FROM bank_details_inference
    ),
 aggr_data AS (
     SELECT SUM(correct) as num_correct, COUNT(*) as total FROM infer_data
 )
 SELECT (num_correct::float/total::float) AS accuracy FROM aggr_data;

--Predict how many will subscribe for term deposit vs not subscribe

WITH term_data AS ( SELECT func_model_bank_marketing( age,jobtype,marital,education,"default",housing,loan,contact,month,day_of_week,duration,campaign,pdays,previous,poutcome,emp_var_rate,cons_price_idx,cons_conf_idx,euribor3m,nr_employed) AS predicted
FROM bank_details_inference )
SELECT
CASE WHEN predicted = 'Y'  THEN 'Yes-will-do-a-term-deposit'
     WHEN predicted = 'N'  THEN 'No-term-deposit'
     ELSE 'Neither' END as deposit_prediction,
COUNT(1) AS count
from term_data GROUP BY 1;
