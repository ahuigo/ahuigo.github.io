---
title: try
date: 2018-09-27
---
# try

## catch multiple exception in on clause
since java 7

    try{}
    catch( IOException | SQLException ex ) {
        e.printStackTrace();
    }