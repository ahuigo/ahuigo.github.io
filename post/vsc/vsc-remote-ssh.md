---
title: vscode remote ssh
date: 2020-06-02
private: true
---
# vscode remote ssh
doc: https://code.visualstudio.com/docs/remote/ssh

## Connect SSH
- install https://code.visualstudio.com/docs/remote/ssh extension
- Press `Cmd+shift+p`,type:`Remote-SSH: Connect to Host...`, 
type `ssh user@192.168.x.x -A`
- Select `~/.ssh/config` to add ssh host to it.
- Check: see a detailed log in the **Remote - SSH** output channel.

disconnect:
- Close Host: choose **File > Close Remote Connection** to disconnect from the host.

## install extension
Install extension like go/deno/copilot, etc. 

## Open dir(project)
open project:
- Open: Press `cmd+o` to open dir