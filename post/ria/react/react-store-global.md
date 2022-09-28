---
title: react global store
date: 2020-11-30
private: true
---
# react global store
    const gRef = React.useRef<any>({});
    const g = gRef.current;

或：

    const { current: store } = React.useRef<Store>({
        start_time: new Date().add(-14, 'd'),
        end_time: new Date(),
    });

g.currrent 可以与forceUpdate 合用

    export function useStateRef() {
      const forceUpdate = React.useReducer(() => ({}))[1];
      const stateRefRaw = React.useRef<FormState>(initialState);

      return React.useMemo(() => {
        let validator = {
          set: function(
            obj: typeof stateRefRaw,
            prop: 'current',
            value: FormState,
          ) {
            obj[prop] = value;
            forceUpdate();
            return true;
          },
        };
        return new Proxy(stateRefRaw, validator);
      }, []);
    }