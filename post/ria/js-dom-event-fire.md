---
title: fire event
date: 2023-02-02
private: true
---
## create event
    const eventAwesome = new CustomEvent('awesome', {
        bubbles: true,
        detail: { text: () => textarea.value }
    });
## dispatchEvent

    //mouseenter->  moverover->mouseleave
    //mouseup -> mousedown
    const mo= new Event('mouseover',{bubbles:true});
    whateverElement.dispatchEvent(mo);
