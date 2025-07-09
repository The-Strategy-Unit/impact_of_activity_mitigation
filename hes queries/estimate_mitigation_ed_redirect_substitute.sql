use StrategicWorking

--drop table dbo.sw_ed_mitigatable_redirect_substitute


select aekey, fyear

into dbo.sw_ed_mitigatable_redirect_substitute

from [HESData].[nhp_strategies].[aae_frequent_attender]
where fraction >= RAND(CHECKSUM(NewId()))

union


select aekey, fyear
from [HESData].[nhp_strategies].[aae_left_before_treatment]
where fraction >= RAND(CHECKSUM(NewId()))


union


select aekey, fyear
from [HESData].[nhp_strategies].[aae_low_cost_discharged]
where fraction >= RAND(CHECKSUM(NewId()))


