---
title: umi css
date: 2019-11-12
private: true
---
# umi css
# 组件class 覆盖
一般用style=xxx 覆盖就可以了。

比如我们如果想覆盖overrid-ant-btn 子组件

    .override-ant-btn {
        :global(.ant-btn) {
            border-radius: 16px;
        }
    }

    <Parent className={styles.override-ant-btn}>
        <Btn className="ant-btn">