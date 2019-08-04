---
title: Python debug object
date: 2019-07-26
private:
---
# Python debug object
https://mg.pov.lt/objgraph/

    >>> x = []
    >>> y = [x, [x], dict(x=x)]
    >>> import objgraph
    >>> objgraph.show_refs([y], filename='sample-graph.png')
    Graph written to ....dot (... nodes)
    Image generated as sample-graph.png