---
title: antd form upload
date: 2023-02-21
private: true
---
# antd form upload

    import React, { useState } from "react";
    import { Select } from "antd";
    import { UploadOutlined } from '@ant-design/icons';
    import type { UploadProps } from 'antd';
    import { Button, message, Upload } from 'antd';
    import type { UploadChangeParam } from 'antd/lib/upload';
    import type { UploadFile } from 'antd/lib/upload/interface';
    
    type File = UploadChangeParam<UploadFile<any>>;
    
    interface Props {
      title: string;
      onChange?: (value: File) => void;
    }
    function InputFile({
      title,
      onChange,
    }: Props) {
      const props = { onChange: onChange! };
      return <Upload {...props}>
        <Button icon={<UploadOutlined />}>{title}</Button>
      </Upload>;
    }

    <Form.Item 
        name="device_list" label="上传" 
        getValueFromEvent={(e) => {
            return e.fileList && e.fileList[0];
        }}
    >
        <InputFile title="点击上传" />
    </Form.Item>