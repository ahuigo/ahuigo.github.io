---
title: ts object type
date: 2023-03-21
private: true
---
# ts object type

## Modify(extends override)
    type Modify<T, R> = Omit<T, keyof R> & R;

    // before typescript@3.5
    type Modify<T, R> = Pick<T, Exclude<keyof T, keyof R>> & R

usage:

    type ModifiedType = Modify<OriginalType, {
      a: number;
      b: number;
    }>
    
    interface ModifiedInterface extends Modify<OriginalType, {
      a: number;
      b: number;
    }> { }
