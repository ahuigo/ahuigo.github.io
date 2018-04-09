# setup.py
    from setuptools import setup
    setup(
        name='flaskr',
        packages=['flaskr'],
        include_package_data=True,
        install_requires=[
            'flask',
        ],
        setup_requires=[
            'pytest-runner',
        ],
        tests_require=[
            'pytest',
        ],
    )

Now create setup.cfg in the project root (alongside setup.py), 使用pytest

    [aliases]
    test=pytest

This calls on the `alias` created in `setup.cfg` which in turn runs `pytest via pytest-runner`:

    python setup.py <alias>
    python setup.py test
    #python setup.py pytest

它会在包目录下寻找test 用例:

    pkg/
        setup.py
        tests/test_flaskr.py