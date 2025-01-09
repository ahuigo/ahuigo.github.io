试了几个办法，没有确定原因：
1. 重新安装最新版vscode　问题依旧

2. 用二分法插件禁用法排查太费时间了(`> Start Extension Bisect`)，因为要运行很久（数小时不等）才会逐渐变得世卡。

3. 通过查看插件资源占用（`> show running extensions`）看不出来有啥明显异常.

最后忍受不了清理所有的vscode 缓存配置＋重装，运行了一天多没见卡。

```
    # 1. 备份＋清理
    mv ~/Library/Application\ Support/{Code,code_bak}
    # 备份扩展清单
    ls ~/.vscode/extensions/ > ~/vsc.extension-list.txt
    # 清理所有的扩展
    rm -rf ~/.vscode/extensions/

    # 2. 重新打开vscode、安装扩展（只安装了目前需要的插件）
    略

    # 3. 只还原了User下的：keybindings.json, settings.json, snippets
    mv ~/Library/Application\ Support/code_bak/User/{{settings,keybindings}.json,snippets}  ~/Library/Application\ Support/Code/User/
　　
```

应该是缓存、配置、插件的原因导致的，不想继续花精力排查了。

遇到类似的情况v2er 可以试着清理一下缓存和配置试一下.
