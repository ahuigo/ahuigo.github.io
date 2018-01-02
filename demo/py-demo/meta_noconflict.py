'''
This code refer to : http://www.phyast.pitt.edu/~micheles/python/metatype.html
'''
metadic = {}
loop = 0
def _generatemetaclass(bases,metas,priority):
    global loop
    loop +=1
    trivial=lambda m: sum([issubclass(M,m) for M in metas],m is type)
    # hackish!! m is trivial if it is 'type' or, in the case explicit (m: meta of bases)
    # trivial: if m is superclass of any metas
    # metaclasses are given, if it is a superclass of at least one of them
    metabs=tuple(set([mb for mb in map(type,bases) if not trivial(mb)]))
    # metabs: mb is  meta of bases, but not in * metas*
    metabases=(metabs+metas, metas+metabs)[priority]
    print('%d. loop'%loop, 'metabases:', metabases)
    if metabases in metadic: # already generated metaclass
        return metadic[metabases]
    elif not metabases: # trivial metabase
        meta=type
    elif len(metabases)==1: # single metabase
        meta=metabases[0]
    else: # multiple metabases
        metaname="_"+''.join([m.__name__ for m in metabases])
        meta=makecls()(metaname,metabases,{})
    return metadic.setdefault(metabases,meta)

def makecls(*metas,**options):
    """Class factory avoiding metatype conflicts. The invocation syntax is
    makecls(M1,M2,..,priority=1)(name,bases,dic). If the base classes have
    metaclasses conflicting within themselves or with the given metaclasses,
    it automatically generates a compatible metaclass and instantiate it.
    If priority is True, the given metaclasses have priority over the
    bases' metaclasses"""

    priority=options.get('priority',False) # default, no priority
    return lambda n,b,d: _generatemetaclass(b,metas,priority)(n,b,d)


def mkMetaCls(*bases):
    metabases =tuple(set([type(base) for base in bases]))
    metaname="_"+''.join([m.__name__ for m in metabases])
    return type(metaname, metabases, {})

class M_A(type): pass
class M_B(type): pass
class A(object, metaclass = M_A): pass
class B(object, metaclass = M_B): pass

# e.g.1
class C(A,B, metaclass=makecls()): pass
print(type(C))

# with priority
class D(A,metaclass=makecls(M_B, priority=True)): pass
print(type(D), D.__class__.__mro__)

'''
To explain the first class C: cls=makecls(), c('C', (A,B), {})
_generatemetaclass(b,metas,priority)('C', (A,B), {})
_generatemetaclass(bases=(A,B),metas=(),False) ('C', (A,B), {})
0. mb: not meta and not  superclass of any metas ()
1. metabs: mb from type-bases: (M_A,M_B)
2. metabases = metabs + metas: (M_A,M_B)+ () = (M_A+M_B)

3. metabases>1:
    metaname = _M_AM_B from metabases
    meta = makecls()(metaname,metabases,{})
        _generatemetaclass(b,metas,priority)('_M_AM_B', (M_A,M_B), {})
        _generatemetaclass((M_A,M_B), metas=(),False)('_M_AM_B', (M_A,M_B), {})
            M_AB=type('_M_AM_B', (M_A,M_B), {})

4. M_AB('C', (A,B), {})

_generatemetaclass(b,metas,priority)('_M_AM_B', (M_A,M_B), {})
_generatemetaclass((M_A,M_B), metas=(),False)('_M_AM_B', (M_A,M_B), {})
0. mb: not meta and not  superclass of any metas ()
1. metabs: mb from type(bases): type(M_A)=type ()
2. metabases = metabs + metas: ()+ () = ()
3. metabases = 1:
    meta = type
    return dict[metabases] = type
    return dict[()] = type
        type('_M_AM_B', (A,B), {})

'''

