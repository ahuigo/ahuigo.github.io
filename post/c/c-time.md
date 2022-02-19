---
layout: page
title:	c time
category: blog
description:
---

# Time
	time_t time();//unix time
	localtime()

## sleep

    #include <unistd.h>
    main() {
        sleep(1); //for 1 second.
        sleep(0.10); // 0.1s
        return 0;
    }
