declare @fk varchar(max), @destinationTable varchar(max), @sourceTable varchar(max);
--set @fk = 'FK_TableSource_Target';
--set @destinationTable = 'T_SOSvcLog';
--set @sourceTable = 'T_UnitConditionLog';


with 
	cte_tables as (select t.[object_id], t.name from sys.tables t),
	cte_columns as (select c.[object_id], c.column_id, c.name from sys.columns c)
select 
	t1.name [ForeignKey],
	t2.name [ReferenceTo] into #TestTable 
from sys.foreign_keys fk
join cte_tables t1 on fk.parent_object_id = t1.object_id
join cte_tables t2 on fk.referenced_object_id = t2.object_id
join sys.foreign_key_columns fkc on fk.object_id = fkc.constraint_object_id
join cte_columns c1 on fkc.parent_column_id = c1.column_id and t1.object_id = c1.object_id
join cte_columns c2 on fkc.referenced_column_id = c2.column_id and t2.object_id = c2.object_id
where 
	fk.name = isnull(@fk, fk.name) and fk.[type] = 'F'
	and t1.name = isnull(@sourceTable, t1.name)
	and t2.name = isnull(@destinationTable, t2.name)
	and t2.name not like 'R%'

SELECT t.ReferenceTo, STUFF(
(SELECT ',' + s.ForeignKey
FROM #TestTable s
WHERE s.ReferenceTo = t.ReferenceTo
FOR XML PATH('')),1,1,'') AS CSV
FROM #TestTable AS t
GROUP BY t.ReferenceTo
GO

drop table #TestTable



--------------------------------------------------


select * from 
(
select TABLE_NAME,COLUMN_NAME from INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE 
where CONSTRAINT_NAME like 'PK%' 
and TABLE_NAME not like 'R%'
)a
join 
(
select TABLE_NAME,COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where DATA_TYPE = 'bigint' 
and TABLE_NAME not like 'R%'
)b
 on a.COLUMN_NAME = b.COLUMN_NAME 
and a.TABLE_NAME <> b.TABLE_NAME
order by 1,2,3,4



with 
	cte_tables as (select t.[object_id], t.name from sys.tables t),
	cte_columns as (select c.[object_id], c.column_id, c.name from sys.columns c)
select 
	
	t2.name Ptable ,c2.name Pcolumn , t1.name Ctable,c1.name Ccolumn 
from sys.foreign_keys fk
join cte_tables t1 on fk.parent_object_id = t1.object_id
join cte_tables t2 on fk.referenced_object_id = t2.object_id
join sys.foreign_key_columns fkc on fk.object_id = fkc.constraint_object_id
join cte_columns c1 on fkc.parent_column_id = c1.column_id and t1.object_id = c1.object_id
join cte_columns c2 on fkc.referenced_column_id = c2.column_id and t2.object_id = c2.object_id
where 
	fk.name =  fk.name and fk.[type] = 'F'
	and t1.name =  t1.name
	and t2.name =  t2.name
	and t2.name not like 'R%'

	order by 1,2,3,4
	 

	

