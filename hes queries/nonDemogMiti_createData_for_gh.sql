use hesdata

select

DATEPART(YYYY, ip.admidate) as yr,
age,
case
	when sex = '1' then 'm'
	else 'f'
	end as sex,
case
	when LEFT(admimeth, 1) = '1' then 'IpElec'
	when LEFT(admimeth, 1) = '3' then 'IpMat'
	else 'IpEmer'
  end as pod,
case
	when ipPrev.EPIKEY is not null then 'prev'
	when ipRati.EPIKEY is not null then 'rati'
	when ipReSu.EPIKEY is not null then 'reSu'
	else 'none'
	end as mitigatable,
COUNT(*) as activity

from [nhp_modelling].[inpatients] ip

left outer join [StrategicWorking].[dbo].[sw_ip_mitigatable_prevention] ipPrev
on ip.EPIKEY = ipPrev.EPIKEY
and ip.FYEAR = ipPrev.fyear

left outer join [StrategicWorking].[dbo].[sw_ip_mitigatable_rationing] ipRati
on ip.EPIKEY = ipRati.EPIKEY
and ip.FYEAR = ipRati.fyear

left outer join [StrategicWorking].[dbo].[sw_ip_mitigatable_redirect_substitute] ipReSu
on ip.EPIKEY = ipReSu.EPIKEY
and ip.FYEAR = ipReSu.fyear

where 

--spelend = 'Y' not needed - built into ip view
datepart(YYYY, ip.admidate) >= 2011
and datepart(YYYY, ip.admidate) <= 2019
and age is not null
and age <= 120
and sex is not null
and sex in ('1', '2')

group by 

DATEPART(YYYY, ip.admidate),
age,
case
	when sex = '1' then 'm'
	else 'f'
	end,
case
	when LEFT(admimeth, 1) = '1' then 'IpElec'
	when LEFT(admimeth, 1) = '3' then 'IpMat'
	else 'IpEmer'
	end,
case
	when ipPrev.EPIKEY is not null then 'prev'
	when ipRati.EPIKEY is not null then 'rati'
	when ipReSu.EPIKEY is not null then 'reSu'
	else 'none'
	end

union all

select

DATEPART(YYYY, op.[apptdate]) as yr,
apptage,
case
	when sex = '1' then 'm'
	else 'f'
	end as sex,
'opAtt' as pod,
case
	when opRati.attendkey is not null then 'rati'
	else 'none'
	end as mitigatable,
COUNT(*) as activity


from [nhp_modelling].[outpatients] op

left outer join [StrategicWorking].[dbo].[sw_op_mitigatable_rationing] opRati
on op.attendkey = opRati.attendkey
and op.FYEAR = opRati.fyear

where

datepart(YYYY, op.[apptdate]) >= 2011
and datepart(YYYY, op.[apptdate]) <= 2019
and apptage is not null
and apptage <= 120
and sex is not null
and sex in ('1', '2')

group by

DATEPART(YYYY, op.[apptdate]),
apptage,
case
	when sex = '1' then 'm'
	else 'f'
	end,
case
	when opRati.attendkey is not null then 'rati'
	else 'none'
	end

union all



select 

DATEPART(YYYY, ed.[arrivaldate]) as yr,
activage,
case
	when sex = '1' then 'm'
	else 'f'
	end as sex,
'edAtt' as pod,
case
	when edReSu.aekey is not null then 'reSu'
	else 'none'
	end as mitigatable,
COUNT(*) as activity

from [nhp_modelling].[aae] ed

left outer join [StrategicWorking].[dbo].[sw_ed_mitigatable_redirect_substitute] edReSu
on ed.aekey = edReSu.aekey
and ed.fyear = edReSu.fyear

where

datepart(YYYY, ed.[arrivaldate]) >= 2011
and datepart(YYYY, ed.[arrivaldate]) <= 2019
and activage is not null
and activage <= 120
and sex is not null
and sex in ('1', '2')
and [aedepttype] in ('1', '01')

group by

DATEPART(YYYY, ed.[arrivaldate]),
activage,
case
	when sex = '1' then 'm'
	else 'f'
	end,
case
	when edReSu.aekey is not null then 'reSu'
	else 'none'
	end

