---
title: antd tabel
date: 2020-05-26
private: true
---
# antd table

# pagination

    <Table 
        onChange={onChange}
        rowKey={(row: any, i) => row.id}
        pagination={{ 
            current: page,
            pageSize: 20, //默认会分页
            showSizeChanger: false, //不切换页数
            total: pageTotal > 10000 ? 10000 : pageTotal,
        }}
        onChange={(pagination: any) => {
            setPage(pagination.current); //新page
        }}
        dataSource={data}
    />

## row key
        rowKey={(row: any, i) => `key${i}`}