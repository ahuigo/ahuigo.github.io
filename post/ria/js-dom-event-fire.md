---
title: fire event
date: 2023-02-02
private: true
---
# event
## create event
    const eventAwesome = new CustomEvent('awesome', {
        bubbles: true,
        detail: { text: () => textarea.value }
    });
## dispatchEvent

    //mouseenter->  moverover->mouseleave
    //mouseup -> mousedown
    const mu= new Event('mouseover',{bubbles:true});
    $0.dispatchEvent(mu);

## link event
   link.click();

# example
## receive inject.js event 
Refer: https://stackoverflow.com/questions/9602022/chrome-extension-retrieving-global-variable-from-webpage/9636008#9636008

document_end.js ("run_at": "document_end" in manifest):

    var s = document.createElement('script');
    s.src = chrome.extension.getURL('inject.js');
    (document.head||document.documentElement).appendChild(s);
    s.onload = function() {
        s.remove();
    };

    // Event listener
    document.addEventListener('RW759_connectExtension', function(e) {
        alert(e.detail);
    });

inject.js - Located in the extension directory, this will be injected into the page itself:

    setTimeout(function() {
        // send message: detail
        document.dispatchEvent(new CustomEvent('RW759_connectExtension', {
            detail: "some details", 
        }));
    }, 0);