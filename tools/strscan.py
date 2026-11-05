import sys,struct,re
ok=set(range(32,127))|{9,10,13}
def scan(d,minlen=2):
    i=0;N=len(d);out=[]
    while i<N-4:
        n=struct.unpack_from('>I',d,i)[0]
        if minlen<=n<=60000 and i+4+n<=N:
            s=d[i+4:i+4+n]
            if all(c in ok for c in s) and s[0]!=32 or (n>=2 and all(c in ok for c in s) and s.strip()):
                out.append((i,s.decode()));i+=4+n;continue
        i+=1
    return out
if __name__=='__main__':
    d=open(sys.argv[1],'rb').read()
    for off,s in scan(d):
        print('@%06x %r'%(off,s[:120]))
