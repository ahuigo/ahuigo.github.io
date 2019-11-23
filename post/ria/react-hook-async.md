---
title: React hook async
date: 2019-11-22
private: true
---
# React hook async

## useEffect+async 的方法

      useEffect(() => {
        // Create an scoped async function in the hook
        async function anyNameFunction() {
          await loadContent();
        }
        // Execute the created function directly
        anyNameFunction();
      }, []);
      
或者：

    const MyFunctionnalComponent: React.FC = props => {
      useEffect(() => {
        // Using an IIFE
        (async function () {
          await loadContent();
        })();
      }, []);
      return <div></div>;
    };