---
title: pg trigger
date: 2019-10-13
private: 
---
# PG trigger

## Add Trigger
### Add Update Trigger
create function

    CREATE OR REPLACE FUNCTION update_modified_column()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.modified = now(); 
        RETURN NEW;
    END;
    $$ language 'plpgsql';

Apply the trigger like this:

    CREATE TRIGGER update_customer_modtime BEFORE UPDATE ON customer FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

If you want Updating timestamp, only if the values changed

    IF row(NEW.*) IS DISTINCT FROM row(OLD.*) THEN
        NEW.modified = now(); 
        RETURN NEW;
    ELSE
        RETURN OLD;
    END IF;

### delete trigger

    CREATE TRIGGER delete_contacto 
    BEFORE DELETE ON cliente 
    FOR EACH ROW 
    EXECUTE PROCEDURE clienteDelete();

## Delete trigger

    DROP TRIGGER trigger_name ON films;