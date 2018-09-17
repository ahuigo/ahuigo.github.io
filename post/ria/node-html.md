# node html
    import { parse } from 'node-html-parser';
    
    const root = parse('<ul id="list"><li>Hello World</li></ul>');
    console.log(root.firstChild.structure);

## selector
    console.log(root.querySelector('#list'))
    console.log(root.toString());

## modify

    root.set_content('<li>Hello World</li>');
    root.toString();	// <li>Hello World</li>

## attribute
https://www.npmjs.com/package/node-html-parser

    HTMLElement#text
