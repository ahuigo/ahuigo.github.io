---
title: pg operator
date: 2022-03-29
private: true
---
# pg operator

## reverse like
    // create function reverse_like (text, text) returns boolean language sql as $$ select $2 like $1 $$;
    create or replace function reverse_like (text, text) returns boolean language sql as
    $$ select $2 like $1 $$ immutable parallel safe;

    create operator <~~ ( function =reverse_like, leftarg = text, rightarg=text );

    SELECT 'ab%' <~~ ANY('{"abc","def"}');
    SELECT not 'ab%' <~~ ALL('{"abc","def"}');