---
title: 用js proxy fetch
date: 2022-10-04
---
# proxy otel trace

```js
import { context, trace } from '@opentelemetry/api';
import { propagation } from '@opentelemetry/api';
import { W3CTraceContextPropagator } from '@opentelemetry/core';
import { SimpleSpanProcessor, BatchSpanProcessor } from '@opentelemetry/sdk-trace-base';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { WebTracerProvider } from '@opentelemetry/sdk-trace-web';
import { ZoneContextManager } from '@opentelemetry/context-zone';
import { config } from '@/conf';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';
const appName = "my-ui";
const propagateTraceHeaderCorsUrls = [
  /^http:\/\/localhost/,
];

const provider = new WebTracerProvider({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: appName,
  }),
});

// Note: For production consider using the "BatchSpanProcessor" to reduce the number of requests
// provider.addSpanProcessor(new BatchSpanProcessor(new ConsoleSpanExporter()));
provider.addSpanProcessor(new BatchSpanProcessor(new OTLPTraceExporter({
  url: config.otel_endpoint + "/v1/traces",
})));
provider.register({
  contextManager: new ZoneContextManager(),
  // propagator: new B3Propagator(), // use header b3
  propagator: new W3CTraceContextPropagator(),// use header traceparent
});

function isAllowTrace(url: string) {
  if (!url.startsWith("http")) {
    return false;
  }
  for (const testurl of propagateTraceHeaderCorsUrls) {
    if (testurl.test(url)) {
      return true;
    }
  }
  return false;
}

window.fetch = new Proxy(window.fetch, {
  apply: async (target, thisArg, argumentsList: [any, any]) => {
    const req = new Request(...(argumentsList));
    const url = req.url
    if (!isAllowTrace(url)) {
      return Reflect.apply(target, thisArg, [req]);
    }

    // otel tracer
    const tracer = trace.getTracer(appName);
    const reqURL = new URL(url);
    const spanName = reqURL.host.split(".")[0] + reqURL.pathname;
    const span = tracer.startSpan(spanName);
    // const spanCtx = trace.setSpan(context.active(), span);
    try {
      const headers: Record<string, string> = {};
      propagation.inject(trace.setSpan(context.active(), span), headers);
      for (const [key, value] of Object.entries(headers)) {
        req.headers.set(key, value);
      }
      const response = await Reflect.apply(target, thisArg, [req]);
      span.addEvent('fetching-request-span-completed');
      return response;
    } catch (error: any) {
      span.recordException(error);
      throw error;
    } finally {
      span.end();
    }
  }
});
```