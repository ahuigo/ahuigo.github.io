---
title: tempfile
date: 2018-09-28
---
# tempfile

    import tempfile
    tempfile.TemporaryDirectory(suffix=None, prefix=None, dir=None)
    tempfile.TemporaryFile(mode='w+b', buffering=None, encoding=None, newline=None, suffix=None, prefix=None, dir=None)

    fp = tempfile.TemporaryFile()
    fp.write(b'ssss')

## temporaryDirectory

    import zipfile,tempfile,os
    with open('a.xlsx', 'rb') as f:
        dest = tempfile.TemporaryDirectory()
        zf = zipfile.ZipFile(f)
        zf.extract('xl/media/image1.png', dest.name)
            '/var/xxxxxx/xl/media/image1.png'
        os.rename(dest.name+'/xl/media/image1.png', 'newdir')

        # print([f.filename for f in zf.filelist if type(f)==zipfile.ZipInfo])
        # print([f.filename for f in zf.infolist()])
        # zf.extractall(dest)

# Path

    >>> from pathlib import Path
    >>> p = Path('.')
    (p/'dir'/'a.py').read_text()

## current working path

    os.chdir('/')
    os.getcwd()

## .iterdir

    >>> [x for x in p.iterdir() if x.is_dir()]
    [PosixPath('.hg'), PosixPath('docs'), PosixPath('dist'),
     PosixPath('__pycache__'), PosixPath('build')]

### .glob file
Listing Python source files in this directory tree:

    >>> list(p.glob('**/*.py'))
    [PosixPath('test_pathlib.py'), PosixPath('setup.py'),
     PosixPath('pathlib.py'), PosixPath('docs/conf.py'),
     PosixPath('build/lib/pathlib.py')]

## walk

    for root, dirs, files in os.walk(dest):
        for file_ in files:
            fn = os.path.join(root, file_)


## concat path
    >>> p = Path('/etc')
    >>> q = p / 'init.d' / 'reboot'
    PosixPath('/etc/init.d/reboot')

### path string

    str(Path(filename))

## property

### .exists()

    q.exists()

### .is_dir()
    q.is_dir()
    q.is_file()

## path info

## .resolve

    >>> q.resolve()
    PosixPath('/etc/rc.d/init.d/halt')

### .parent

    >>> PurePosixPath('/a/b/c/d').parent
    PurePosixPath('/a/b/c')

    >>> PurePosixPath('/a/b/c/d/').parent
    PurePosixPath('/a/b/c')

You cannot go past an anchor, or empty path:

    >>> p = PurePosixPath('/').parent
    PurePosixPath('/')
    >>> p = PurePosixPath('.').parent
    PurePosixPath('.')

Please use `Path.resolve()`:

    >>> PurePosixPath('foo/..').resolve()

### filepath

    str(Path('a.txt'))

### relative_to

    >>> p = PurePosixPath('/etc/passwd')
    >>> p.relative_to('/')
    PurePosixPath('etc/passwd')

### .name

    >>> PurePosixPath('my/library/setup.py').name
    'setup.py'

### .stem

    >>> PurePosixPath('my/library.tar').stem
    'library'

### .suffix

    >>> PurePosixPath('my/library.tar.gz').suffix
    '.gz'

### .suffixes

    >>> PurePosixPath('my/library.tar.gar').suffixes
    ['.tar', '.gar']

### .parts()

    >>> p = PurePath('/usr/bin/python3').parts
    ('/', 'usr', 'bin', 'python3')

    >>> p = PureWindowsPath('c:/Program Files/PSF').parts
    ('c:\\', 'Program Files', 'PSF')

### .match()

    >>> PurePath('a/b.py').match('*.py')
    True
    >>> PurePath('/a/b/c.py').match('b/*.py')
    True
    >>> PurePath('/a/b/c.py').match('a/*.py')
    False

## file operation

    ### .mkdir()
    Path.mkdir(mode=0o777, parents=False, exist_ok=False)¶

### .rename(new_path)
for r in Path('.').glob('devops-*.md'): r.rename(str(r).replace('devops-', 'ops-'))

### .unlink()
remove file or directory

    q.unlink() # use .rmdir() if q is directory

### .open()
open 和内置的open 是一样的

    q = Path('a.txt')
    with q.open() as f: f.readline()

### read-write
read_bytes()
write_bytes()

read_text()
write_text()

    >>> p = Path('my_binary_file')
    >>> p.write_bytes(b'Binary file contents')
    20
    >>> p.read_bytes()
    b'Binary file contents'

#### readline
    fp = open('a.txt')
    line = fp.readline()

    for line in fp:
    for cnt, line in enumerate(fp):
       print("Line {}: {}".format(cnt, line))