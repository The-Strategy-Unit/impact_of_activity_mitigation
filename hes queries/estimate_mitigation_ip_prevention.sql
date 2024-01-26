use StrategicWorking

--drop table dbo.sw_ip_mitigatable_prevention


select EPIKEY, fyear

into dbo.sw_ip_mitigatable_prevention

from [HESData].[nhp_strategies].[ip_alcohol_partially_attributable] 
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_alcohol_wholly_attributable]
where fraction >= RAND(CHECKSUM(NewId()))


union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_falls_related_admissions]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_obesity_related_admissions]
where fraction >= RAND(CHECKSUM(NewId()))

union


select EPIKEY, fyear
from [HESData].[nhp_strategies].[ip_smoking]
where fraction >= RAND(CHECKSUM(NewId()))
