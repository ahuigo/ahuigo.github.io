---
title: Umi form 表单
date: 2019-11-12
private: true
---

# Umi form 表单

    <Form layout="inline" ... >

# 取值

    form  = use
    form.getFieldValue("key")
    form.getFieldsValue()
    const data = form.getFieldsValue();

# 写值

## forceRender

写值不会触发update, 除非手动：

    const forceUpdate = React.useReducer(() => ({}))[1];

## 初值

    <Form initialValues={{ type: defaultType }} onFinish={onFinish} form={form}>

或：

    const [form] = Form.useForm();
    useEffect(() => {
        form.setFieldsValue({ type: defaultType });
    }, []);

或

    <Select defaultValue={86400} >

### OnFieldsChange 写值

Store Form Data into Upper Component

    // const initFields = Object.entries(def).map((item) => ({name:item[0],value:item[1]}))
    // 官方好像自带 setFields
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

## 更新field
Note:

    必须用匹配的`<Form.Item> attr`注册attr后， 才能修改值
    或者用：
    form.getFieldDecorator('fieldName', { initialValue: your_value })

用 setFieldsValue:

    <input 
        onChange={(e)=>form.setFieldsValue({name:e.target.value}}}
        value={form.getFieldValue('name')}
    >

或 setFields

    form.setFields([{name:"age", value:1}])

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

## getFieldDecorator 存取值

> 推荐用v4的form.Item 代替 getFieldDecorator: https://ant.design/components/form/v3

建立Input 与form 之间的数据响应

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

## required 值

    <Form.Item 
        label="密码" name="password" 
        rules={[{ required: true, message: 'input password !', type:'string' }]}
    >

## 复合数据结构

    // data = {props: {title: "news1"}[] }
    <Form.Item name={['props', 0, 'title']}>
        <Input placeholder="请输入规格名称" />
    </Form.Item>

## Item会透传 onChange/value

    <Form.Item label="Alert.reminders" name={["alert", "reminders"]}>
        <SelectUsers
            defaultValue={def.alert.reminders || [""]}
            onChange={(v: any) => null}
        />
    </Form.Item>

## 多个Item合并一行
        <div className={styles.flexItems}>
          <Form.Item label="Alert.enable" name={["alert", "enable"]}>


# Input

自动激活

    <Input
        placeholder="Basic usage"
        defaultValue="ahui"
        maxLength={25} {/*无效*/}
        style={{ width: "300px" }} 
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


# layout

## form class

no wrap

    <Form className="flex" >

## Input width

    <Input style={{ width: '20%' }} defaultValue="0571" />

## 列宽度

labelCol, wrapperCol 分别控制label/Item 的宽度

    const layout = {
        labelCol: { span: 8 },
        wrapperCol: { span: 16 },
    };
    const tailLayout = {
        wrapperCol: { offset: 8, span: 16 },
    };

    <Form {...layout} >
      <Form.Item {...tailLayout} name="remember" valuePropName="checked">
        <Checkbox>Remember me</Checkbox>
      </Form.Item>
    </Form>

## Input Row

https://ant.design/components/input/

    <Input.Group size="large">
      <Row gutter={8}>
        <Col span={5}>
          <Input defaultValue="0571" />
        </Col>
        <Col span={8}>
          <Input defaultValue="26888888" />
        </Col>
      </Row>
    </Input.Group>

compact:

    <Input.Group compact>
      <Input style={{ width: '20%' }} defaultValue="0571" />
      <Input.Search style={{ width: '30%' }} defaultValue="26888888" />
    </Input.Group>
