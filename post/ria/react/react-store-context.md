---
title: React Context
date: 2019-09-07
private:
---
# React Context

    import { useState, createContext, useContext } from 'react';
    const LoadingContext = createContext(['loading',(v)=>undefined]);

    const Gloading = () => {
      const [gloadingLevel] = useContext(LoadingContext);
      return (
        <p>status: {gloadingLevel}!</p>
      );
    };

    const ToggleLoading = () => {
      const [_, setLoading] = useContext(LoadingContext);
      return (
        <>
          <button onClick={() => setLoading('loading')}>loading</button>
          <button onClick={() => setLoading('loaded')}>loaded</button>
        </>
      );
    };

    const App = () => {
      const [level, setGloading] = useState('loading');  
      return (
        <LoadingContext.Provider value={[level,setGloading]}>
          <div>
            <Gloading />
            <ToggleLoading />
          </div>
        </LoadingContext.Provider>
      );
    }; 