---
layout: page
title:	rime 鼠须管输入法
category: blog
description:
---
# Preface
# todo
diy 处方

設定項速查手冊

# 输入方案定制说明
所有的输入方案都是以`*.schema.yaml`命名的,比如: `wubi_pinyin.schema.yaml`
一般, 我们可以直接修改`wubi_pinyin.schema.yaml` 定制出我们想要的功能, 但是这样做不方便升级(一旦升级, 这个文件就会被更新, 我们所做的设定就丢失了)

强烈建议, 新建立一个定制文件 `wubi_pinyin.custom.yaml`, 然后在里面以patch 补丁的形式, 定制我们所需的功能. 所有方案对应的补丁名都是`<方案名>.custom.yaml`

	patch:
	  "一級設定項/二級設定項/三級設定項": 新的設定值
	  "另一個設定項": 新的設定值
	  "再一個設定項": 新的設定值

`default.custom.yaml` 中的default不是方案名, 而是全局设定名. 编译输入法时,`default.yaml`的生成会依赖于它.
如果我们想让设定作用于所有的输入方案, 就用default.custom.yaml, 如果想让设定作用于特定的输入方案wubi_pinyin, 就用 *wubi_pinyin.custom.yaml*

以下罗列一些常用的设定, 如果没有特别的说明, 方案设定和全局设定均适用.

# 输入法列表
这个需要写在全局设定中: `default.custom.yaml`

	patch:
	  schema_list:
		- schema: hello
		- schema: wubi_pinyin
		- schema: pinyin_simp

# 字体
字体属于style, 只能在方案设定 或者 squirrel.yaml 中设置

	patch:
		"style/font_face": "明兰"  # 字體名稱，從記事本等處的系統字體對話框裏能看到
		"style/font_point": 14     # 字號，只認數字的，不認「五號」、「小五」這樣的

# 在特定程序中关闭中文输入
例如，要在 Xcode 裏面默認關閉中文輸入，又要在 Alfred 裏面恢復開啓中文輸入，可如此設定：  example squirrel.custom.yaml

		patch:
			app_options/com.apple.Xcode:
				ascii_mode: true
			app_options/com.alfredapp.Alfred: {}

註：一些版本的 Xcode 標識爲 com.apple.dt.Xcode，請注意查看 Info.plist。

# 快捷键

 按键定义 按鍵定義的格式爲`「修飾符甲+修飾符乙+…+按鍵名稱」`，加號爲分隔符，要寫出。

Shift
Control
Alt	Windows上 Alt+字母 會被系統優先識別爲程序菜單項的快捷鍵，當然 Alt+Tab 也不可用
Super 属于linux/unix 按键

其他的按鍵名稱參考這裏 [X11/keysymdef.h](https://github.com/lotem/librime/blob/develop/thirdparty/include/X11/keysymdef.h) 的定義，去除代碼前綴 XK_ 即是。


## 定製喚出方案選單的快捷鍵
下列代码实现了 `Ctrl+s` `F4` ``ctrl+` `` 换出方案选单

	# default.custom.yaml
	patch:
		"switcher/hotkeys":  # 這個列表裏每項定義一個快捷鍵，使哪個都中
			- "Control+s"      # 添加 Ctrl+s
			- "Control+grave"  # 你看寫法並不是 Ctrl+` 而是與 IBus 一致的表示法
			- F4


## 上屏
如果需要shift 上屏输入码和文字:
可以写到全局设定中

	patch:
	  ascii_composer/switch_key:
			Shift_L: commit_code
			Shift_R: commit_text

可選的切換策略：

- inline_ascii 在輸入法的臨時西文編輯區內輸入字母、數字、符號、空格等，回車上屏後自動復位到中文
- commit_text 已輸入的候選文字上屏並切換至西文輸入模式
- commit_code 已輸入的編碼字符上屏並切換至西文輸入模式
- 設爲 noop，屏蔽該切換鍵

## 翻页键
翻页键的定制使用的是key_binder：

	key_binder:
		bindings:
			# commonly used paging keys
			- { when: composing, accept: ISO_Left_Tab, send: Page_Up }
			- { when: composing, accept: Shift+Tab, send: Page_Up }
			- { when: composing, accept: Tab, send: Page_Down }
			- { when: has_menu, accept: minus, send: Page_Up }
			- { when: has_menu, accept: equal, send: Page_Down }
			- { when: paging, accept: comma, send: Page_Up }
			- { when: has_menu, accept: period, send: Page_Down }
			- { when: paging, accept: bracketleft, send: Page_Up }
			- { when: has_menu, accept: bracketright, send: Page_Down }

- when: 有几种种状态: composing, has_menu, paging
- accept 控制接受的按键：minus, equal, period, comma, bracketleft, bracketright
- send 控制动作：Page_Up, Page_Down, Escape(清空输入码)

# translator

## 关闭词语调频

	# wubi86.custom.yaml
	patch:
		translator/enable_completion: false
		translator/enable_sentence: false #关闭输入法连打 用于屏蔽倉頡、五筆中帶有太極圖章「☯」的連打詞句選項
		abc_segmentor/extra_tags: {} #敲 ` 之後輸入拼音：



# switches 模式转换
rime的将:全角半角、中文西文、简繁体都列为 switches 了。


	patch:
		switches:
		  - name: ascii_mode
			reset: 0 #0表示默认使用中文，1则是默认使用西文
			states: [ 中文, 西文 ]
		  - name: full_shape
			states: [ 半角, 全角 ]
		  - name: simplification    # 轉換開關
			states: [ 漢字, 汉字 ]

# 反查

	#wubi86.custom.yaml
	recognizer/patterns/reverse_lookup:"`[a-z]*'?$"
	reverse_lookup:
		dictionary: pinyin_simp
		preedit_format:
			- "xform/([nl])v/$1ü/"
			- "xform/([nl])ue/$1üe/"
			- "xform/([jqxy])v/$1u/"
		prefix: "`"
		suffix: "'"
		tips: "〔拼音〕"

# 组件
switches 转换只是用于设定模式的状态， 真正起使用的是组件：engine/punctuator

- engine 会根据不同的switches-simplification 状态 调用字体转换组件
- punctator 会根据不同的switches-full_shape 调用不的的punctuator 标点转换组件

# engine 引擎
当`switch-simplification` 为简体字时, engine 就需要调用`engine/filters`中的简体字过滤组件`simplifer` 以及去重组件`uniquifier`

		engine:
		  filters:
			- simplifier  # 必要組件一(简体)
			- uniquifier  # 必要組件二(去重)

## 标点
标点组件的名字叫:punctator

	patch:
		punctuator:
		  import_preset: default #引入默认的标点符号表
		  full_shape:		#作用于全角时
			"/" : "、"
		  half_shape:		#作用于半角时
			"/" : "、"

如果想完全用第三方的符号表代替, 比如alternative.yaml, 则:

	patch:
		"punctator/import_preset": alternative


# 关于词

## 候选数
	patch:
	  "menu/page_size": 9

## pageup/pagedown 字词翻页

如果需要用`[]`实现翻页，Edit *.custom.yaml

	patch:
	  "key_binder/bindings":
		- { when: paging, accept: bracketleft, send: Page_Up }
		- { when: has_menu, accept: bracketright, send: Page_Down }

## 刪除誤上屏的錯詞
不慎上屏了錯誤的詞組，再打同樣的編碼時，那錯詞出現在候選欄。這時候可以：

先把選字光標（用上、下鍵）移到要刪除的用戶詞組上，再按下 Shift+Delete 或 Control+Delete（蘋果鍵盤用 Shift+Fn+Delete）。

只能夠從用戶詞典中刪除詞組。用於碼表中原有的詞組時，只會取消其調頻效果。

# 備份及合併詞典快照
Rime 輸入法在使用中會在一定時間自動將用戶詞典備份爲快照文件 *.userdb.txt

# reverse lookup 反查
通过``` ``实现输入法反查. 这个在wubi_pinyin.schema.yaml中默认了

	reverse_lookup:
	  dictionary: pinyin_simp
	  prefix: "`"

# 引入码表
如果你想引入其它来源的码表(比如my_pinyin.dict.yaml), 在输入方案中*.schema.ymal 或者 输入方案对应的*.custom.ymal 中, 增加此码表就好了:

    translator:
      dictionary: my_pinyin

# Rime 中的數據文件分佈及作用
除程序文件以外，Rime 還包括多種數據文件。 這些數據文件存在於以下位置：

共享資料夾

    【中州韻】 /usr/share/rime-data/
    【小狼毫】 "安裝目錄\data"
    【鼠鬚管】 "/Library/Input Methods/Squirrel.app/Contents/SharedSupport/"

用戶資料夾

    【中州韻】 ~/.config/ibus/rime/ （0.9.1 以下版本爲 ~/.ibus/rime/）
    【小狼毫】 "%APPDATA%\Rime"
    【鼠鬚管】 ~/Library/Rime/

共享資料夾包含預設輸入方案的源文件。 這些文件屬於 Rime 所發行軟件的一部份，在訪問權限控制較嚴格的系統上對用戶是只讀的，因此謝絕軟件版本更新以外的任何修改—— 一旦用戶修改這裏的文件，很可能影響後續的軟件升級或在升級時丟失數據。

在「部署 Rime」操作時，將用到這裏的輸入方案源文件、並結合用戶定製的內容來編譯預設輸入方案。

用戶資料夾則包含爲用戶準備的內容，如：

	〔全局設定〕 default.yaml (编译输入法时基于default.custom.yaml 产生)
	〔發行版設定〕 weasel.yaml(不一定有)
	〔預設輸入方案副本〕 <方案標識>.schema.yaml
	※〔安裝信息〕 installation.yaml
	※〔用戶狀態信息〕 user.yaml

編譯輸入方案所產出的二進制文件：

	〔Rime 棱鏡〕 <方案標識>.prism.bin
	〔Rime 固態詞典〕 <詞典名>.table.bin
	〔Rime 反查詞典〕 <詞典名>.reverse.bin

記錄用戶寫作習慣的文件：

	※〔用戶詞典〕 <詞典名>.userdb.kct
	※〔用戶詞典快照〕 <詞典名>.userdb.txt、<詞典名>.userdb.kct.snapshot 見於同步文件夾

以及用戶自己設定的(通过这些设定,我们可以定制出想要的功能)：

	※〔用戶對全局設定的定製信息〕 default.custom.yaml
	※〔用戶對預設輸入方案的定製信息〕 <方案標識>.custom.yaml
	※〔用戶自製輸入方案〕(*.schema.yaml) 及配套的詞典源文件(*.dict.yaml)

> 註：以上標有 ※ 號的文件，包含用戶資料，您在清理文件時要注意備份！

# Reference

[rime 定制指南]: https://code.google.com/p/rimeime/wiki/CustomizationGuide
