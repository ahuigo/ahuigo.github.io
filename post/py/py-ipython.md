# ipython

# exit without confirm
create default config file first:

    $ ipython profile create
    ~/.ipython/profile_default/ipython_config.py

add :

    c.TerminalInteractiveShell.confirm_exit = False
