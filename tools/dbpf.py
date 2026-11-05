import struct, sys, os, zlib, collections
def refpack(src):
    p=0
    flags=src[0]; assert src[1]==0xFB, hex(src[1])
    p=2
    n=4 if flags&0x80 else 3
    size=int.from_bytes(src[p:p+n],'big'); p+=n
    if flags&0x01: p+=n
    out=bytearray()
    L=len(src)
    while p<L:
        b0=src[p]
        if b0<0x80:
            b1=src[p+1]; p+=2
            pl=b0&3; cl=((b0&0x1c)>>2)+3; off=((b0&0x60)<<3)+b1+1
        elif b0<0xC0:
            b1,b2=src[p+1],src[p+2]; p+=3
            pl=b1>>6; cl=(b0&0x3f)+4; off=((b1&0x3f)<<8)+b2+1
        elif b0<0xE0:
            b1,b2,b3=src[p+1],src[p+2],src[p+3]; p+=4
            pl=b0&3; cl=((b0&0x0c)<<6)+b3+5; off=((b0&0x10)<<12)+(b1<<8)+b2+1
        elif b0<0xFC:
            p+=1; pl=((b0&0x1f)<<2)+4; cl=0; off=0
        else:
            p+=1; pl=b0&3; cl=0; off=0
            out+=src[p:p+pl]; break
        out+=src[p:p+pl]; p+=pl
        if cl:
            s=len(out)-off
            if off>=cl: out+=out[s:s+cl]
            else:
                for i in range(cl): out.append(out[s+i])
    return bytes(out)
def entries(path):
    f=open(path,'rb'); h=f.read(96)
    cnt=struct.unpack_from('<I',h,0x24)[0]; isz=struct.unpack_from('<I',h,0x2c)[0]
    off=struct.unpack_from('<Q',h,0x40)[0]
    f.seek(off); d=f.read(isz)
    flags=struct.unpack_from('<I',d,0)[0]; p=4
    const={}
    for i,k in enumerate(['type','group','ihi']):
        if flags&(1<<i): const[k]=struct.unpack_from('<I',d,p)[0]; p+=4
    res=[]
    for _ in range(cnt):
        e={}
        for k in ['type','group','ihi']:
            if k in const: e[k]=const[k]
            else: e[k]=struct.unpack_from('<I',d,p)[0]; p+=4
        e['ilo'],e['off'],e['size'],e['mem']=struct.unpack_from('<IIII',d,p); p+=16
        e['comp'],e['commit']=struct.unpack_from('<HH',d,p); p+=4
        e['size']&=0x7fffffff
        res.append(e)
    return f,res
def read(f,e):
    f.seek(e['off']); raw=f.read(e['size'])
    if e['comp']==0xFFFF: return refpack(raw)
    if e['comp']==0x5A42: return zlib.decompress(raw)
    return raw
if __name__=='__main__':
    path=sys.argv[1]; mode=sys.argv[2]
    f,es=entries(path)
    if mode=='stats':
        c=collections.Counter((e['type']) for e in es)
        for t,n in c.most_common(): print(hex(t),n)
    elif mode=='dump':
        out=sys.argv[3]; types=set(int(x,16) for x in sys.argv[4].split(',')) if len(sys.argv)>4 else None
        os.makedirs(out,exist_ok=True)
        for e in es:
            if types and e['type'] not in types: continue
            try: data=read(f,e)
            except Exception as ex: print('fail',e,ex); continue
            d=os.path.join(out,'%08x'%e['type']); os.makedirs(d,exist_ok=True)
            open(os.path.join(d,'%08x_%08x%08x.bin'%(e['group'],e['ihi'],e['ilo'])),'wb').write(data)
