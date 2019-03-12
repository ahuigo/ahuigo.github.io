---
title: Django Notes
date: 2019-03-11
---
# Models
## raw sql

    >>> lname = 'Doe'
    >>> first_person = Person.objects.raw('SELECT * FROM myapp_person WHERE last_name = %s', [lname])[0]
