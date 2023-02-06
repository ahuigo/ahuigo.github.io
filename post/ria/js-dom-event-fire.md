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

    //mouseenter mouseleave moverover
    //mouseup mousedown
    const mouseoverEvent = new Event('mouseover');
    whateverElement.dispatchEvent(mouseoverEvent);
