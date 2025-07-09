use StrategicWorking

--drop table dbo.sw_op_mitigatable_rationing

select attendkey, fyear

into dbo.sw_op_mitigatable_rationing

from [HESData].[nhp_strategies].[op_followup_reduction]
where fraction >= RAND(CHECKSUM(NewId()))

union


select attendkey, fyear
from [HESData].[nhp_strategies].[op_consultant_to_consultant_referrals]
where fraction >= RAND(CHECKSUM(NewId()))

