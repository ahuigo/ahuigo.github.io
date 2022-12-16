---
title: antd select onsearch
date: 2022-10-26
private: true
---

# select

## multiple

    <Select mode="multiple">

## allowClear

    <Select allowClear>

## allow input

    const handleSelectStatus= (newValue: string) => {
        if (newValue) {
            options.push({ name: newValue })
            setOptions(statusDefList.unique())
        }
    };
    <Select 
    showSearch
    onSearch={handleSearch}>
        {options.map((def, i) => {
            return ( <Option key={i} value={def.name}> {def.name} </Option>);
        })}

## filter

filter key and value "children"

    <Select
        showSearch
        optionFilterProp="children"

        onSearch={onSearch}
        // 自定义搜索函数
        filterOption={(input, option) =>  
            option.props.children.toLowerCase().indexOf(input.toLowerCase()) >= 0 
            || option.props.value.toLowerCase().indexOf(input.toLowerCase()) >= 0
        }
    >
        {person.map(p => <Option value={p.username}>{p.displayName}</Option>)}
    </Select>

# show search
    <Select
        showSearch
        onSearch={handleSelectStatus}
        // onChange={handleSelectStatus}
        style={{ width: '350px' }}
        filterOption={true}
    >
        <Option value="" key="all">
        All
        </Option>
    </Select>

## onKeyDown(onKeyPress)
        <Select
          showSearch
          defaultValue={jql}
          key={jql}
          // onSearch={handleSelectStatus}
          onChange={(jql) => {
            setJql(jql)
          }}
          placeholder='Jira Jql: project = "Mpilot Highway Test"'
          style={{ width: '80%' }}
          filterOption={true}
          onKeyDown={(e:any) =>{
            console.log(e.target.value)
            if (e.keyCode == 13) {
              console.log(e.target.value)
              setJql(e.target.value)
            }
          }}
        >