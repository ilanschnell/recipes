import sys
print(sys.version)
print(sys.executable)

import pyodbc
print(pyodbc)

s = ("DRIVER={/home/osboxes/bin/libsqlite3odbc-0.9996.so};"
     "SERVER=localhost;DATABASE=./test.sqlite;Trusted_connection=yes")

cnxn = pyodbc.connect(s)
cursor = cnxn.cursor()
try:
    cursor.execute('drop table foo')
except:
    pass
cursor.execute('create table foo (symbol varchar(5))')
cursor.execute("insert into foo (symbol) values (?)", "Hello")

cursor.execute("select * from foo")
dictarray = cursor.fetchdictarray()

cursor.close()

print(dictarray['symbol'][0])
assert dictarray['symbol'][0] == "Hello"
