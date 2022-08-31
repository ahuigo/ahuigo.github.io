---
title: react hook swr
date: 2022-08-27
private: true
---
# react hook swr

## usePromise
    function usePromise<T>(fetcher: Promise<T>, init: T) {
      const [state, setState] = useState(init);
      const isLoadingRef = useRef(false);
      fetcher.then((d) => {
        setState(d);
        isLoadingRef.current=true
      });
      return [state, isLoadingRef.current] as [T, boolean];
    }

    function fetchPathList(path: string): Promise<string[]> {
      return fetch(path).then(async (r) => {
        const pathList = ["path1", "path2"];
        return pathList;
        // return await r.json();
      });
    }

    export default function DirTree({ path }: dirTreeProps) {
      const [pathList, isLoading] = usePromise(fetchPathList(path), undefined);
    }

## useFetch
还可以封装 useGet, usePost - useFetch

    function useGet<T>(url, options, init):T {
    }