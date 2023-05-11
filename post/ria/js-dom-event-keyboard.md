---
title: js keyboard events
date: 2023-05-09
private: true
---
# js keyboard event
## command+s/ctrl+s

    document.addEventListener("keydown", function(e) {
        const isMacOSX = navigator.userAgent.match(/ Mac OS X /);
        if ((isMacOSX ? e.metaKey : e.ctrlKey)  && e.keyCode == 83) {
            e.preventDefault();
            // Process the event here (such as click on submit button)
        }
    }, false);

## keyborad event:
### keycode

    // deprecated
    event.keyCode === 13
    event.which === 13
    e.keyCode == e.which: 
         16-Shift, 17-Ctrl, 18-Alt
         1-click 3-right-click

    // recommended
    event.key === 'Enter'
    e.key vs e.code
        's', 'S' vs 'KeyS'
        'Shift' vs 'ShiftLeft', 'ShiftRight', 
    e.ctrlKey, e.altKey,e.metaKey(true/false)

### shortcuts

    command+s:
        e.metaKey&& e.key=='s'
        e.metaKey&& e.code=='KeyS'
    alt+s:
        e.altKey&& e.key=='Í'
        e.altKey&& e.code=='KeyS'
    ctrl+s:
        e.ctrlKey&& e.key=='s'
    command+shift+s:
        e.metaKey && e.shiftKey && e.key=='s'
    command + ctrl + shift + s:
        e.metaKey && e.ctrlKey && e.shiftKey && e.key=='s'
    command + ctrl + shift + alt + s:
        e.metaKey && e.ctrlKey && e.shiftKey e.altKey && e.key=='Í'
        e.metaKey && e.ctrlKey && e.shiftKey e.altKey && e.code=='KeyS'

key-repeat: 

    e.repeat: true

### global keydown handler

    //body.onkeydown = handler
    export function useSaveShortcut(graph: Graph) {
        const onSaveHandler = (e: KeyboardEvent) => {
            if ((isMacOSX() ? e.metaKey : e.ctrlKey) && e.code == 'KeyS') {
            e.preventDefault();
            saveWorkflowDef(graph);
            }
        };
        document.addEventListener("keydown", onSaveHandler, false);
        return () => {
            document.removeEventListener("keydown", onSaveHandler, false);
        };
    }

### keyEvent with textarea

    document.addEventListener('keydown', e=>{
        if (e.keyCode === 9 && e.target.tagName === 'TEXTAREA') {
           var target = e.target;   
            var start = target.selectionStart;   
            var end = target.selectionEnd;
            target.value=target.value.slice(0, start) + "\t" + target.value.slice(end);
            target.selectionStart = target.selectionEnd = start + 1;
            e.preventDefault();
        }
    })

### trigger event

	node.click();
	node.dbclick();
	node.mouserover();
	node.submit();

	//通用的方法
	Element.prototype.trigger = function (type, data) {
	　　var event = document.createEvent('HTMLEvents');
	　　event.initEvent(type, true, true);
	　　event.data = data || {};
	　　event.eventName = type;
	　　event.target = this;
	　　this.dispatchEvent(event);
	　　return this;
	};

	//NodeList 也可以用
	NodeList.prototype.trigger = function (event) {
	　　[]['forEach'].call(this, function (el) {
	　　　　el['trigger'](event);
	　　});
	　　return this;
	};

#### dispatchEvent

    var event = new Event('submit', {
        bubbles: true,
        cancelable: true
        });
    document.forms[0].dispatchEvent(event);

trigger resize:

    window.onresize=handler
    window.dispatchEvent(new Event('resize'));

