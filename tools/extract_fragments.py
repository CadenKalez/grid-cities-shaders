"""Rebuild the shader-fragment library + material shader assemblies as HLSL.
usage: python3 -I extract_shaders.py <0469a3f7 dir> <out dir>
40212002_* : fragment library (1023 VS slots, 1024 PS slots, big-endian)
40212004_* : material shader table (fragment index lists) + precompiled DX9 cache
Instances 0..3 = the four graphics-quality builds of the library."""
import struct,sys,re,json,os
ID=re.compile(r'^([A-Za-z_]\w*)?$')
class R:
    def __init__(s,d,p=0): s.d=d;s.p=p
    def u32(s): v=struct.unpack_from('>I',s.d,s.p)[0]; s.p+=4; return v
    def raw(s,n): v=s.d[s.p:s.p+n]; s.p+=n; return v
    def str(s): n=s.u32(); return s.raw(n).decode('latin1')
def frag(r,ps):
    hdr=r.raw(14 if ps else 15); main=r.str(); decl=r.str(); n=r.u32()
    params=[]
    for _ in range(n): t=r.str(); meta=r.raw(12); params.append({'decl':t,'meta':meta.hex()})
    samplers=[]
    if ps:
        blk=r.raw(40); ns=struct.unpack('>I',blk[-4:])[0]
        for _ in range(ns): samplers.append(r.str())
    name=r.str()
    return dict(name=name,hdr=hdr.hex(),main=main,decl=decl,params=params,samplers=samplers)
def parse_frags(d):
    r=R(d,8); vs=[frag(r,False) for _ in range(1023)]
    n=r.u32(); ps=[frag(r,True) for _ in range(n)]
    return vs,ps
def parse_mats(d,V,P):
    mats=[]
    for m in re.finditer(rb'\xff\xfe[\x02\x03]\x00\xff\xff[\x02\x03]\x00\x80',d):
        p=m.start()+12; n=struct.unpack_from('>I',d,p)[0]; p+=4
        if n>100: continue
        name=d[p:p+n].decode('latin1'); p+=n+1
        lists=[]
        for T,base in ((V,1),(P,0)):   # VS refs are 1-based, PS slot 0 is an empty slot
            c=struct.unpack_from('>I',d,p)[0]; p+=4; L=[]
            for i in range(c):
                e=d[p:p+26]; p+=26; idx=struct.unpack('>H',e[24:26])[0]-base
                L.append({'index':idx,'frag':T[idx]['name'],'cond':e[:24].hex()})
            lists.append(L)
        mats.append({'name':name,'vs':lists[0],'ps':lists[1]})
    return mats
def write_frag(f,path,stage,idx):
    with open(path,'w') as o:
        o.write('// shader fragment  [%s slot %d]  %s\n'%(stage,idx,f['name']))
        o.write('// Extracted from data package, type 0x0469A3F7 group 0x40212002\n')
        if f['params']:
            o.write('\n// ---- uniform parameters ----\n')
            for p in f['params']: o.write('uniform %s;   // reg-meta %s\n'%(p['decl'],p['meta']))
        if f['samplers']:
            o.write('\n// ---- samplers ----\n')
            for s in f['samplers']: o.write('sampler %s;\n'%s)
        if f['decl'].strip():
            o.write('\n// ---- declarations / helper functions ----\n'+f['decl'].rstrip()+'\n')
        o.write('\n// ---- fragment body (spliced into the generated main()) ----\n'+f['main'].rstrip()+'\n')
def assemble(m,V,P):
    out=['// material shader: %s'%m['name'],
         '// Reassembled from fragment library. Fragments are spliced in order into one main();',
         '// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.','']
    for stage,lst,T in (('VERTEX',m['vs'],V),('PIXEL',m['ps'],P)):
        out.append('//'+'='*78); out.append('// %s SHADER  (%d fragments; each may be conditionally enabled)'%(stage,len(lst))); out.append('//'+'='*78)
        seen=set()
        for e in lst:
            f=T[e['index']]
            if e['index'] in seen: continue
            for p in f['params']: out.append('uniform %s;'%p['decl'])
            for s in f['samplers']: out.append('sampler %s;'%s)
            if f['decl'].strip(): out.append(f['decl'].rstrip())
            seen.add(e['index'])
        out.append('\nvoid main_%s()\n{'%stage.lower())
        for e in lst:
            f=T[e['index']]
            out.append('    // --- fragment: %s   (cond %s)'%(f['name'],e['cond']))
            out+=['    '+l for l in f['main'].rstrip().split('\n') if f['main'].strip()]
        out.append('}\n')
    return '\n'.join(out)
if __name__=='__main__':
    src,dst=sys.argv[1],sys.argv[2]
    for inst in range(4):
        d=open(os.path.join(src,'40212002_%016x.bin'%inst),'rb').read()
        V,P=parse_frags(d)
        md=open(os.path.join(src,'40212004_%016x.bin'%inst),'rb').read()
        mats=parse_mats(md,V,P)
        base=os.path.join(dst,'quality%d'%inst)
        for stage,T in (('vs',V),('ps',P)):
            od=os.path.join(base,'fragments',stage); os.makedirs(od,exist_ok=True)
            seen={}
            for i,f in enumerate(T):
                if not f['name']: continue
                k=f['name']; seen[k]=seen.get(k,0)+1
                write_frag(f,os.path.join(od,'%04d_%s.hlsl'%(i,k)),stage.upper(),i)
        od=os.path.join(base,'materials'); os.makedirs(od,exist_ok=True)
        cnt={}
        for m in mats:
            k=m['name'].lstrip('#'); cnt[k]=cnt.get(k,0)+1
            fn=k if cnt[k]==1 else '%s__%d'%(k,cnt[k])
            open(os.path.join(od,fn+'.hlsl'),'w').write(assemble(m,V,P))
        json.dump({'materials':mats},open(os.path.join(base,'materials.json'),'w'),indent=1)
        json.dump({'vs':V,'ps':P},open(os.path.join(base,'fragments.json'),'w'),indent=1)
        print(inst,'vs',sum(1 for f in V if f['name']),'ps',sum(1 for f in P if f['name']),'materials',len(mats))
