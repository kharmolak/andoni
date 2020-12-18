delete from dbo.[Date];

bulk insert dbo.[Date]
from 'E:\education files\db2\Project\Date.txt'
with
(
	fieldterminator = '\t',
	CODEPAGE = '65001'
);

