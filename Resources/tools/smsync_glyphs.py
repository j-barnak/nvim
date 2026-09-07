# smsync_glyphs.py - glyph oracle for Shared-Memory Synchronization (Scott/Brown).
#
# The book's math notation (bardbl=∥, angbracketleft/right=⟨⟩, Phi=Φ, Theta=Θ,
# negationslash=≠, ceiling=⌈⌉, ⊥, →) is set in subsetted CMSY/MTSYN/MTMI fonts
# whose bytes pdftotext -layout emits as font-AMBIGUOUS control bytes (one byte =
# several glyphs by font), so a byte remap is impossible and a plain build shows
# ~700 "?". This aligns the pdftotext -layout stream (arg 1) against a mutool
# "draw -F txt" extraction (arg 2, which resolves the fonts' ToUnicode) per page
# and per line, splicing the correct glyph in at each control-byte position.
#   mt.txt = mutool draw -F txt -o mt.txt SRC ; pt.txt = pdftotext -layout SRC -
#   python3 smsync_glyphs.py pt.txt mt.txt > repaired.txt
# A handful of glyphs neither tool maps are resolved by a font-name closed set.
# NOTE: this pipeline (plus smsync_build.sh + smsync_fix.awk and 4 pinned glyph
# corrections - see that book's commit) regenerates the frozen text; the plain
# pdf_build.sh cannot, so the frozen files are committed as artifacts.
import sys,difflib,re
pt=open(sys.argv[1],encoding="latin-1").read().split("\f")
mt=open(sys.argv[2],'rb').read().decode("utf-8","replace").split("\f")
CTRL=lambda o:(o<32 and o not in (9,10,13))
def sig(text):
    P=[i for i,c in enumerate(text) if not c.isspace()]
    return P,[text[i] for i in P]
def ao(s): return "".join(c if 32<ord(c)<127 else "\x01" for c in s)
cnt=dict(glob=0,line=0,phi=0,theta=0,par=0,cel=0,ang=0,neq=0,left=0)
leftctx=[]
out=[]
for pi in range(len(pt)):
    ptext=pt[pi]; mtext=mt[pi] if pi<len(mt) else ""
    Apos,A=sig(ptext)
    if not any(CTRL(ord(c)) for c in A): out.append(ptext); continue
    Bpos,B=sig(mtext)
    # global alignment
    sm=difflib.SequenceMatcher(None,ao(A),ao(B),autojunk=False)
    aligned={}
    for tag,i1,i2,j1,j2 in sm.get_opcodes():
        if tag=='equal':
            for k in range(i2-i1): aligned[i1+k]=j1+k
    # mt lines for per-line matching (this page)
    mlines=[l for l in mtext.split("\n") if l.strip()]
    rep={}
    for ai,a in enumerate(A):
        if not CTRL(ord(a)): continue
        p=Apos[ai]
        # 1) global oracle
        j=aligned.get(ai)
        if j is not None:
            b=B[j]
            if ord(b)!=0xFFFD and not CTRL(ord(b)):
                rep[p]=b; cnt['glob']+=1; continue
        # 2) per-line oracle: match the pt fragment (ascii run around glyph) to an mt line
        ls=ptext.rfind("\n",0,p)+1; le=ptext.find("\n",p); le=len(ptext) if le<0 else le
        line=ptext[ls:le]; col=p-ls
        # ascii run containing this column (fragment), specials as wildcard \x01
        L=col
        while L>0 and (32<=ord(line[L-1])<127 or CTRL(ord(line[L-1]))) and line[L-1] not in ' ' or (L>0 and CTRL(ord(line[L-1]))): 
            if line[L-1]==' ' and not CTRL(ord(line[L-1])): break
            L-=1
        R=col
        while R<len(line)-1 and (32<=ord(line[R+1])<127 or CTRL(ord(line[R+1]))):
            if line[R+1]==' ': break
            R+=1
        frag=line[L:R+1]; gpos=col-L
        # build regex from frag: ascii literal, specials -> (.)
        parts=[]; caps=[]
        for idx,ch in enumerate(frag):
            if CTRL(ord(ch)): parts.append("(.)"); caps.append(idx)
            elif 32<ord(ch)<127: parts.append(re.escape(ch))
            else: parts.append("(?:.)")
        pat="".join(parts)
        got=None
        if sum(1 for ch in frag if 32<ord(ch)<127)>=3:
            for ml in mlines:
                m=re.search(pat,ml)
                if m:
                    # which capture group is our glyph
                    for gi,ci in enumerate(caps,1):
                        if ci==gpos:
                            g=m.group(gi)
                            if ord(g)!=0xFFFD and not CTRL(ord(g)): got=g
                    if got: break
        if got: rep[p]=got; cnt['line']+=1; continue
        # 3) confirmed-glyph context rules (font-verified closed set)
        before=ptext[ls:p]; after=ptext[p+1:le]; lob=before.lower()
        g=None
        if re.match(r"\s*=", after):                              # glyph directly before '='  -> not-equal
            g="̸"; cnt['neq']+=1
        elif re.match(r"\s*[A-Za-z0-9_*]+\s*,", after):         # opens a tuple  -> left angle
            g="⟨"; cnt['ang']+=1
        elif re.search(r"[A-Za-z0-9_*⟩]\s*$", before) and (re.match(r"\s*(:=|:|\)|$|\s)", after) or after.strip()==""):
            # closes a tuple: preceded by word/*, followed by := or end  -> right angle (only if a '⟨' plausibly opened)
            if "," in before or "⟨" in before or before.rstrip().endswith("*"):
                g="⟩"; cnt['ang']+=1
        if g is None and re.search(r"\(\s*n\b|\(\s*log|height|only|requires|takes", (after+ " "+before).lower()) and re.match(r"\s*\(", after):
            g="Θ"; cnt['theta']+=1
        if g is None and (re.match(r"\s*log ?2", after)):
            g="⌈"; cnt['cel']+=1
        if g is None and re.search(r"log ?2 ?n\s*$", before):
            g="⌉"; cnt['cel']+=1
        if g is None and (re.search(r"fetch.?and|and_|function|computes|store\(old|-and-|\bidiom\b|operations|were performed", lob+" "+after.lower()) or re.match(r"\s*\(\s*old\s*\)", after)):
            g="Φ"; cnt['phi']+=1
        if g is None and (re.search(r"(store|load|fence|swap|CAS|FAA|FAI|TAS|inc|flag|serving|announce|preempt)\b|[RW]\s*$|\(\s*$|,\s*$", before) and re.match(r"\s*[RW)]", after) or re.match(r"\s*[RW]{0,2}\s*\)", after) or (re.match(r"\s*\)",after) and re.search(r"\([^)]*$",before)) or re.search(r"[RW]$",before)):
            g="∥"; cnt['par']+=1
        if g is None:
            # dominant confirmed math glyph on this physical page (mutool ground truth)
            MS="∥⟨⟩ΘΦ⌈⌉̸→⊥∈⌊⌋≥′×¬"
            from collections import Counter as _C
            mc=_C(ch for ch in mtext if ch in MS)
            if mc:
                top,tn=mc.most_common(1)[0]; tot=sum(mc.values())
                if tot>=4 and tn>=0.7*tot:
                    g=top; cnt['par']+=1
        if g is None:
            cnt['left']+=1
            if len(leftctx)<40: leftctx.append(("p%d |"%(pi+1))+(before[-26:]+"<>"+after[:20]))
        else:
            rep[p]=g
    if rep:
        buf=list(ptext)
        for idx,s in rep.items(): buf[idx]=s.encode("utf-8").decode("latin-1")
        ptext="".join(buf)
    out.append(ptext)
sys.stderr.write(str(cnt)+"\n")
for s in leftctx: sys.stderr.write("  LEFT "+s+"\n")
sys.stdout.buffer.write(("\f".join(out)).encode("latin-1"))
