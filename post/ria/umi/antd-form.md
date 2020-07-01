---
title: Umi form 表单
date: 2019-11-12
private: true
---
# Umi form 表单

    <Form
        layout="inline" ...
    >

# 存值

## 初值
    <Form initialValues={{ type: defaultType }} onFinish={onFinish} form={form}>

或：

    const [form] = Form.useForm();
    useEffect(() => {
        form.setFieldsValue({ type: defaultType });
    }, []);

## fields 存值
Store Form Data into Upper Component

    // const initFields = Object.entries(def).map((item) => ({name:item[0],value:item[1]}))
    const [fields, setFields] = useState([{ name: 'username', value: 'Ant' }]);

    return <Form
      name="global_state"
      layout="inline"
      fields={fields}
      onFieldsChange={(changedFields, allFields) => {
        setFields(allFields);
      }}
    >
      <Form.Item
        name="username"
        label="Username"
        rules={[{ required: true, message: 'Username is required!' }]}
      >
        <Input />
      </Form.Item>
    </Form>

## formInstance 存值
可以通过formInstance, 建立Input 与form 之间的数据响应

    const LoginForm = () => {
        const form = Form.useform({
            onValuesChange: () => console.log('Value changes'),
        });
        useEffect(()=>{
            form.setFieldsValue({username:'hilo'})
        })
        const { getFieldDecorator, validateFields } = form;
        return (
            <Form onSubmit={handleSubmit}>
                <Form.Item>
                    {getFieldDecorator('userName')(<Input placeholder="Username" />)}
                </Form.Item>
            </Form>
        );
    };



# 更新field
## 手动更新field
Item: 用setFieldsValue

    <input 
        onChange={(e)=>form.setFieldsValue({name:e.target.value}}}
        value={form.getFieldValue('name')}
    >

## via decorator item
    {getFieldDecorator('labels', {
        rules: [
            {
                required: true,
                message: '请选择标签',
                type: 'array',
            },
        ],
    })(<Input/>)

## via Form.Item

      <Form.Item
        name="username"
        label="Username"
        rules={[{ required: true, message: 'Username is required!' }]}
      >
        <Input/>

## 监听所有field
可用Form的onFieldsChange 监听变化

    <Form
        onFieldsChange={(changedFields, allFields) => {
            form.setFieldsValue(allFields);
        }}
    >

## onSubmit(e)/onFinish(data)
    <Form onSubmit={ (e) => {
        e.preventDefault();
    }} >

或者只监听数据data:

    <Form 
        onFinish={(data)=>console.log(data)}

还可以通过 form 得到data

    const data = form.getFieldsValue()

# Input
自动激活

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
