---
title: antd modal
date: 2020-06-09
private: true
---
# antd modal
    <Modal width="70%" visible={true} onCancel={onClose}
        okText="提交"
        cancelText="取消"
    >

top: 

    <Modal style={{ top: '0px' }}

按钮属性

    <Modal
          title="Basic Modal"
          visible={this.state.visible}
          onOk={this.handleOk}
          onCancel={this.handleCancel}

          okButtonProps={{ disabled: true }}
          cancelButtonProps={{ disabled: true }}
        >

隐藏按钮

      footer={null}