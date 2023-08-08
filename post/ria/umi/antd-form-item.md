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

