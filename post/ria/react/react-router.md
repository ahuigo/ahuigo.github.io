---
title: react router
date: 2022-09-27
private: true
---
# code splitting
refer ultra.dev

## via lazy and Suspense
Suspense提供了统一的无缝的代码分割（Code Splitting）兼异步加载方法，在v16.6.0就实现了这样的Suspense功能

    import {lazy, Suspense} from "react"
    const HomePage = lazy(()=> import("./pages/Home.tsx"));
    const AboutPage = lazy(()=> import("./pages/About.tsx"));

    export default function App() {
      return (
          <Suspense fallback={<div>Page is Loading...</div>}>
            <Routes>
              <Route path="/" element={<DefaultLayout />}>
                <Route index element={<HomePage />} />
                <Route path="about" element={<AboutPage />} />
              </Route>
            </Routes>
          </Suspense>
      );
    }

## via loadable
loadable 相对lazy 不需要Suspense, 而且支持`SSR`+ `Library code splitting`(https://blog.logrocket.com/react-dynamic-imports-route-centric-code-splitting-guide/#react-lazy)

    import { Routes, Route, Outlet, Link } from "react-router-dom";
    import loadable from "@loadable/component";

    import HomePage from "./pages/Home";

    const LoadablePage = loadable((props) => import(`./pages/${props.page}`), {
      fallback: <div>Page is Loading...</div>,
      cacheKey: (props) => props.page
    });

    export default function App() {
      return (
        <div className="App">
          <Routes>
            <Route path="/" element={<AppLayout />}>
              <Route index element={<HomePage />} />
              <Route path="dashboard" element={<LoadablePage page="Dashboard" />} />
              <Route path="notifications" element={<LoadablePage page="Notifications" />} />
            </Route>
          </Routes>
        </div>
      );
    }