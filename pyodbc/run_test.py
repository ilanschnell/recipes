import pyodbc

print(pyodbc)

s = ("DRIVER={/Users/ilan/a/envs/py38/lib/libsqlite3odbc.dylib};"
     "SERVER=localhost;DATABASE=./test.db;Trusted_connection=yes")

cnxn = pyodbc.connect(s)
cursor = cnxn.cursor()
try:
    cursor.execute('drop table foo')
except:
    pass
cursor.execute('create table foo (symbol varchar(5))')
uni = b'A\xe2\x98\x82c\xe2\x98\x85b'.decode('utf-8')
cursor.execute("insert into foo (symbol) values (?)", uni)

cursor.execute("select * from foo")
dictarray = cursor.fetchdictarray()

cursor.close()

print(dictarray['symbol'][0])
