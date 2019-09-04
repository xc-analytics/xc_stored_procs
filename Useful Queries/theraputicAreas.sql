USE [Xcenda_DW]
GO

IF OBJECT_ID('tempdb..#thera') IS NOT NULL
BEGIN
    DROP TABLE #thera
END

create table #thera ([Project Code] [varchar](20), 
[Theraputic] [varchar] (30),
[Second Theraputic] [varchar] (30));

-- this is created via excel, no need to upload and drop a table
insert into #thera 
values ('GSK0612191', 'Oncologic_Disorders', 'Multiple Myeloma'),
('HZN0625191', 'Eye_Disorders', 'Other'),
('AZ0430191', 'Oncologic_Disorders', 'Lung Cancer'),
('NOV0619191', 'Neurologic_Disorders', 'Headache Disorders '),
('CC19HEMATO', 'Hematologic_Disorders', 'Other')

select * from #thera

/*
update [dimProjectPhase]
set [Project PrimaryTherapeuticArea1] = a.[Theraputic]
FROM #thera a
where [dimProjectPhase].[Project Code] = a.[Project Code]

update [dimProjectPhase]
set [Project PTA1_SecondaryTherapeuticArea1] = a.[Second Theraputic]
FROM #thera a
where [dimProjectPhase].[Project Code] = a.[Project Code]
*/

--this is a check against what was just added, 
select distinct
[Project Code],
[Project PrimaryTherapeuticArea1],
[Project PTA1_SecondaryTherapeuticArea1] 
from [dimProjectPhase]
where [Project Code] in ('GSK0612191',
'HZN0625191',
'AZ0430191',
'NOV0619191',
'CC19HEMATO')