---
title: antd select onsearch
date: 2022-10-26
private: true
---

# antd table

## show search
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