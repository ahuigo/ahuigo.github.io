---
title: antd tabel
date: 2020-05-26
private: true
---
# antd table

# pagination

    const pager = {
        current: page,
        pageSize: 20, //默认会分页
        showSizeChanger: false, //不切换页数
        total: pageTotal > 10000 ? 10000 : pageTotal,
    };

    const onChange = (pagination: any) => {
        setPage(pagination.current); //新page
    };

    <Table 
        onChange={onChange}
        pagination={pager}
        onChange={onChange}
        rowKey={(row: any, i) => row.id}
        pagination={pager}
        dataSource={data}
    />