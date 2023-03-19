---
title: css ::part
date: 2023-03-14
private: true
---
# css ::part

# demo
https://developer.mozilla.org/en-US/docs/Web/CSS/::part

    <style>
        tabbed-custom-element::part(tab) {
          color: #0c0dcc;
          border-bottom: transparent solid 2px;
        }

        tabbed-custom-element::part(tab):hover {
          background-color: #0c0d19;
          color: #ffffff;
          border-color: #0c0d33;
        }

        tabbed-custom-element::part(tab):hover:active { /**/
          background-color: #0c0d33;
          color: #ffffff;
        }

        tabbed-custom-element::part(tab):focus {
          box-shadow: 0 0 0 1px #0a84ff inset, 0 0 0 1px #0a84ff,
            0 0 0 4px rgba(10, 132, 255, 0.3);
        }

        tabbed-custom-element::part(active) {
          color: #0060df;
          border-color: #0a84ff !important;
        }
    </style>
    <title>::part() - examples - code sample</title>

    <template id="tabbed-custom-element">
      <div part="tab active">Tab 1</div>
      <div part="tab">Tab 2</div>
      <div part="tab">Tab 3</div>
    </template>

    <tabbed-custom-element></tabbed-custom-element>

    <script>
        let template = document.querySelector("#tabbed-custom-element");
        globalThis.customElements.define(
            template.id,
            class extends HTMLElement {
                constructor() {
                super().attachShadow({ mode: "open" }).append(template.content);
                }
            }
        );

    </script>