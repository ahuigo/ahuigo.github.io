---
title: antd form item
date: 2023-03-21
private: true
---
# antd form item
## item shoulUpdate 联动
demo: https://codesandbox.io/s/ji-ben-shi-yong-antd-4-22-5-forked-qk5yhj?file=/demo.js

    import { Form, Input } from "antd";

    const App = () => {
      const [form] = Form.useForm();
      const onClick=()=>{
        const username = form.getFieldValue("username")
        form.setFieldsValue({ username:username=="1"?"2":"1" });
      }

      return (
        <Form autoComplete="off" form={form}>
          <div onClick={onClick}>click</div>
          <Form.Item label="Username" name="username">
            <Input placeholder="Type '111'" />
          </Form.Item>
          <Form.Item noStyle shouldUpdate>
            {() => {
              console.log(form.getFieldValue("username"))
              return (
                <Form.Item
                  label="Password"
                  name="password"
                  rules={[
                    {
                      required: form.getFieldValue("username") === "111",
                      message: "Please input your password!"
                    }
                  ]}
                >
                  <Input />
                </Form.Item>
              );
            }}
          </Form.Item>

        </Form>
      );
    };

# ProForm
手动添加form item 项

    import { ProFormText, ProFormDatePicker, ProForm } from '@ant-design/pro-components';
    const onFinish = async (data: Params) => {
        await tosApi.addDef(data);
        message.success('successful!');
        history.back();
    };

    <ProForm<Params>
        request={async () => {
            const response = await getApi();
            return response;
          }}
          onFinish={onFinish}
    >
         <Col {...colSpan} md={12}>
              <ProForm.Item shouldUpdate noStyle>
                {(form) => (
                    <CustomInput label={form.getFieldValue('label')} />
                )}
              </ProForm.Item>
        </Col>