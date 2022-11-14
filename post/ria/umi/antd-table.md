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

与地址联动:

    pagination={{
        current: +(location.search.parseStr().page || 1),
        pageSize, //默认会分页
        showSizeChanger: false, //不切换页数
        // total: total,
    }}
    onChange={(pager: any) => {
        console.log(pager.current);
        const search = window.location.search.addParams({ page: pager.current });
        history.push(search);
        // window.history.pushState(null, "", search);
        // forceUpdate();
    }}

## footer

    -- <Table pagination={{ size: "small" }}/>
    <Table 
      columns={columns}
      data={data}
      footer={() => 
        <TableFooter />
      }

## no pagination

    pagination={false}

## row key

    rowKey={(row: any, i) => `key${i}`}

## 宽度自适应

    <Table
      bordered
      // scroll={{ y: 1000 }}
      scroll={{ x: 'max-content' }}
      ...

同时column 设置宽度

    {
      title: '资源',
      dataIndex: 'resources',
      width: '300px',
