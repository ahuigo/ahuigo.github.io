---
title: React state
date: 2019-05-28
private:
---
# React access child's state
https://stackoverflow.com/questions/54702565/how-to-access-childs-state-in-react-react-hooks

## access child state via ref(非受控)
Form (Parent)

    export const Form: FunctionComponent<IProps> = ({ onFinish, initState }) => {
      const formInputsStateRef = useRef({})

      const handleFinish = () => {
        const params = formInputsStateRef.current
        console.log(params)
        onFinish(params)
      }

      return (
        <div>
          <Inputs initState={initState} stateRef={formInputsStateRef}  />
          <S.Button onClick={handleFinish}>
            Finish
          </S.Button>
        </div>
      )
    }

Inputs (Child)

    export const Inputs: FunctionComponent<IProps> = ({ initState, stateRef }) => {
      const [pool, setPool] = useState(initState.pool)
      const [solarPanel, setSolarPanel] = useState(initState.solarPanel)

      useEffect(() => {
        stateRef.current = { pool, solarPanel }
      }, [pool, solarPanel])

      const handlePoolInput = () => {
        setPool('new pool')
      }

      const handleSolarPanelInput = () => {
        setSolarPanel('new solar panel')
      }

      return (
        <div>
          <h2>{pool}</h2>
          <S.Button onClick={handlePoolInput}>Change pool</S.Button>
          <h2>{solarPanel}</h2>
          <S.Button onClick={handleSolarPanelInput}>Change solar panel</S.Button>
          <h2>-----</h2>
        </div>
      )
    }

### useImperativeHandle
However to have a more controlled handle of child values using ref, you can make use of useImperativeHandle hook.

Child

    const InputsChild: FunctionComponent<IProps> = ({ initState, ref }) => {
      const [pool, setPool] = useState(initState.pool)
      const [solarPanel, setSolarPanel] = useState(initState.solarPanel)

      useImperativeHandle(ref, () => ({
        pool,
        solarPanel
      }), [pool, solarPanel])

      const handlePoolInput = () => {
        setPool('new pool')
      }

      const handleSolarPanelInput = () => {
        setSolarPanel('new solar panel')
      }

      return (
        <div>
          <h2>{pool}</h2>
          <S.Button onClick={handlePoolInput}>Change pool</S.Button>
          <h2>{solarPanel}</h2>
          <S.Button onClick={handleSolarPanelInput}>Change solar panel</S.Button>
          <h2>-----</h2>
        </div>
      )
    }

    export const Inputs = forwardRef(InputsChild);

Parent

    export const Form: FunctionComponent<IProps> = ({ onFinish, initState }) => {
      const formInputsStateRef = useRef({})

      const handleFinish = () => {
        const params = formInputsStateRef.current
        console.log(params)
        onFinish(params)
      }

      return (
        <div>
          <Inputs initState={initState} ref={formInputsStateRef}  />
          <S.Button onClick={handleFinish}>
            Finish
          </S.Button>
        </div>
      )
    }