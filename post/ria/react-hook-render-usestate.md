---
title: React hook render useState 多次渲染
date: 2020-01-20
private: true
---
# React setState 多次渲染问题
如果是同步调用，多次setState 会被合并为一次, 因为此时setState 通过上下文能判断出属于function compoment 生命周期的第一阶段，会忽略render。到生命周期的render 阶段再统一渲染

    const [loading, setLoading] = useState(true);
    const [data, setData] = useState(null);
    useEffect(() => {
      setLoading(false);
      setData({ a: 1 });
    }, []);

如果是同步调用，多次setState 会被render 多次, 
因为setState 脱离了function component 的生命周期(我想setState 或许可以支持一下防抖动？)

    const [loading, setLoading] = useState(true);
    const [data, setData] = useState(null);
    useEffect(async () => {
      const res = await axios.get("xxx");
      setLoading(false);
      setData(res);
    }, []);

通过合并setState 避免多次render

## 自定义useMergeState

    const useMergeState = (initialState) => {
        const [state, setState] = useState(initialState);
        const setMergeState = (newState) =>
            setState((prevState) => ({ ...prevState, newState }));
        return [state, setMergeState];
    };

    /* 使用 */
    const [request, setRequest] = useMegeState({ loading: false, data: null});
    useEffect(async () => {
        setRequest({loading: true}); // 旧的data 不会消失
        const data = await axios.get("xxx");
        setRequest({loading: false, data:data}); 
    }, []);

## 使用useReducer合并
React提供了useReducer来管理各个依赖项，(useState本身就是用的useReducer)

    const [request, setRequest] = useReducer(
        (prevState, newState) => ({ ...prevState, newState }),
        { loading: false, data: null }
    );

    useEffect(async () => {
        setRequest({loading: true}); // 旧的data 不会消失
        const data = await axios.get("xxx");
        setRequest({loading: false, data:data}); 
    }, []);

如果想要支持回调函数－获取上一个状态，需要对上面的代码进行改造:

    const [request, setRequest] = useReducer(
        (prevState, newState) => {
            const newWithPrevState = typeof newState === "function" ? newState(prevState) : newState;
            return { ...prevState, newWithPrevState }
        },
        { loading: false, data: null },
    );

    useEffect(async () => {
        setRequest({loading: true}); 
        const data = await axios.get("xxx");
        // 回调函数
        setRequest((prevState) => {
            return { loading: false, data: data }
        });
    }, []);

### typescript 支持
    interface MyState {
    loading: boolean;
    data: any;
    something: string;
    }

    const [state, setState] = useReducer<Reducer<MyState, Partial<MyState>>>(
        (state, newState) => ({...state, ...newState}),
        {loading: true, data: null, something: ''}
    )



# Rerfer
1. https://segmentfault.com/a/1190000041132302
2. https://stackoverflow.com/questions/53574614/multiple-calls-to-state-updater-from-usestate-in-component-causes-multiple-re-re