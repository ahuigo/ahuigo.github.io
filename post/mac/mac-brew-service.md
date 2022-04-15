---
title: mac brew services
date: 2022-04-16
private: true
---
# mac brew services
## brew services command
[sudo] brew services [list] (--json)
List information about all managed services for the current user (or root).

[sudo] brew services info (formula|--all|--json)
List all managed services for the current user (or root).

[sudo] brew services run (formula|--all)
Run the service formula without registering to launch at login (or boot).

[sudo] brew services start (formula|--all|--file=)
Start the service formula immediately and register it to launch at login (or boot).

[sudo] brew services stop (formula|--all)
Stop the service formula immediately and unregister it from launching at login (or boot).

[sudo] brew services kill (formula|--all)
Stop the service formula immediately but keep it registered to launch at login (or boot).

[sudo] brew services restart (formula|--all)