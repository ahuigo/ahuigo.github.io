---
title: ts extends example
date: 2022-09-23
private: true
---
# ts extends example

# NonNullable
    // type NonNullable<T> = T & {};

    type Name = null | undefined | string;

    // 👇️ type T2 = string
    type T2 = NonNullable<Name>;

## recursive nonNull

    type WithoutNullableKeys<Type> = {
      [Key in keyof Type]-?: WithoutNullableKeys<NonNullable<Type[Key]>>;
    };

    type Employee = {
      name?: string | null;
      country?: string | null;
      salary?: number | null;
    };

    // 👇️ type T1 = {
    //     name: string;
    //     country: string;
    //     salary: number;
    //    }
    type T1 = WithoutNullableKeys<Employee>;