---
title: vim debug
date: 2022-04-21
private: true
---
# checkhealth
    :checkhealth

I run `:checkhealth` provider and found this error:

    ## Python 3 provider (optional)
    - INFO: Using: g:python3_host_prog = "/usr/local/bin/python3"
    - Error: Executable: /usr/local/bin/python3  not found

So I solved it by fix execute python path:

    sudo ln -s /opt/homebrew/opt/python@3.10/bin/python3 /usr/local/bin/python3