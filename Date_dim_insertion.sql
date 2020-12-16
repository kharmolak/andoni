delete from dbo.[Date];

alter table dbo.[Date]
alter column [PersianMonthName] [nvarchar](max);

bulk insert dbo.[Date]
from 'E:\education files\db2\Project\Date.txt'
with
(
	fieldterminator = '\t',
	CODEPAGE = '65001'
);

