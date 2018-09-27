---
title: SWAP
date: 2018-09-27
---
# SWAP

## Verify if swap exists
After running that command you should see something similar to this output:

    free -m

    total              used       free     shared    buffers     cached
    Mem:               1840       1614     226       15          36       1340
    -/+ buffers/cache:            238      1602
    Swap:              0          0        0

If you see a value of `0` in the `Swap section`, then you can proceed to step 2.

Alternatively, you can run the following command to see if there is a configured swap file:

    swapon -s

If you do not see any output from swapon, then proceed to step 2.

## Step 2: Create swap file

    dd if=/dev/zero of=/swapfile count=2048 bs=1M

## Step 3: Activate the swap file
As a security measure, update the swapfile permissions to only allow R/W for root and no other users. Run:

    chmod 600 /swapfile

Next, tell the server to setup the swap file by running:

    $ mkswap /swapfile
    Setting up swapspace version 1, size = 2097148 KiB
    no label, UUID=ff3fc469-9c4b-4913-b653-ec53d6460d0e

## Step 4: Turn swap on
Once your file is ready to be used as swap, you need to enable it by running:

    swapon /swapfile

You can verify that the swap file is active by running the free command again.

    free -m

# Step 5: Enable swap on reboot
nano /etc/fstab, Add the following line at the end of the file:

    /swapfile   none    swap    sw    0   0

# summary

    dd if=/dev/zero of=/swapfile count=2048 bs=1M
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile   none    swap    sw    0   0' >> /etc/fstab