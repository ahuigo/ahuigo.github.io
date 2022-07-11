---
title: fresh context
date: 2022-06-30
private: true
---

# fresh context

every request

    hander = ctx.handler()
      const inner = router.router(...this.#handlers());
      const withMiddlewares = this.#composeMiddlewares(this.#middlewares);
      return function handler(req, connInfo) {
        return withMiddlewares(req, connInfo, inner);
      };
    resp = hander(req, {remote,local});
        withMiddlewares(req, connInfo, inner);

## life cycle
1. init ctx=fromManifest(manifest, options)
    1. create `ctx.#routes` // in `fromManifest`
    1. create `this.#renderFn= options.render` // from options.ts
2. hander = ctx.handler()       //big ctx main handler
    1. handlers = this.#handlers(); 
        2. create genRender         // #handlers()
        1. create routers = ctx.#routes    // #handlers()
        1. return [routes,unknown,error] in context.ts
    2. inner = router.router(...handlers); //context.ts 
        1. create internalRoutes base handlers  // api/get/uYQG.ts
        1. create inner // api/get/uYQG.ts
    3. withMiddlewares = this.#composeMiddlewares(this.#middlewares, inner);
    4. return withMiddlewares
3. resp = handler(req, connInfo:{remote,local});    //context.ts
4. withMiddlewares(req, connInfo, inner);       //context.ts
    1. mws = selectMiddlewares from middlewares
    2. mws.push(inner)
    3. mws.shift()(req)
        1. call middleware // which middleware?
        2. call inner(req,ctx)  //context.ts:composeMiddlewares
5. inner(req,ctx)   //2.2.1 api/get/uYQG.ts
    1. call `handler(req,ctx, res.pathname.groups,)` //api/get/uYQG.ts
        1. handler is selected from from `internalRoutes` //api/get/uYQG.ts:Router()
        2. internalRoutes < #handlers() < ctx.#routes
6. call `handler(req,ctx, res.pathname.groups,)` //api/get/uYQG.ts
7. `handler(req,ctx, res.pathname.groups,)` //callback in context.ts:452:#handlers()
    1. create `render=createRender(req,)` //context.ts:457:#handlers()
    2. call `handler(req,{render})` //context.ts:453:#handlers() 
    3. call `handler.GET(_req, { render })`;//context.ts:129:fromManifest()
    4. call `render()` ///context.ts:129:fromManifest()
    3. render();    //context.ts:399:genRender()
        1. imports=[REFRESH_JS_URL];
        1. call resp=`internalRender(route,imports,this.#renderFn)` //genRender()
        2. return new Response(resp) // context.ts:genRender()
    5. `internalRender(route,imports,this.#renderFn)` //`src/server/render.tsx`:render(opts)
        1. create headComponents
        1. call vnode=h(opts.route.component)
        2. ctx = new RenderContext(opts)
        2. call opts.renderFn(ctx,render)   
            1. render is renderToString //  provided by preact
            1. bodyHtml = renderToString(vnode);    // render.ts:180
            2. renderFn is created from `options.render`//in fromManifest-fixture/options.ts
        3. island:
            1. imports contains
                1. refresh url  // refer 7.3.1
                1. push([main_url, randomNonce]
                2. island url ENCOUNTERED_ISLANDS // data from 7.7.1.1
            2. create initCode 
                1. import("/main.js")
                2. import islandImports
        3. create islandRegistry
        4. bodyHtml += island
            2. ISLAND_PROPS // data from 7.7.1.1
            1. script initCode component
        5. create html = template({bodyHtml, headComponents, imports, opts.preloads});
    6. renderToString(vnode)
        1. call `options.vnode(vnode)` // preact
    7. options.vnode(vnode)
        1. execute island
            1. call `ENCOUNTERED_ISLANDS.add(island)`
            2. generate `vnode.type = (props) => {}`
                child = h(island.component, props); // props is sub component's props
                ISLAND_PROPS.push(props);
                return h(`!--frsh-${island.id}:{index}--`, null, child);
        2. call originalHook(vnode) // old vnode provided by preact

## select middleware
    // withMiddlewares(req)
    return ( req: Request, connInfo: ConnInfo, inner) => {
      const mws = selectMiddlewares(req.url, middlewares);
      const handlers= [];
      const ctx = {
        next() {
          const handler = handlers.shift()!;
          return Promise.resolve(handler());
        },
        ...connInfo,
        state: {},
      };
      for (const mw of mws) {
        handlers.push(() => mw.handler(req, ctx));
      }
      handlers.push(() => inner(req, ctx));
      const handler = handlers.shift()!;
      return handler();
    };

## call options.vnode(vnode)
options is provided by preact
1. old `options.vnode` is backuped as original `originalHook`
2. define new `options.vnode` 

`options.vnode` will call:
1. only if find island via `vnode.type`:
    1. call `ENCOUNTERED_ISLANDS.add(island)`
    2. generate `vnode.type = (props) => {...}` 
2. call originalHook(vnode)

within `vnode.type = (props) => {}`:

    vnode.type = (props) => {
        ignoreNext = true;
        // originalType === island.component
        const child = h(originalType, props);
        ISLAND_PROPS.push(props);
        return h(
            `!--frsh-${island.id}:${ISLAND_PROPS.length - 1}--`,
            null,
            child,
        );
    };