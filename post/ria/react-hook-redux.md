---
title: react hook redux/dva
date: 2020-01-18
private: true
---
# react hook redux/dva

## useDispatch
useDispath 只能在function component 内使用，如果是这样会报错的：

    <div onClick={e=>{ 
        const dispatch = useDispatch()
        dispatch({type:'xxx'})
    }}>

正确的用法：


    import React, { useEffect } from 'react';
    // import ReactDOM from 'react-dom';
    import { useSelector, useDispatch } from 'react-redux';

    interface Position {
        lng: number,
        lat: number,
        alt?: number,
    }

    export function useLabelHook() {
        const dispatch = useDispatch();
        return {
            addLabel: (labelId: string, position: Position, labelEl: JSX.Element) => {
                dispatch({
                    type: 'label/addLabel',
                    payload: {
                        labelId,
                        position,
                        labelEl,
                    },
                });
            },

            delLabel: (labelId: string) => {
                // ReactDOM.unmountComponentAtNode(labels[id].dom);
                dispatch({
                    type: 'label/delLabel',
                    payload: {
                        labelId,
                    },
                });
            }
        }
    }
    export default function LabelsLoader(props: any) {
        // props = || {};
        const lableList = useSelector((state: any) => state.label.labels);
        const labelHooks = useLabelHook()
        console.log(lableList)
        useEffect(() => {
            // todo: addListen move
            // const el = document.getElementById(containerId);
        }, []);
        return <div {...props} style={{ background: 'red', 'zIndex': 9999 }}>
            <div onClick={e => {
                labelHooks.addLabel('ahui', { lng: 139, lat: 40 }, <div><h1>new1</h1></div>)
            }}>
                <h1 id="ahuix">test</h1>
            </div>

            {Object.entries(lableList).map(([labelId, labelInfo]: [string, any]) => {
                const style = {} // getLabelStyle(labelInfo.position);
                return <div key={labelId} style={style}>{labelInfo.labelEl}</div>
            })}
        </div>
    }
