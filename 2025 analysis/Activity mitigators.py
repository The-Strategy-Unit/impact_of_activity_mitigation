# Databricks notebook source
# MAGIC %md
# MAGIC # Kick off of analysis
# MAGIC
# MAGIC Steven and I discussed the initial extraction needed for this work. We wanted counts of hospital spells on the following variables:
# MAGIC
# MAGIC - Year
# MAGIC - Admission method
# MAGIC - Age
# MAGIC - Sex
# MAGIC - ICD10 chapter
# MAGIC - Mitigation type (prevention; de-adoption; redirection & substitution; none / counterfactual)
# MAGIC - Deprivation quintile
# MAGIC
# MAGIC We can see that currently the mitigators data has specific strategies. We need to map these strategies to the three mitigation classes. The table in the previous mitigation paper has **19** unique activity subsets that are binned into the three mitigation classes. There are some instances in which the  mitigation class appears in more than one pod, e.g. alcohol related admissions appears in both elective and non-elective. The total number of combinations of activity type and mitigation class is **23**.
# MAGIC
# MAGIC There may be a situation in which an episode falls in scope of more than one of the three mitigations. It's somewhat arbritrary but our rule for this is the following hierachy to arrive at a single mitigation type per episode: prevention > de-adoption > redirection & substitution > none.
# MAGIC
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC ## Mitigation classes by pod from previous activity mitigation analysis
# MAGIC
# MAGIC |Mitigation class|Hospital activity subsets|Point of Delivery|% of total activity 2013|% of total activity 2019|
# MAGIC |:----|:----|:----|:----|:----|
# MAGIC |Prevention|Alcohol related admissions|non-elective admissions|8.82%|8.77%|
# MAGIC | |Alcohol related admissions|elective admissions|4.14%|4.99%|
# MAGIC | |Falls related admissions|non-elective admissions|3.83%|3.85%|
# MAGIC | |Smoking related admissions|elective admissions|2.91%|2.92%|
# MAGIC | |Smoking related admissions|non-elective admissions|2.58%|2.56%|
# MAGIC | |Obesity related admissions|non-elective admissions|0.65%|0.64%|
# MAGIC | |Obesity related admissions|elective admissions|0.64%|0.64%|
# MAGIC |Redirection/substitution|Low cost discharged attendances|ED attendances|35.34%|33.62%|
# MAGIC | |Emergency re-admissions within 28 days|non-elective admissions|21.23%|22.79%|
# MAGIC | |Admission with no overnight stay and no procedure|non-elective admissions|19.92%|25.38%|
# MAGIC | |Ambulatory care sensitive admissions|non-elective admissions|14.95%|17.22%|
# MAGIC | |Frail elderly admissions|non-elective admissions|12.69%|15.75%|
# MAGIC | |Frequent ED attenders|ED attendances|12.32%|14.72%|
# MAGIC | |Medically unexplained symptoms admissions|non-elective admissions|4.72%|4.53%|
# MAGIC | |Medicines related admissions|non-elective admissions|2.96%|3.12%|
# MAGIC | |Patients who leave ED before being seen|ED attendances|2.56%|1.89%|
# MAGIC | |Intentional self-harm admissions|non-elective admissions|1.67%|1.26%|
# MAGIC | |End of life care admissions|non-elective admissions|1.26%|1.03%|
# MAGIC | |Mental health admissions via ED|non-elective admissions|1.08%|1.24%|
# MAGIC | |End of life care admissions|elective admissions|0.02%|0.01%|
# MAGIC |De-adoption|Follow-up outpatient attendances|outpatient attendances|68.86%|64.93%|
# MAGIC | |Interventions with limited evidence|elective admissions|14.00%|12.85%|
# MAGIC | |Consultant referred outpatient attendances|outpatient attendances|5.32%|5.68%|
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC ## Initial script
# MAGIC Let's start by counting episodes across all fiscal years by admission method and mitigation. This is just from admitted patient care (apc) for now. We need to link the apc mitigators and diagnoses tables.

# COMMAND ----------

# MAGIC %sql
# MAGIC describe su_data.nhp.apc

# COMMAND ----------

# MAGIC %sql
# MAGIC describe su_data.nhp.apc_mitigators

# COMMAND ----------

# MAGIC %sql
# MAGIC describe hes.silver.apc_diagnoses

# COMMAND ----------

# MAGIC %sql
# MAGIC /* code for loading in the mitigator lookup as a view*/
# MAGIC CREATE temporary view mitigator_lookup AS SELECT
# MAGIC   *
# MAGIC FROM
# MAGIC   read_files(
# MAGIC     '/Volumes/su_data/nhp/reference_data/mitigator-lookup.csv',
# MAGIC     format => 'csv',
# MAGIC     header => true,
# MAGIC     --schema => 'lsoa11 string, imd19_decile int',
# MAGIC     mode => 'FAILFAST'
# MAGIC   )

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT
# MAGIC   i.fyear,
# MAGIC   case
# MAGIC 	  when i.admimeth like '1%' then 'IpElec'
# MAGIC     when i.admimeth like '3%' then 'IpMat'
# MAGIC     else 'IpEmer' -- arguably should be widened to non-elective
# MAGIC   end as pod,
# MAGIC   i.age,
# MAGIC   case
# MAGIC     when i.sex = '1' then 'Male'
# MAGIC     else 'Female'
# MAGIC   end as sex,
# MAGIC   left(d.diagnosis, 1) as icd_chapter,
# MAGIC   e.imd19_decile,
# MAGIC   a.type,
# MAGIC   a.strategy,
# MAGIC   sum(a.sample_rate) as n
# MAGIC  FROM su_data.nhp.apc i
# MAGIC  INNER JOIN 
# MAGIC   su_data.nhp.apc_mitigators a 
# MAGIC   ON i.epikey = a.epikey
# MAGIC INNER JOIN
# MAGIC   hes.silver.apc_diagnoses d 
# MAGIC   ON i.epikey = d.epikey
# MAGIC LEFT JOIN  
# MAGIC   Su_data.reference.lsoa11_to_imd19 e
# MAGIC   ON i.lsoa11 = e.lsoa11
# MAGIC WHERE
# MAGIC   d.diag_order = 1
# MAGIC GROUP BY
# MAGIC   i.fyear,
# MAGIC   case
# MAGIC 	  when i.admimeth like '1%' then 'IpElec'
# MAGIC     when i.admimeth like '3%' then 'IpMat'
# MAGIC     else 'IpEmer' -- arguably should be widened to non-elective
# MAGIC   end,
# MAGIC   i.age,
# MAGIC   case
# MAGIC     when i.sex = '1' then 'Male'
# MAGIC     else 'Female'
# MAGIC   end,
# MAGIC   left(d.diagnosis, 1),
# MAGIC   e.imd19_decile,
# MAGIC   a.type,
# MAGIC   --a.sample_rate,
# MAGIC   a.strategy
# MAGIC
# MAGIC
# MAGIC   
# MAGIC 	

# COMMAND ----------

# MAGIC %md
# MAGIC This takes 20 minutes to run and is huge. We will attempt to reduce the detail through aggregating the mitigators to their respective groups. 

# COMMAND ----------

# MAGIC %md
# MAGIC ### attempt of categorising mitigators 

# COMMAND ----------

# MAGIC %md
# MAGIC From the previous queries (at the bottom of this note), there are **30** strategies that are being categorised into three groups: prevention, re-direction and subtitution, and de-adoption (called rationing previously).
# MAGIC
# MAGIC The mitigator lookup has **92** strategies of which **61** are activity avoidance (which is the type of mitigation we are interested in).
# MAGIC
# MAGIC The query below demonstrates that there are only **58** strategies in this data. **33** of them are activity avoidance. Thus we are missing only **3** from this table. 

# COMMAND ----------

# MAGIC %sql
# MAGIC select type, count(distinct strategy) from su_data.nhp.apc_mitigators group by type

# COMMAND ----------

# MAGIC %sql
# MAGIC describe su_data.nhp.opa_mitigators

# COMMAND ----------

# MAGIC %md
# MAGIC Now we will categorise the strategies into the three buckets of prevention (`prev`), re-direction and substitution (`reSu`) and de-adoption (`deAdopt`).

# COMMAND ----------

# MAGIC %sql
# MAGIC
# MAGIC select 
# MAGIC     --epikey,
# MAGIC     sum(sample_rate),
# MAGIC     type,
# MAGIC     strategy,
# MAGIC     case
# MAGIC         when strategy in (
# MAGIC             'alcohol_partially_attributable_acute', 'alcohol_partially_attributable_chronic', 'alcohol_wholly_attributable', 'falls_related_admissions',              'obesity_related_admissions', 'smoking') then 'prev'
# MAGIC         when strategy in (
# MAGIC             'evidence_based_interventions_ent', 'evidence_based_interventions_general_surgery', 'evidence_based_interventions_gi_surgical', 'evidence_based_interventions_msk', 'evidence_based_interventions_urology', 'evidence_based_interventions_vascular_varicose_veins') then 'deAdopt'
# MAGIC         when strategy in (
# MAGIC             'ambulatory_care_conditions_acute', 'ambulatory_care_conditions_chronic', 'ambulatory_care_conditions_vaccine_preventable', 'eol_care_2_days', 'eol_care_3_to_14_days', 'frail_elderly_high', 'frail_elderly_intermediate', 'intentional_self_harm', 'medically_unexplained_related_admissions', 'medicines_related_admissions_explicit', 'medicines_related_admissions_implicit_anti-diabetics', 'medicines_related_admissions_implicit_benzodiasepines', 'medicines_related_admissions_implicit_diurectics', 'medicines_related_admissions_implicit_nsaids', 'raid_ae', 'readmission_within_28_days', 'zero_los_no_procedure_adult', 'zero_los_no_procedure_child') then 'reSu'
# MAGIC         else 'other'
# MAGIC     end as mitigation_type,
# MAGIC     count(*) as n
# MAGIC from
# MAGIC     su_data.nhp.apc_mitigators
# MAGIC group by
# MAGIC     --epikey,
# MAGIC     --sample_rate,
# MAGIC     type,
# MAGIC     strategy,
# MAGIC     case
# MAGIC         when strategy in (
# MAGIC             'alcohol_partially_attributable_acute', 'alcohol_partially_attributable_chronic', 'alcohol_wholly_attributable', 'falls_related_admissions',              'obesity_related_admissions', 'smoking') then 'Prevention'
# MAGIC         when strategy in (
# MAGIC             'evidence_based_interventions_ent', 'evidence_based_interventions_general_surgery', 'evidence_based_interventions_gi_surgical', 'evidence_based_interventions_msk', 'evidence_based_interventions_urology', 'evidence_based_interventions_vascular_varicose_veins') then 'De-adoption'
# MAGIC         when strategy in (
# MAGIC             'ambulatory_care_conditions_acute', 'ambulatory_care_conditions_chronic', 'ambulatory_care_conditions_vaccine_preventable', 'eol_care_2_days', 'eol_care_3_to_14_days', 'frail_elderly_high', 'frail_elderly_intermediate', 'intentional_self_harm', 'medically_unexplained_related_admissions', 'medicines_related_admissions_explicit', 'medicines_related_admissions_implicit_anti-diabetics', 'medicines_related_admissions_implicit_benzodiasepines', 'medicines_related_admissions_implicit_diurectics', 'medicines_related_admissions_implicit_nsaids', 'raid_ae', 'readmission_within_28_days', 'zero_los_no_procedure_adult', 'zero_los_no_procedure_child') then 'Redirection & substitution'
# MAGIC         else 'other'
# MAGIC     end

# COMMAND ----------

# MAGIC %md
# MAGIC Filtering the above to `type == "activity_avoidance"` and `mitigation_type = "other"` draws out the following three strategies which are missing:
# MAGIC
# MAGIC - _cancelled_operations_
# MAGIC - _virtual_wards_activity_avoidance_ari_
# MAGIC - _virtual_wards_activity_avoidance_heart_failure_

# COMMAND ----------

# MAGIC %md
# MAGIC #### Creating a view
# MAGIC
# MAGIC Now we will create a view which we can use when loading in the mitigators.
# MAGIC
# MAGIC

# COMMAND ----------

# MAGIC %sql
# MAGIC
# MAGIC CREATE temporary view apc_mitigators_data AS SELECT
# MAGIC     epikey,
# MAGIC     sample_rate,
# MAGIC     type,
# MAGIC     strategy,
# MAGIC     case
# MAGIC         when strategy in (
# MAGIC             'alcohol_partially_attributable_acute', 'alcohol_partially_attributable_chronic', 'alcohol_wholly_attributable', 'falls_related_admissions',              'obesity_related_admissions', 'smoking') then 'prev'
# MAGIC         when strategy in (
# MAGIC             'evidence_based_interventions_ent', 'evidence_based_interventions_general_surgery', 'evidence_based_interventions_gi_surgical', 'evidence_based_interventions_msk', 'evidence_based_interventions_urology', 'evidence_based_interventions_vascular_varicose_veins') then 'deAdopt'
# MAGIC         when strategy in (
# MAGIC             'ambulatory_care_conditions_acute', 'ambulatory_care_conditions_chronic', 'ambulatory_care_conditions_vaccine_preventable', 'eol_care_2_days', 'eol_care_3_to_14_days', 'frail_elderly_high', 'frail_elderly_intermediate', 'intentional_self_harm', 'medically_unexplained_related_admissions', 'medicines_related_admissions_explicit', 'medicines_related_admissions_implicit_anti-diabetics', 'medicines_related_admissions_implicit_benzodiasepines', 'medicines_related_admissions_implicit_diurectics', 'medicines_related_admissions_implicit_nsaids', 'raid_ae', 'readmission_within_28_days', 'zero_los_no_procedure_adult', 'zero_los_no_procedure_child') then 'reSu'
# MAGIC         else 'other'
# MAGIC     end as mitigation_type
# MAGIC from
# MAGIC     su_data.nhp.apc_mitigators

# COMMAND ----------

# MAGIC %md
# MAGIC ### Sampling
# MAGIC Just because an episode appears in scope of a strategy does not mean that we think it would be affected. Above we investigated this using the specific episode with ID '510238182078' in the mitigators table. Let's review that again, this time using the view we created above.

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT  
# MAGIC   *
# MAGIC FROM  
# MAGIC   apc_mitigators_data
# MAGIC WHERE  epikey = '510238182078'
# MAGIC ORDER BY mitigation_type

# COMMAND ----------

# MAGIC %md
# MAGIC The sample rate column tells us for each strategy the proportion of episodes in its scope that would be likely to be actually affected by said strategy. Thus, what we can do is use random number generator to filter on it. 

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT
# MAGIC   *
# MAGIC FROM  
# MAGIC   apc_mitigators_data
# MAGIC WHERE  
# MAGIC   epikey = '510238182078'
# MAGIC   and sample_rate >= rand()
# MAGIC
# MAGIC ORDER BY mitigation_type

# COMMAND ----------

# MAGIC %md
# MAGIC Works as expected. The alcohol partially attributable disappears. It *could* have appeared, but we would expect it to only be counted in 5% of cases.

# COMMAND ----------

# MAGIC %md
# MAGIC #### creating a view

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMPORARY VIEW apc_mitigators_data_sampled AS SELECT * FROM apc_mitigators_data WHERE sample_rate >= rand();

# COMMAND ----------

# MAGIC %md
# MAGIC #### Testing sampled view
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC In theory the number of rows in the sampled data should be the average sampling rate times the number of rows in the unsampled data.

# COMMAND ----------

# MAGIC %sql
# MAGIC -- 1. Calculate the average sample rate, number of rows and expected number of rows after sampling
# MAGIC WITH avg_sample_rate_cte AS (
# MAGIC     SELECT AVG(sample_rate) AS avg_sample_rate, 
# MAGIC     count(*) as count, 
# MAGIC     avg_sample_rate * count(*) as expected_rows
# MAGIC     FROM apc_mitigators_data
# MAGIC ),
# MAGIC
# MAGIC -- 2. Query the sampled table for the actual number of rows
# MAGIC actual_rows_cte AS (
# MAGIC     SELECT count(*) as actual_rows
# MAGIC     FROM apc_mitigators_data_sampled
# MAGIC )
# MAGIC
# MAGIC -- Final select to display the results
# MAGIC SELECT 
# MAGIC     avg_sample_rate_cte.avg_sample_rate,
# MAGIC     avg_sample_rate_cte.count,
# MAGIC     avg_sample_rate_cte.expected_rows,
# MAGIC     actual_rows_cte.actual_rows,
# MAGIC     avg_sample_rate_cte.expected_rows - actual_rows_cte.actual_rows AS diff,
# MAGIC     (avg_sample_rate_cte.expected_rows - actual_rows_cte.actual_rows) / actual_rows_cte.actual_rows as diff_p
# MAGIC FROM 
# MAGIC     avg_sample_rate_cte,
# MAGIC     actual_rows_cte;

# COMMAND ----------

# MAGIC %md
# MAGIC ### Hierarchy of mitigation types
# MAGIC
# MAGIC Remember that a single episode can appear more than once in the procedures table. Above we investigated this using the specific episode with ID '510238182078' in the mitigators table. Let's review that again, this time using the view we created above. 

# COMMAND ----------

# MAGIC %sql
# MAGIC select * from apc_mitigators_data_sampled where epikey = '510238182078'

# COMMAND ----------

# MAGIC %md
# MAGIC It appears under four strategies, two of which are classes as re-direction and substitution, two are other efficiency mitigations.
# MAGIC
# MAGIC We have a hierachy in this case, the episode will be assigned to a mitigation type according to the following hiarchy: **prevention > de-adoption > redirection and substitution; if none of those exist, then "none".**
# MAGIC
# MAGIC What we can do is create another view, where we have selected only one row according to that hierarchy. To do this we use row numbers.
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC #### Creating ranked view
# MAGIC Now we can tie them up. recap:
# MAGIC - we start with a view where the mitigators have been categorised into `prev`, `deAdopt`, and `reSu` (plus `other`) 
# MAGIC - we want to perform the sampling of the mitigators to account for the fact that the strategies will not impact every single episode in scope
# MAGIC - we then want to select the mitigator type according to the hierachy we have decided upon

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMPORARY VIEW apc_mitigators_data_ranked AS
# MAGIC   SELECT
# MAGIC     *
# MAGIC   FROM (
# MAGIC     SELECT
# MAGIC       *,
# MAGIC       ROW_NUMBER() OVER (
# MAGIC                PARTITION BY epikey
# MAGIC                ORDER BY
# MAGIC                    CASE mitigation_type
# MAGIC                        WHEN 'prev' THEN 1
# MAGIC                        WHEN 'deAdopt' THEN 2
# MAGIC                        WHEN 'reSu' THEN 3
# MAGIC                        ELSE 4 -- Default for any unexpected values
# MAGIC                    END
# MAGIC            ) AS rn -- this is the row number, not the rank - it is based on rank 
# MAGIC     FROM apc_mitigators_data_sampled
# MAGIC   ) subquery
# MAGIC   WHERE rn = 1;  -- given it is row number, there will be only one
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC #### testing ranked view

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT  
# MAGIC   *
# MAGIC FROM  
# MAGIC   apc_mitigators_data_ranked
# MAGIC WHERE  epikey = '510238182078'
# MAGIC ORDER BY mitigation_type

# COMMAND ----------

# MAGIC %md
# MAGIC It works: as expected it is counted as a single reSu case. 
# MAGIC
# MAGIC However, just want to check the point above as in this case prevention won out but it only appeared once in the mitigators table. 
# MAGIC
# MAGIC the query below shows episodes in the mitigators table by how how often they show up in scope of strategies.
# MAGIC

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT  
# MAGIC   epikey,
# MAGIC   count( *)
# MAGIC FROM  
# MAGIC   apc_mitigators_data_sampled
# MAGIC group by epikey
# MAGIC limit 100

# COMMAND ----------

# MAGIC %md
# MAGIC We'll take '508702865261' in the subsequent analysis as it is under 7 mitigators

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT  
# MAGIC   *
# MAGIC FROM  
# MAGIC   apc_mitigators_data_sampled
# MAGIC WHERE  epikey = '508702865261'
# MAGIC ORDER BY mitigation_type

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT  
# MAGIC   *
# MAGIC FROM  
# MAGIC   apc_mitigators_data_ranked
# MAGIC WHERE  epikey = '508702865261'
# MAGIC ORDER BY mitigation_type

# COMMAND ----------

# MAGIC %md
# MAGIC ### the script for inpatients

# COMMAND ----------

# MAGIC %sql
# MAGIC select fyear, count(*) from Su_data.nhp.apc group by fyear order by fyear

# COMMAND ----------

# MAGIC %sql
# MAGIC -- try out the code using the specific episode
# MAGIC SELECT
# MAGIC   i.fyear,
# MAGIC   case
# MAGIC 	  when i.admimeth like '1%' then 'IpElec'
# MAGIC     when i.admimeth like '3%' then 'IpMat'
# MAGIC     else 'IpEmer' -- arguably should be widened to non-elective
# MAGIC   end as pod,
# MAGIC   i.age,
# MAGIC   case
# MAGIC     when i.sex = '1' then 'Male'
# MAGIC     else 'Female'
# MAGIC   end as sex,
# MAGIC   f.chapter_code as icd_chapter,
# MAGIC   e.imd19_decile,
# MAGIC   a.mitigation_type,
# MAGIC   count(i.epikey) as episodes  
# MAGIC  FROM su_data.nhp.apc i
# MAGIC  INNER JOIN 
# MAGIC   apc_mitigators_data_ranked a 
# MAGIC   ON i.epikey = a.epikey
# MAGIC INNER JOIN
# MAGIC   hes.silver.apc_diagnoses d 
# MAGIC   ON i.epikey = d.epikey
# MAGIC LEFT JOIN
# MAGIC   Su_data.reference.icd10_codes f
# MAGIC   ON d.diagnosis = f.icd10
# MAGIC LEFT JOIN  
# MAGIC   Su_data.reference.lsoa11_to_imd19 e
# MAGIC   ON i.lsoa11 = e.lsoa11
# MAGIC WHERE
# MAGIC   d.diag_order = 1
# MAGIC GROUP BY 
# MAGIC   i.fyear,
# MAGIC   case
# MAGIC 	  when i.admimeth like '1%' then 'IpElec'
# MAGIC     when i.admimeth like '3%' then 'IpMat'
# MAGIC     else 'IpEmer' -- arguably should be widened to non-elective
# MAGIC   end,
# MAGIC   i.age,
# MAGIC   case
# MAGIC     when i.sex = '1' then 'Male'
# MAGIC     else 'Female'
# MAGIC   end,
# MAGIC   f.chapter_code,
# MAGIC   e.imd19_decile,
# MAGIC   a.mitigation_type;
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC ## Outpatient and A&E
# MAGIC The 33 activity avoidance mitigators referred to above are for admitted patient care. 
# MAGIC
# MAGIC Consulting the mitigator lookup, there are 16 A&E and 12 outpatients. Each of these will be 4 variants, so in reality it's 4 A&E groupings and 3 OPA groupings.
# MAGIC
# MAGIC These are the ones from Steven's SQL script (essentially 5 mitigators for which there are 4 variations of each)
# MAGIC
# MAGIC - frequent_attenders_adult_ambulance
# MAGIC - frequent_attenders_adult_walk-in
# MAGIC - frequent_attenders_child_ambulance
# MAGIC - frequent_attenders_child_walk-in
# MAGIC - low_cost_discharged_adult_ambulance
# MAGIC - low_cost_discharged_adult_walk-in
# MAGIC - low_cost_discharged_child_ambulance
# MAGIC - low_cost_discharged_child_walk-in
# MAGIC - left_before_seen_adult_ambulance
# MAGIC - left_before_seen_adult_walk-in
# MAGIC - left_before_seen_child_ambulance
# MAGIC - left_before_seen_child_walk-in
# MAGIC - consultant_to_consultant_reduction_adult_non-surgical
# MAGIC - consultant_to_consultant_reduction_adult_surgical
# MAGIC - consultant_to_consultant_reduction_child_non-surgical
# MAGIC - consultant_to_consultant_reduction_child_surgical
# MAGIC - followup_reduction_adult_non-surgical
# MAGIC - followup_reduction_adult_surgical
# MAGIC - followup_reduction_child_non-surgical
# MAGIC - followup_reduction_child_surgical
# MAGIC
# MAGIC So we're off by 2 sets of four:
# MAGIC - gp_referred_first_attendance_reduction_adult_non-surgical
# MAGIC - gp_referred_first_attendance_reduction_adult_surgical
# MAGIC - gp_referred_first_attendance_reduction_child_non-surgical
# MAGIC - gp_referred_first_attendance_reduction_child_surgical
# MAGIC - discharged_no_treatment_adult_ambulance
# MAGIC - discharged_no_treatment_adult_walk-in
# MAGIC - discharged_no_treatment_child_ambulance
# MAGIC - discharged_no_treatment_child_walk-in
# MAGIC
# MAGIC **From having spoken to Tom, the flagging does not exist for outpatient and ED.**
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC ## to-do
# MAGIC
# MAGIC - the A&E and outpatient stuff
# MAGIC - checking about ICD chapters
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC # Previous SQL queries on Strategy Unit Server
# MAGIC
# MAGIC We have the following three scripts for categorising strategies from the previous analysis
# MAGIC
# MAGIC **in-patient prevention**
# MAGIC
# MAGIC ```sql
# MAGIC use StrategicWorking
# MAGIC
# MAGIC --drop table dbo.sw_ip_mitigatable_prevention
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC
# MAGIC into dbo.sw_ip_mitigatable_prevention
# MAGIC
# MAGIC from [HESData].[nhp_strategies].[ip_alcohol_partially_attributable] 
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_alcohol_wholly_attributable]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_falls_related_admissions]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_obesity_related_admissions]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_smoking]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC ```
# MAGIC
# MAGIC **in-patient re-direction and substitution**
# MAGIC
# MAGIC ```sql
# MAGIC use StrategicWorking
# MAGIC
# MAGIC --drop table dbo.sw_ip_mitigatable_redirect_substitute
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC
# MAGIC into dbo.sw_ip_mitigatable_redirect_substitute
# MAGIC
# MAGIC from [HESData].[nhp_strategies].[ip_ambulatory_care_conditions_acute]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_ambulatory_care_conditions_chronic]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_ambulatory_care_conditions_vaccine_preventable]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_eol_care]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_frail_elderly]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_intentional_self_harm]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_medically_unexplained_related_admissions]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_medicines_related_admissions_explicit]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_medicines_related_admissions_implicit_anti_diabetics]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_medicines_related_admissions_implicit_benzodiasepines]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_medicines_related_admissions_implicit_diurectics]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_medicines_related_admissions_implicit_nsaids]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_raid_ae]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_readmission_within_28_days]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_zero_los_no_procedure]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC ```
# MAGIC
# MAGIC **in-patient de-adoption**
# MAGIC
# MAGIC ```sql
# MAGIC use StrategicWorking
# MAGIC
# MAGIC --drop table dbo.sw_ip_mitigatable_rationing
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC
# MAGIC into dbo.sw_ip_mitigatable_rationing
# MAGIC
# MAGIC from [HESData].[nhp_strategies].[ip_evidence_based_interventions_ent]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_evidence_based_interventions_general_surgery]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_evidence_based_interventions_gi_surgical]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_evidence_based_interventions_msk]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_evidence_based_interventions_urology]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select EPIKEY, fyear
# MAGIC from [HESData].[nhp_strategies].[ip_evidence_based_interventions_vasuclar_varicose_veins]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC ```
# MAGIC
# MAGIC **outpatient de-adoption**
# MAGIC ```sql
# MAGIC use StrategicWorking
# MAGIC
# MAGIC --drop table dbo.sw_op_mitigatable_rationing
# MAGIC
# MAGIC select attendkey, fyear
# MAGIC
# MAGIC into dbo.sw_op_mitigatable_rationing
# MAGIC
# MAGIC from [HESData].[nhp_strategies].[op_followup_reduction]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select attendkey, fyear
# MAGIC from [HESData].[nhp_strategies].[op_consultant_to_consultant_referrals]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC ```
# MAGIC
# MAGIC **emergency department re-direction and substitution**
# MAGIC ```sql
# MAGIC use StrategicWorking
# MAGIC
# MAGIC --drop table dbo.sw_ed_mitigatable_redirect_substitute
# MAGIC
# MAGIC
# MAGIC select aekey, fyear
# MAGIC
# MAGIC into dbo.sw_ed_mitigatable_redirect_substitute
# MAGIC
# MAGIC from [HESData].[nhp_strategies].[aae_frequent_attender]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select aekey, fyear
# MAGIC from [HESData].[nhp_strategies].[aae_left_before_treatment]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC
# MAGIC
# MAGIC union
# MAGIC
# MAGIC
# MAGIC select aekey, fyear
# MAGIC from [HESData].[nhp_strategies].[aae_low_cost_discharged]
# MAGIC where fraction >= RAND(CHECKSUM(NewId()))
# MAGIC ```
# MAGIC
