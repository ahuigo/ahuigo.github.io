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