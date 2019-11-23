---
title: umi dva
date: 2019-11-23
private: true
---
# umi dva
https://github.com/dvajs/dva/issues/2140

dva 也可以用的:

    import { useSelector, useDispatch, } from 'react-redux';

    function MeanTime(props: any) {
        const productionEfficiency = useSelector((state: any) => state.productionEfficiency);
        const dispatch = useDispatch()