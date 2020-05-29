---
title: Umi form 表单
date: 2019-11-12
private: true
---
# Umi form 表单
https://ant.design/components/form-cn/#components-form-demo-coordinated

    this.props.form
        setFieldsValue
        getFieldValue
        setFieldDecorator

form 不用state, 用form 值

      handleSelectChange = value => {
        console.log(value);
        this.props.form.setFieldsValue({
          note: `Hi, ${value === 'male' ? 'man' : 'lady'}!`,
        });
      };

# Input

    <Input
        placeholder="Basic usage"
        defaultValue="ahui"
        ref={(node: any) => {
            node.select()
            node.input.select()
        }}

## fieldset
    <div>
        <label for="username">Name: <abbr title="required" aria-label="required">*</abbr></label>
        <input id="username" type="text" name="username">
    </div>

    <fieldset>
        <legend>你的性别是：</legend>
        <p>
        <input type="radio" name="gender" id="male" value="male">
        <label for="male">男</label>
        </p>
        <p>
        <input type="radio" name="gender" id="female" value="female">
        <label for="female">女</label>
        </p>
    </fieldset>
