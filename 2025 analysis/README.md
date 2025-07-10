This analysis studies the impact of activity mitigation efforts on demand at hospitals in England between 2011/12 and 2019/20. 

This is done by studying the differential growth rates in activity for mitigatable activity. The mitigatable activity falls into four types:

-   prevention (`prev`)
-   redirection and substitution (`reSu`)
-   de-adoption (`deAdopt`)

Any activity which is not in scope of at least one of these types of mitigation is recorded as non-mitigatbale (`none`), with this group serving as our counterfactual against which we measure the relative growth rates for each of the above mitigation types.

There are four points of delivery (pod) upon which we stratisfy the analysis:
-  elective inpatient admissions,
-  non-elective inpatient admissions,
-  outpatient appointments
-  ED attendances

The combinations of pod and mitigation type are as follows:

-  elective admissions in scope of de-adoption
-  elective admissions in scope of prevention 
-  non-elective admissions in scope of prevention 
-  non-elective admissions in scope of redirection and substitution
-  outpatient appointments in scope of de-adoption
-  ED attendances in scope of redirection and substitution

In the case of admitted patient care, there are admissions which fall in scope of more than one mitigation type. To ensure that the counts of activity avoid double counting admissions, we use the following hierachy to assign each to only one mitigation type:

- if in scope of prevention, then record as prevention
- if in scope of de-adoption, then record as de-adoption
- if in scope of redirection and substitution, then record as redirection and substitution
- else record as non-mitigatable

There are 96 individual strategies considered in the New Hospitals Programme Demand and Capacity Model. (The background to these is detailed in project information for [inpatients](https://connect.strategyunitwm.nhs.uk/nhp/project_information/modelling_methodology/activity_mitigators/inpatient_activity_mitigators.html), [outpatients](https://connect.strategyunitwm.nhs.uk/nhp/project_information/modelling_methodology/activity_mitigators/outpatient_activity_mitigators.html) and [ED](https://connect.strategyunitwm.nhs.uk/nhp/project_information/modelling_methodology/activity_mitigators/ae_activity_mitigators.html). 

We are primarily concerned with admission avoidance strategies, given we are only studying the arrivals at hospitals and not length of stay. As a result, there are a total 58 strategies we consider with these falling into 30 admitted patient acre, 16 ED and 12 outpatient. The full list is below.

| activity_type | mitigator_type     | mitigator_variable                                        | mitigator_name                                                              | mitigator_code | paper grouping             |
| ------------- | ------------------ | --------------------------------------------------------- | --------------------------------------------------------------------------- | -------------- | -------------------------- |
| aae           | activity_avoidance | discharged_no_treatment_adult_ambulance                   | A&E Discharged No Investigation or Treatment (Adult, Ambulance Conveyed)    | AE-AA-001      | Redirection & substitution |
| aae           | activity_avoidance | discharged_no_treatment_adult_walk-in                     | A&E Discharged No Investigation or Treatment (Adult, Walk-in)               | AE-AA-002      | Redirection & substitution |
| aae           | activity_avoidance | discharged_no_treatment_child_ambulance                   | A&E Discharged No Investigation or Treatment (Children, Ambulance Conveyed) | AE-AA-003      | Redirection & substitution |
| aae           | activity_avoidance | discharged_no_treatment_child_walk-in                     | A&E Discharged No Investigation or Treatment (Children, Walk-in)            | AE-AA-004      | Redirection & substitution |
| aae           | activity_avoidance | frequent_attenders_adult_ambulance                        | A&E Frequent Attenders (Adult, Ambulance Conveyed)                          | AE-AA-005      | Redirection & substitution |
| aae           | activity_avoidance | frequent_attenders_adult_walk-in                          | A&E Frequent Attenders (Adult, Walk-in)                                     | AE-AA-006      | Redirection & substitution |
| aae           | activity_avoidance | frequent_attenders_child_ambulance                        | A&E Frequent Attenders (Children, Ambulance Conveyed)                       | AE-AA-007      | Redirection & substitution |
| aae           | activity_avoidance | frequent_attenders_child_walk-in                          | A&E Frequent Attenders (Children, Walk-in)                                  | AE-AA-008      | Redirection & substitution |
| aae           | activity_avoidance | low_cost_discharged_adult_ambulance                       | A&E Low Cost Discharged Attendances (Adult, Ambulance Conveyed)             | AE-AA-013      | Redirection & substitution |
| aae           | activity_avoidance | low_cost_discharged_adult_walk-in                         | A&E Low Cost Discharged Attendances (Adult, Walk-in)                        | AE-AA-014      | Redirection & substitution |
| aae           | activity_avoidance | low_cost_discharged_child_ambulance                       | A&E Low Cost Discharged Attendances (Children, Ambulance Conveyed)          | AE-AA-015      | Redirection & substitution |
| aae           | activity_avoidance | low_cost_discharged_child_walk-in                         | A&E Low Cost Discharged Attendances (Children, Walk-in)                     | AE-AA-016      | Redirection & substitution |
| aae           | activity_avoidance | left_before_seen_adult_ambulance                          | A&E Patients Left Before Being Treated (Adult, Ambulance Conveyed)          | AE-AA-009      | Redirection & substitution |
| aae           | activity_avoidance | left_before_seen_adult_walk-in                            | A&E Patients Left Before Being Treated (Adult, Walk-in)                     | AE-AA-010      | Redirection & substitution |
| aae           | activity_avoidance | left_before_seen_child_ambulance                          | A&E Patients Left Before Being Treated (Children, Ambulance Conveyed)       | AE-AA-011      | Redirection & substitution |
| aae           | activity_avoidance | left_before_seen_child_walk-in                            | A&E Patients Left Before Being Treated (Children, Walk-in)                  | AE-AA-012      | Redirection & substitution |
| ip            | activity_avoidance | zero_los_no_procedure_adult                               | Admission With No Overnight Stay and No Procedure (Adults)                  | IP-AA-032      | Redirection & substitution |
| ip            | activity_avoidance | zero_los_no_procedure_child                               | Admission With No Overnight Stay and No Procedure (Children)                | IP-AA-033      | Redirection & substitution |
| ip            | activity_avoidance | alcohol_partially_attributable_acute                      | Alcohol Related Admissions (Acute Conditions - Partially Attributable)      | IP-AA-001      | Prevention                 |
| ip            | activity_avoidance | alcohol_partially_attributable_chronic                    | Alcohol Related Admissions (Chronic Conditions - Partially Attributable)    | IP-AA-002      | Prevention                 |
| ip            | activity_avoidance | alcohol_wholly_attributable                               | Alcohol Related Admissions (Wholly Attributable)                            | IP-AA-003      | Prevention                 |
| ip            | activity_avoidance | ambulatory_care_conditions_acute                          | Ambulatory Care Sensitive Admissions (Acute Conditions)                     | IP-AA-004      | Redirection & substitution |
| ip            | activity_avoidance | ambulatory_care_conditions_chronic                        | Ambulatory Care Sensitive Admissions (Chronic Conditions)                   | IP-AA-005      | Redirection & substitution |
| ip            | activity_avoidance | ambulatory_care_conditions_vaccine_preventable            | Ambulatory Care Sensitive Admissions (Vaccine Preventable)                  | IP-AA-006      | Redirection & substitution |
| ip            | activity_avoidance | readmission_within_28_days                                | Emergency Readmissions Within 28 Days                                       | IP-AA-028      | Redirection & substitution |
| ip            | activity_avoidance | eol_care_2_days                                           | End of Life Care Admissions (died within 2 days)                            | IP-AA-008      | Redirection & substitution |
| ip            | activity_avoidance | eol_care_3_to_14_days                                     | End of Life Care Admissions (died within 3-14 days)                         | IP-AA-009      | Redirection & substitution |
| ip            | activity_avoidance | falls_related_admissions                                  | Falls Related Admissions                                                    | IP-AA-016      | Prevention                 |
| ip            | activity_avoidance | intentional_self_harm                                     | Intentional Self Harm Admissions                                            | IP-AA-019      | Redirection & substitution |
| ip            | activity_avoidance | evidence_based_interventions_ent                          | Interventions with Limited Evidence (ENT)                                   | IP-AA-010      | De-adoption                |
| ip            | activity_avoidance | evidence_based_interventions_general_surgery              | Interventions with Limited Evidence (General Surgery)                       | IP-AA-011      | De-adoption                |
| ip            | activity_avoidance | evidence_based_interventions_gi_surgical                  | Interventions with Limited Evidence (GI Surgical)                           | IP-AA-012      | De-adoption                |
| ip            | activity_avoidance | evidence_based_interventions_msk                          | Interventions with Limited Evidence (MSK)                                   | IP-AA-013      | De-adoption                |
| ip            | activity_avoidance | evidence_based_interventions_urology                      | Interventions with Limited Evidence (Urology)                               | IP-AA-014      | De-adoption                |
| ip            | activity_avoidance | evidence_based_interventions_vascular_varicose_veins      | Interventions with Limited Evidence (Vascular Varicose Veins)               | IP-AA-015      | De-adoption                |
| ip            | activity_avoidance | medically_unexplained_related_admissions                  | Medically Unexplained Symptoms Admissions                                   | IP-AA-020      | Redirection & substitution |
| ip            | activity_avoidance | medicines_related_admissions_explicit                     | Medicines Related Admissions (Explicit)                                     | IP-AA-021      | Redirection & substitution |
| ip            | activity_avoidance | medicines_related_admissions_implicit_anti-diabetics      | Medicines Related Admissions (Implicit - Anti-Diabetics)                    | IP-AA-022      | Redirection & substitution |
| ip            | activity_avoidance | medicines_related_admissions_implicit_benzodiasepines     | Medicines Related Admissions (Implicit - Benzodiazepines)                   | IP-AA-023      | Redirection & substitution |
| ip            | activity_avoidance | medicines_related_admissions_implicit_diurectics          | Medicines Related Admissions (Implicit - Diuretics)                         | IP-AA-024      | Redirection & substitution |
| ip            | activity_avoidance | medicines_related_admissions_implicit_nsaids              | Medicines Related Admissions (Implicit - NSAIDs)                            | IP-AA-025      | Redirection & substitution |
| ip            | activity_avoidance | raid_ae                                                   | Mental Health Admissions via Emergency Department                           | IP-AA-027      | Redirection & substitution |
| ip            | activity_avoidance | obesity_related_admissions                                | Obesity Related Admissions                                                  | IP-AA-026      | Prevention                 |
| ip            | activity_avoidance | frail_elderly_high                                        | Older People with Frailty Admissions (High Frailty Risk)                    | IP-AA-017      | Redirection & substitution |
| ip            | activity_avoidance | frail_elderly_intermediate                                | Older People with Frailty Admissions (Intermediate Frailty Risk)            | IP-AA-018      | Redirection & substitution |
| ip            | activity_avoidance | smoking                                                   | Smoking Related Admissions                                                  | IP-AA-029      | Prevention                 |
| op            | activity_avoidance | consultant_to_consultant_reduction_adult_non-surgical     | Outpatient Consultant to Consultant Referrals (Adult, Non-Surgical)         | OP-AA-001      | De-adoption                |
| op            | activity_avoidance | consultant_to_consultant_reduction_adult_surgical         | Outpatient Consultant to Consultant Referrals (Adult, Surgical)             | OP-AA-002      | De-adoption                |
| op            | activity_avoidance | consultant_to_consultant_reduction_child_non-surgical     | Outpatient Consultant to Consultant Referrals (Children, Non-Surgical)      | OP-AA-003      | De-adoption                |
| op            | activity_avoidance | consultant_to_consultant_reduction_child_surgical         | Outpatient Consultant to Consultant Referrals (Children, Surgical)          | OP-AA-004      | De-adoption                |
| op            | activity_avoidance | followup_reduction_adult_non-surgical                     | Outpatient Followup Appointment Reduction (Adult, Non-Surgical)             | OP-AA-005      | De-adoption                |
| op            | activity_avoidance | followup_reduction_adult_surgical                         | Outpatient Followup Appointment Reduction (Adult, Surgical)                 | OP-AA-006      | De-adoption                |
| op            | activity_avoidance | followup_reduction_child_non-surgical                     | Outpatient Followup Appointment Reduction (Children, Non-Surgical)          | OP-AA-007      | De-adoption                |
| op            | activity_avoidance | followup_reduction_child_surgical                         | Outpatient Followup Appointment Reduction (Children, Surgical)              | OP-AA-008      | De-adoption                |
| op            | activity_avoidance | gp_referred_first_attendance_reduction_adult_non-surgical | Outpatient GP Referred First Attendance Reduction (Adult, Non-Surgical)     | OP-AA-009      | De-adoption                |
| op            | activity_avoidance | gp_referred_first_attendance_reduction_adult_surgical     | Outpatient GP Referred First Attendance Reduction (Adult, Surgical)         | OP-AA-010      | De-adoption                |
| op            | activity_avoidance | gp_referred_first_attendance_reduction_child_non-surgical | Outpatient GP Referred First Attendance Reduction (Children, Non-Surgical)  | OP-AA-011      | De-adoption                |
| op            | activity_avoidance | gp_referred_first_attendance_reduction_child_surgical     | Outpatient GP Referred First Attendance Reduction (Children, Surgical)      | OP-AA-012      | De-adoption                |

This analysis serves as a sequel to a previous analysis in the parent folder. The difference is that the extraction of data is from Data Bricks -- full details in [this notebook](https://adb-4243551358552236.16.azuredatabricks.net/editor/notebooks/3706892377783776?o=4243551358552236) and also committed to this repo -- and that we control for additional factors in our growth rates (in bold below):

-  population size
-  age-sex breakdown
-  **deprivation quintile**
-  **region**
-   **case mix:**
    -   **for inpatients admissions, the ICD-10 chapter of the principal diagnosis**
    -   **for outpatients attendances, the type (surgical, non-surgical and maternity)**
    -   **for ED attendances, the group (ambulance and walk-in)**
 
We evaluate the impact by using general additive models (in this case big additive models, due to the sheer amount of data) of the following forms

**Admitted patient care**

```
bam(
  activity ~ s(age, by = sex) + sex + mitigation_type + fyear + fyear:mitigation_type + chapter_number + imd_quintile + s(resgor_ons, bs = "re") + offset(log(population)),
  family = nb(link = 'log'),
  weights = population_share,
  data = gam_data_apc,
  subset = (pod == "non-elective"),
  discrete = TRUE)
```

**Outpatients**

```
bam(
  activity ~ s(age, by = sex_type) + sex + mitigation_type + fyear + fyear:mitigation_type + type + imd_quintile + s(resgor_ons, bs = 're') + offset(log(population)),
  family = nb(link = 'log'),
  weights = population_share,
  data = gam_data_op,
  discrete = TRUE)
```

**ED**

```
ed_bam_re <- bam(
  activity ~ s(age, by = sex_group) + sex + mitigation_type + fyear + fyear:mitigation_type + group + imd_quintile + s(resgor_ons, bs = 're') + offset(log(population)),
  family = nb(link = 'log'),
  weights = population_share,
  data = gam_data_aae,
  discrete = TRUE)
```


