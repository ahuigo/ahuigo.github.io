---
title: react on props change
date: 2020-08-26
private: true
---
# react rerender on props change
用useEffect控制就好喽

    import React, { useEffect } from 'react';

    const SitesTableContainer = ({
      user,
      isManager,
      dispatch,
      sites,
    }) => {
      useEffect(() => {
        if(isManager) {
          dispatch(actions.fetchAllSites())
        } else {
          const currentUserId = user.get('id')
          dispatch(actions.fetchUsersSites(currentUserId))
        }
      }, [user]); 

      return (
        return <SitesTable sites={sites}/>
      )

    }