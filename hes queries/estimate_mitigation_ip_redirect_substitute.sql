use StrategicWorking

--drop table dbo.sw_ip_mitigatable_redirect_substitute


select EPIKEY, fyear

into dbo.sw_ip_mitigatable_redirect_substitute

from [HESData].[nhp_strategies].[ip_ambulatory_care_conditions_acute]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_ambulatory_care_conditions_chronic]
where fraction >= RAND(CHECKSUM(NewId()))


union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_ambulatory_care_conditions_vaccine_preventable]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_eol_care]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_frail_elderly]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_intentional_self_harm]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_medically_unexplained_related_admissions]
where fraction >= RAND(CHECKSUM(NewId()))


union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_medicines_related_admissions_explicit]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_medicines_related_admissions_implicit_anti_diabetics]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_medicines_related_admissions_implicit_benzodiasepines]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_medicines_related_admissions_implicit_diurectics]
where fraction >= RAND(CHECKSUM(NewId()))


union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_medicines_related_admissions_implicit_nsaids]
where fraction >= RAND(CHECKSUM(NewId()))


union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_raid_ae]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_readmission_within_28_days]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_zero_los_no_procedure]
where fraction >= RAND(CHECKSUM(NewId()))


