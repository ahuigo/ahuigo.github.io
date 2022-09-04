---
title: react hook swr
date: 2022-08-27
private: true
---

# react hook swr

## useFetch

    // const [data, isOk] = useFetch(url)
    function useFetch<T>(url: string, init: T): [T, boolean] {
      const [state, setState] = useState<T>(init);
      const isLoadingRef = useRef(false);
      useEffect(() => {
        fetch(url).then(async (d) => {
          const r = d.json() as Promise<T>;
          setState(await r);
        });
      }, []);
      return [state, isLoadingRef.current] as [T, boolean];
    }

还可以封装 usePost - useFetch

    function useGet<T>(url, options, init):T {
    }
