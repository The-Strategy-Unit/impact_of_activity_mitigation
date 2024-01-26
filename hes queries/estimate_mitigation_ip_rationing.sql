use StrategicWorking

--drop table dbo.sw_ip_mitigatable_rationing


select EPIKEY, fyear

into dbo.sw_ip_mitigatable_rationing

from [HESData].[nhp_strategies].[ip_evidence_based_interventions_ent]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_evidence_based_interventions_general_surgery]
where fraction >= RAND(CHECKSUM(NewId()))


union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_evidence_based_interventions_gi_surgical]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_evidence_based_interventions_msk]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_evidence_based_interventions_urology]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_evidence_based_interventions_vasuclar_varicose_veins]
where fraction >= RAND(CHECKSUM(NewId()))
