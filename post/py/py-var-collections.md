# named tuples

    # Old testmod return value
    doctest.testmod()
    # (0, 4)

Better Clarify multiple return values with named tuples

    doctest.testmod()
    # TestResults(failed=0, attempted=4)

A namedTuple is a subclass of tuple


    TestResults = namedtuple('TestResults', ['failed', 'attempted'])

    >>> # Basic example
    >>> Point = namedtuple('Point', ['x', 'y'])
    >>> p = Point(11, y=22)     # instantiate with positional or keyword arguments
    >>> p[0] + p[1]             # indexable like the plain tuple (11, 22)
    33
    >>> x, y = p                # unpack like a regular tuple
    >>> x, y
    (11, 22)
    >>> p.x + p.y               # fields also accessible by name
    33
    >>> p                       # readable __repr__ with a name=value style
    Point(x=11, y=22)

## NamedTuple._make
- NamedTuple._make(list)
- NamedTuple(`**dict`)
- NamedTuple(`*args, **kw`)

Named tuples are especially useful for assigning field names to result tuples returned by the csv or sqlite3 modules:

    EmployeeRecord = namedtuple('EmployeeRecord', 'name, age, title, department, paygrade')

    import csv
    for emp in map(EmployeeRecord._make, csv.reader(open("employees.csv", "rb"))):
        print(emp.name, emp.title)

    import sqlite3
    conn = sqlite3.connect('/companydata')
    cursor = conn.cursor()
    cursor.execute('SELECT name, age, title, department, paygrade FROM employees')
    for emp in map(EmployeeRecord._make, cursor.fetchall()):
        print(emp.name, emp.title)

init:

    >>> d = {'x': 11, 'y': 22}
    >>> Point(**d)
    Point(x=11, y=22)
    >>> Point._make([11,22])
