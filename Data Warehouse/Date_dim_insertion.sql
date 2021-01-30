delete from dbo.[Date];

-- Sajede
bulk insert dbo.[Date]
from 'E:\education files\db2\Project\Date.txt'
with
(
	fieldterminator = '\t',
	CODEPAGE = '65001'
);

-- Maryam 
bulk insert dbo.[Date]
from '\\VBOXSVR\Virtual_Share\DataBase2\andoni\Data Warehouse\Date.txt'
with
(
	fieldterminator = '\t',
	CODEPAGE = '65001'
);