---
title: ts union assert
date: 2023-03-30
private: true
---
# ts union assert
## 直接断言
    function isFish(pet: Fish | Bird): pet is Fish {
        return (pet as Fish).swim !== undefined;
    }
    if (isFish(pet)) {
        pet.swim();
    } else {
        pet.fly();
    }

## 通过属性断言
https://stackoverflow.com/questions/68708331/get-type-of-typescript-union-field

    type Option1 = {
        items: string[];
    }
    type Option2 = {
        delete: true;
    }
    type Combined = Option1 | Option2;

    type Keys = keyof Combined; // never

    const hasProperty = <Obj, Prop extends string>(obj: Obj, prop: Prop)
        : obj is Obj & Record<Prop, unknown> =>
        Object.prototype.hasOwnProperty.call(obj, prop);

    const handle = (union: Combined) => {
        if (hasProperty(union, 'items')) {
            const option = union; // Option1
        } else {
            const option = union; // Option2
        }

    }

Or you can add common property:

    type Option1 = {
        tag: '1',
        items: string[];
    }
    type Option2 = {
        tag: '2',
        delete: true;
    }
    type Combined = Option1 | Option2;

    type CommonProperty = Combined['tag'] // "1" | "2"

    const handle = (union: Combined) => {
        if(union.tag==='1'){
            const option = union // Option1
        }
    }

Another, alternative way is to use StrictUnion.

    type Option1 = {
        items: string[];
    }
    type Option2 = {
        delete: true;
    }
    type Combined = Option1 | Option2;

    // credits goes https://stackoverflow.com/questions/65805600/type-union-not-checking-for-excess-properties#answer-65805753
    type UnionKeys<T> = T extends T ? keyof T : never;
    type StrictUnionHelper<T, TAll> =
        T extends any
        ? T & Partial<Record<Exclude<UnionKeys<TAll>, keyof T>, never>> : never;

    type StrictUnion<T> = StrictUnionHelper<T, T>

    type Union = StrictUnion<Combined>

    const items_variable: Union['items'] = ["a", "b"]; // string[] | undefined