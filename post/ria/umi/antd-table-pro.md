---
title: antd pro table
date: 2023-10-20
private: true
---
# antd pro table
example
```
interface DataItem{
    id:number;
}
// request 参数
interface Params{
    page: number;
    name?: string;
}
return <ProTable<DataItem, Params>
        bordered
        className="m-2"
        columns={columns}
        form={{
          syncToUrl: (values, type) => {
            if (type === 'get') {
              const beginTs = values.beginTs ? parseInt(values.beginTs) : undefined;
              const endTs = values.endTs ? parseInt(values.endTs) : undefined
              return {
                ...values,
                has_error: values.has_error ?? default_has_error,
                created_at: [beginTs, endTs],
              }
            }
            return values;
          },
          labelCol: {
            flex: "6rem",
          },
        }}
        search={{
          collapsed: false,
          collapseRender: false,
          span: 6,
          optionRender: ({ searchText, resetText }, { form }) => {
            return [
              <>
                <ProFormSwitch
                  key="has_error"
                  name="has_error"
                  label="是否有错误"
                  fieldProps={{
                    defaultChecked: default_has_error,
                    onChange: (checked) => {
                      form?.setFieldValue('has_error', checked);
                    },
                  }}
                />
                <Button type="primary" onClick={() => form?.submit()}>
                  {searchText}
                </Button>
                <Button onClick={() => form?.resetFields()}>{resetText}</Button>
              </>,
            ];
          }
        }}
        scroll={{
          x: 1200,
        }}
        dateFormatter="number"
        request={async (params) => {
          const {data, total} = await mpushAPI.getMonitorFailList({
            pageSize: params.pageSize,
            page: params.current,
            topic: params.topic,
            has_error: params.has_error,
            response_code: params.response_code,
            begin_time: params.beginTs ? new Date(params.beginTs).format() : undefined,
            end_time: params.endTs ? new Date(params.endTs).format() : undefined,
          });
          return {
            success: true,
            data,
            total,
          }
        }}
        rowKey="id"
      />

```

## form initialValues

    form={{
        syncToUrl: (values, type) => {
            if (type === 'get') {
                return {...values, ...initialValues}
            }
        }
    }}

## request mock data
    request={async () => ({
        success: true,
        data: [
            {
              id: 624748504,
              number: 6689,
              title: '🐛 [BUG]yarn install命令 antd2.4.5会报错',
          ],
        })}

