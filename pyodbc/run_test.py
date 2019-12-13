import sys
from os.path import isfile
print(sys.version)
print(sys.executable)

import pyodbc
print(pyodbc)

if sys.platform == 'darwin':
    driver_path = '/Users/ilan/a/envs/py38/lib/libsqlite3odbc.dylib'
elif sys.platform.startswith('linux'):
    driver_path = '/home/osboxes/bin/libsqlite3odbc-0.9996.so'
if not isfile(driver_path):
    raise Exception('so such file: %r' % driver_path)

connect_string = (
    "DRIVER={%s};SERVER=localhost;DATABASE=./test.sqlite;Trusted_connection=yes"
    % driver_path
)

cnxn = pyodbc.connect(connect_string)
cursor = cnxn.cursor()
try:
    cursor.execute('drop table foo')
except:
    pass
cursor.execute('create table foo (symbol varchar(5), price float)')
N = 1000
for i in range(N):
    cursor.execute("insert into foo (symbol, price) values (?, ?)",
                   (str(i), float(i)))
cursor.execute("commit")

cursor.execute("select * from foo")
dictarray = cursor.fetchdictarray()

cursor.close()

for i in range(N):
    assert dictarray['symbol'][i] == str(i)
    assert (dictarray['price'][i] - float(i)) < 1E-10
print("Done.")
