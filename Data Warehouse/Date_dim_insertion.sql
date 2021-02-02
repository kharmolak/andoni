delete from dbo.[dimDate];

-- Sajede
bulk insert dbo.[dimDate]
from 'E:\education files\db2\Project\Date.txt'
with
(
	fieldterminator = '\t',
	CODEPAGE = '65001'
);

-- Maryam 
bulk insert dbo.[dimDate]
from '\\VBOXSVR\Virtual_Share\DataBase2\andoni\Data Warehouse\Date.txt'
with
(
	fieldterminator = '\t',
	CODEPAGE = '65001'
);
