---
title: css module
date: 2022-09-01
private: true
---
# css scope style
draft: https://drafts.csswg.org/css-cascade-6/#scoped-styles

https://css-tricks.com/early-days-for-css-scoping/

    @scope (.media) {
      :scope {
        display: grid;
        grid-template-columns: 50px 1fr;
      }
      img {
        filter: grayscale(100%);
        border-radius: 50%;
      }
      .content { ... }
    }

# deno css module
https://github.com/denoland/deno/issues/11961
https://github.com/exhibitionist-digital/ultra/issues/89

# chrome css module
## import styleSheet

    import styleSheet from "./styles.css" assert { type: "css" };
        CSSStyleSheet

custom styleSheet:

    const sheet = new CSSStyleSheet();
    // Apply a rule to the sheet
    sheet.replaceSync('a { color: red; }');
    sheet.insertRule("* { background-color: blue; }");


## append style.sheet

    $ document.getElementsByTagName("style").sheet
    CSSStyleSheet {
        rules: CSSRuleList,
        href: 'http://localhost:4500/assets/purecss@2.0.3.css',
    }

refer fresh/plugins/twind/main.ts

    const el = document.getElementById(STYLE_ELEMENT_ID) as HTMLStyleElement;
    el.sheet.insertRule(rule, index)

## insert global styleSheet
https://github.com/WICG/webcomponents/blob/gh-pages/proposals/css-modules-v1-explainer.md

    import styleSheet from "./styles.css" assert { type: "css" };
    document.adoptedStyleSheets = [...document.adoptedStyleSheets, styleSheet];

## insert components styles
> Web components can isolate styles  via the Shadow DOM.
https://css-tricks.com/styling-a-web-component/#aa-shadow-doming-the-template

via this.shadowRoot.adoptedStyleSheets = [styles];

    <head>
        <script type="module">
            import styles from './html5Element.css' assert { type: 'css' };
            class HTML5Element extends HTMLElement {
                constructor() {
                    super();
                    let shadowRoot = this.attachShadow({ mode: "closed" });

                    this.shadowRoot.adoptedStyleSheets = [styles];

                    let outerDiv = document.createElement("div");
                    outerDiv.className = "outerDiv";
                    let mainImage = document.createElement("img");
                    mainImage.className = "mainImage";
                    mainImage.src = "https://www.w3.org/html/logo/downloads/HTML5_Logo_512.png";
                    let devText = document.createElement("div");
                    devText.className = "devText";
                    devText.innerText = "CSS Modules Are Great!";

                    shadowRoot.appendChild(outerDiv);
                    outerDiv.appendChild(mainImage);
                    outerDiv.appendChild(devText);
                }
            }
            window.customElements.define("my-html5-element", HTML5Element);
       </script>
    </head>
    <body>
        <my-html5-element></my-html5-element>
    </body>

## insert element sheet

    const node = document.querySelector('div');
    const shadow = node.attachShadow({ mode: 'closed' });
    shadow.appendChild(...node.children)

    //Adopt the same sheet into the shadow DOM
    const sheet = new CSSStyleSheet();
    sheet.replaceSync('a { color: red; }');
    shadow.adoptedStyleSheets = [sheet];


## Link to external styles instead
https://css-tricks.com/styling-a-web-component/#aa-link-to-external-styles-instead

    const template = document.createElement('template');
    template.innerHTML = `
    <style>
    @import "https://codepen.io/chriscoyier/pen/VqKvZr.css";
    </style>
    <button>Sup?</button>`;

    class WhatsUp extends HTMLElement {
      connectedCallback() {
        this.attachShadow({mode: 'open'});
        this.shadowRoot.appendChild(template.content.cloneNode(true));
        const button = this.shadowRoot.querySelector("button");
        button.addEventListener("click", this.handleClick);
      }
      handleClick(e) {
        alert("Sup?");
      }
    }

    window.customElements.define('whats-up', WhatsUp);


# convert react to webcomponents
https://github.com/preactjs/preact-custom-element