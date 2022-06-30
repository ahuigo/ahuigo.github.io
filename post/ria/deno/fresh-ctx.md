---
title: fresh context
date: 2022-06-30
private: true
---
# fresh context
every request

  hander = ctx.handler()
    const inner = router.router<RouterState>(...this.#handlers());
    const withMiddlewares = this.#composeMiddlewares(this.#middlewares);
    return function handler(req, connInfo) {
      return withMiddlewares(req, connInfo, inner);
    };
  resp = hander(req, {remote,local});
      withMiddlewares(req, connInfo, inner);

## ctx.#handlers()
    // js route
    routes[`${INTERNAL_PREFIX}${JS_PREFIX}/${BUILD_ID}/:path*`]

    // dev route
    routes[REFRESH_JS_URL]
    routes[ALIVE_URL]

    //static route
    routes[`GET@/foo.txt`]

    //main route
    routes[`${method}@${route.pattern}`]
        createRender = genRender(route, 200);
        routes[route.pattern] = (req, ctx, params) =>
          (route.handler as Handler)(req, {
            ...ctx,
            params,
            render: createRender(req, params),
        });
    return [routes, unknownHandler, errorHandler];


### main route genRender(route)(req)
render: createRender(req, params) = (data)=>response
重点：internalRender

      // render: createRender(req, params)
      return ( req: Request, params: Record<string, string>, error?: unknown,) => {
        // render(data)
        return async (data?: Data) => {
          const preloads: string[] = [];
          // 重点
          const resp = await internalRender({
            route,
            islands: this.#islands,
            app: this.#app,
            imports,
            preloads,
            renderFn: this.#renderFn,
            url: new URL(req.url),
            params,
            data,
            error,
          });

          const headers: Record<string, string> = {
            "content-type": "text/html; charset=utf-8",
          };

          const [body, csp] = resp;
          // csp header
          if (csp) {
            if (this.#dev) {
              csp.directives.connectSrc = [ ...(csp.directives.connectSrc ?? []), SELF, ];
            }
            const directive = serializeCSPDirectives(csp.directives);
            if (csp.reportOnly) {
              headers["content-security-policy-report-only"] = directive;
            } else {
              headers["content-security-policy"] = directive;
            }
          }
          return new Response(body, { status, headers });
        };
      };

### internalRender
src/server/render.tsx

    // function render(opts): <[string, ContentSecurityPolicy | undefined]> {
    const props: Record<string, unknown> = {
      params: opts.params,
      url: opts.url,
      route: opts.route.pattern,
      data: opts.data,
    };

    // vnode
    const headComponents: ComponentChildren[] = [];
    const vnode = h(CSP_CONTEXT.Provider, {
      value: csp,
      children: h(HEAD_CONTEXT.Provider, {
        value: headComponents,
        // opts.app.default + route.component
        children: h(opts.app.default, {
          Component() {
            return h(opts.route.component! as ComponentType<unknown>, props);
          },
        }),
      }),
    });

    // renderFn
    const ctx = new RenderContext(
      crypto.randomUUID(),
      opts.url,
      opts.route.pattern,
      opts.lang ?? "en",
    );
    await opts.renderFn(ctx, () => {
      bodyHtml = renderToString(vnode);
      return bodyHtml;
    });

    // imports refresh js
    const imports = opts.imports.map((url) => {
      const randomNonce = crypto.randomUUID().replace(/-/g, "");
      return [url, randomNonce] as const;
    });

    // import island
    if (ENCOUNTERED_ISLANDS.size > 0) {
      // Load the main.js script
      {
        const randomNonce = crypto.randomUUID().replace(/-/g, "");
        const url = bundleAssetUrl("/main.js");
        imports.push([url, randomNonce] as const);
      }

      // Prepare the inline script that loads and revives the islands
      let islandImports = "";
      let islandRegistry = "";
      for (const island of ENCOUNTERED_ISLANDS) {
        const randomNonce = crypto.randomUUID().replace(/-/g, "");
        const url = bundleAssetUrl(`/island-${island.id}.js`);
        imports.push([url, randomNonce] as const);
        islandImports += `\nimport ${island.name} from "${url}";`;
        islandRegistry += `\n  ${island.id}: ${island.name},`;
      }
      const initCode = `import { revive } from "${
        bundleAssetUrl("/main.js")
      }";${islandImports}\nrevive({${islandRegistry}\n});`;

      // Append the inline script to the body
      const randomNonce = crypto.randomUUID().replace(/-/g, "");
      if (csp) {
        csp.directives.scriptSrc = [
          ...csp.directives.scriptSrc ?? [],
          nonce(randomNonce),
        ];
      }
      (bodyHtml as string) +=
        `<script id="__FRSH_ISLAND_PROPS" type="application/json">${
          JSON.stringify(ISLAND_PROPS)
        }</script><script type="module" nonce="${randomNonce}">${initCode}</script>`;
    }

    const html = template({
      bodyHtml,
      headComponents,
      imports,
      preloads: opts.preloads,
      styles: ctx.styles,
      lang: ctx.lang,
    });

    return [html, csp];

## router.router(...handlers)-> innerHandler
// inner(req): match path method and call handler(req)
const inner = router.router(routes, unknownHandler,errorHandler);

    for (const [route, handler] of Object.entries(routes)) {
        // default method='any'
        let [method, path] = route.split(methodRegex);
        internalRoutes[path] = {
            pattern: new URLPattern({ pathname: path }),
            methods: {
                [method]: handler //append
            }
        };
    }
    // inner = callback --> match path method and call handler(req)
    return async (req, ctx) => {
        // match url
      for (const { pattern, methods } of Object.values(internalRoutes)) {
        const res = pattern.exec(req.url);
        if (res !== null) {
          for (const [method, handler] of Object.entries(methods)) {
            if (req.method === method) {
              return await handler( req, ctx, res.pathname.groups,);
            }
          }
          if (methods["any"]) {
            return await methods["any"]( req, ctx, res.pathname.groups,);
          } else {
            return await unknownMethod( req, ctx, Object.keys(methods),);
          }
        }
      }
      return await other(req, ctx);


## withMiddlewares = this.#composeMiddlewares(this.#middlewares)
wrap middlewares and innerHandler

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

## handle(req)
    handle = route.handle
    handle(req, { ...ctx, params, render: createRender(req, params), }

