# regexp

  > select 'string or column' regexp 'key1|key2' ;
  1 or 0

## extract(hive only)

  select regexp_extract('1.2.3.4', '(\\d+\\.){2}\\d+', 0) from xxx
    1.2.3
  select regexp_extract('1.2.3.4', '(\\d+\\.){5}\\d+', 0) from xxx
  false
  regexp_extract(rid, '(?:re|ps\\d+),(\\d{8})',1);
  select regexp_replace;

## where regexp

    wehre rid regexp 'lc_ps(1|2)'

# length

    LENGTH()
    CHARACTER_LENGTH() is a synonym for CHAR_LENGTH().

# concat

    SELECT CONCAT(14.3);
        -> '14.3'
    SELECT CONCAT(14.3, column1, ...);
    SELECT CONCAT_WS(",", a, b,...);
        -> 'a,b,c'

## implode

    GROUP_CONCAT(uid ORDER BY uid DESC SEPARATOR ',')
    GROUP_CONCAT(uid SEPARATOR ',')
    GROUP_CONCAT(uid)

# TRIM()

# substr
SUBSTR() is a synonym for : SUBSTRING(str,pos,len). MID(str,pos,len).

      SUBSTR(str,pos,len)
        pos: `start from 1`, could be negative number
        len: none-negative
      SUBSTR('str00',1,-2); //wrong
      SUBSTR('str00',-2,2); //right
        00
      SUBSTR('str00',1, LENGTH('str00')-2); //right
        str


# length

  LENGTH
  CHAR_LENGTH

# trim

  LPAD(str,len,padstr)
  Ltrim(str)

# math

  round(double a, int d)
  round(double a)
  avg(column)
