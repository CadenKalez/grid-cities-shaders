import struct,sys,os,re
def blobs(d):
    res=[];i=0
    while True:
        i=d.find(b'\xfe\xff',i)
        if i<0: break
        s=i-2
        if s>=4 and d[s+1] in (2,3) and d[s]==0:
            n=struct.unpack_from('>I',d,s-4)[0]
            if 8<n<400000 and d[s+n-4:s+n]==b'\xff\xff\x00\x00':
                res.append((s,d[s:s+n]));i=s+n;continue
        i+=1
    return res
if __name__=='__main__':
    d=open(sys.argv[1],'rb').read();out=sys.argv[2];os.makedirs(out,exist_ok=True)
    bl=blobs(d)
    names=[(m.start(),m.group(1).decode()) for m in re.finditer(rb'\x00\x00\x00[\x02-\x40]([A-Za-z_][\w]{1,63})\x00',d)]
    print(len(bl))
    import bisect
    pos=[p for p,_ in names]
    for k,(off,b) in enumerate(bl):
        kind='vs' if b[2]==0xfe else 'ps'
        open(os.path.join(out,'%05d_%06x_%s%d.bin'%(k,off,kind,b[1])),'wb').write(b)
