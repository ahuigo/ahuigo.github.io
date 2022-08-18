---
title: deno publish module
date: 2022-07-11
private: true
---
# Publishing Modules
## Publishing on deno.land/x
A common way to publish Deno modules is via the official https://deno.land/x hosting service.

To use it: 
1. modules must be developed and hosted in public repositories on GitHub. 
2. Their source is then published to deno.land/x on **tag creation**. 
    1. Then accesse it by a url in the following format: `https://deno.land/x/<module_name>@<tag_name>/<file_path>`

Adding a Module here: https://deno.land/add_module

## Publishing Deno modules for Node.js
See dnt - Deno to Node Transform.
https://deno.land/manual@main/publishing
https://nest.land
https://denopkg.com/

trex 用的就是这三家
