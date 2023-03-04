reread = 1
alt = 300
ivars = [32,33,34]
if n_elements(directory) eq 0 then directory ='.'
directory = ask('which gitm directory to plot: ',directory)

filelist = file_search(directory+'/*.bin')
nfiles_new = n_elements(filelist)
if n_elements(nfiles) eq 0 then nfiles = 0

if nfiles_new eq nfiles then reread = 0

if not reread then begin
    reread = 'n'
    reread = ask('whether to reread files: ',reread)
    if strpos(reread,'y') ge 0 then reread = 1 else reread = 0
endif
Vars = ['[e-]','NmF2','HmF2','Te','Ti']
if reread then begin 
    thermo_readsat, filelist, data_n, time, nTimes, Vars_temp, nAlts, nSats, Files 
    nFiles = n_elements(filelist)

    data = fltarr(n_elements(vars),ntimes)
    nmf2 = fltarr(ntimes)
    hmf2 = fltarr(ntimes)
    e = fltarr(ntimes)
    te = fltarr(ntimes)
    ti = fltarr(ntimes)
    alts = reform(data_n(0,0,2,*))/1000.
    f2min = min(where(alts ge 200.0))
    for itime = 0L, ntimes - 1 do begin
        nmf2(itime) = max(data_n(0,itime,32,f2min:nalts-3),imax)
        hmf2(itime) = data_n(0,itime,2,imax+f2min)/1000.
       ; if itime mod 5 eq 0 then begin
       ;     name = 'plot'+chopr('00'+tostr(itime),3)+'.ps'
       ;     setdevice,name,'p',5,.95
       ;     plot, data_n(0,itime,32,2:nalts-3),alts(2:nalts-3),xtitle = '[e-] (m!U-3!N)',$
       ;       ytitle='Altitude (km)',/xlog,xrange=[1e9,1e12],yrange=[100,700],thick=3
       ;     closedevice
       ;   
       ; endif
    endfor

    temp = min(abs(alts - alt),r)
    if r lt alt then r_l = r else r_l = r - 1
    r_h = r_l + 1
    
    a_d = alts(r_h) - alts(r_l)
    a_m = alts(r_h) - alt
    
    data(0,0:ntimes-1) = data_n(0,*,ivars(0),r_h) - $
      (((data_n(0,*,ivars(0),r_h) - data_n(0,*,ivars(0),r_l)) * a_m) /  a_d)
    
    data(1,0:ntimes-1) = nmf2
    
    data(2,0:ntimes-1) = hmf2
    
    data(3,0:ntimes-1) = data_n(0,*,ivars(1),r_h) - $
      (((data_n(0,*,ivars(1),r_h) - data_n(0,*,ivars(1),r_l)) * a_m) /  a_d)
    
    data(4,0:ntimes-1) = data_n(0,*,ivars(2),r_h) - $
      (((data_n(0,*,ivars(2),r_h) - data_n(0,*,ivars(2),r_l)) * a_m) /  a_d)
endif

if n_elements(raddir) eq 0 then raddir = '.'
raddir = ask('which radar directory to plot: ',raddir)
radfile = file_search(raddir+'/*.txt')

if n_elements(radfile) gt 1 then begin
    dislay, radfile
    if n_elements(iradfile) eq 0 then iradfile = 0
    iradfile = fix(ask('which file: ',tostr(iradfile)))
endif else begin
    iradfile = 0
endelse

if strlen(radfile(0)) lt 0 then begin
    print, 'No radar files in directory ', raddir
    stop
endif

radfile = radfile(iradfile)

nrlines_new = file_lines(radfile)
if n_elements(nrlines) eq 0 then nrlines = 0
if nrlines_new eq nrlines then rereadrad = 0 else rereadrad = 1
if not rereadrad then begin
    rereadrad = 'n'
    rereadrad = ask('whether to reread radar data: ',rereadrad)
    if strpos(rereadrad,'n') ge 0 then rereadrad = 0 else rereadrad = 1
endif
nrlines = nrlines_new



t = ''
line = 0

if rereadrad then begin
rdata = fltarr(nrlines,5)
rrtime = fltarr(nrlines)
    openr,1,radfile
    while not eof(1) do begin
        readf,1, t
        temp = strsplit(t,/extract)
        
        if n_elements(temp) eq 7 then begin
            temp2 = temp
            temp = fltarr(8)
            temp(0:3) = temp2(0:3)
            temp(4) = strmid(tostr(temp2(4)),0,5)
            temp(5) = strmid(tostr(temp2(4)),6)
            temp(6:7) = temp2(5:6)
        endif
        ryear = fix(temp(0))
        if ryear lt 2000 then ryear = ryear + 2000
        doy = fix(temp(1))
        if doy gt 365 then doy = doy - 365
        ut = float(temp(2))
        rdata(line,0) = float(temp(7))
        rdata(line,1) = float(temp(3))
        rdata(line,2) = float(temp(4))
        rdata(line,3) = float(temp(5))
        rdata(line,4) = float(temp(6))
        
        dt = [ryear,doy,0,0,0]
        rdate = date_conv(dt,'F')
        rmon = strmid(rdate,5,2)
        rday = strmid(rdate,8,2)
        rhour = ut
        rmin = (ut-fix(ut))*60.
        rsec = (rmin - fix(rmin))*60.
        ritime = [ryear,rmon,rday,fix(rhour),fix(rmin),fix(rsec)]
        c_a_to_r,ritime,rt
        rrtime(line) = rt
        
        line = line + 1

    endwhile
    close,1
endif

stime = time(0)
etime = max(time)

c_r_to_a,istime,stime
c_r_to_a,ietime,etime


display, vars
if n_elements(pvar) eq 0 then pvar = 0
pvar = fix(ask('which variable to plot: ',tostr(pvar)))



setdevice, 'plot.ps', 'p',5,.95
ppp = 4
space = 0.1
pos_space, ppp, space, sizes,ny=ppp

loadct, 39

;for imon = 0, 9 do begin
;    if imon mod 4 eq 0 then plotdumb
imon = 0
print, 'GITM data is available from : '
print, tostr(istime),' through: ',tostr(ietime)
if n_elements(ctimestart) eq 0 then ctimestart = ' '
if n_elements(ctimeend) eq 0 then ctimeend = ' '
ctimestart = ask('start time (-1 for entire range or yyyy mon day hour min sec): ',ctimestart);;

if ctimestart(0) ne -1 then begin
    ctimeend = ask('end time: ',ctimeend)
    
    itimestart = fix(strsplit(ctimestart,/extract))
    itimeend = fix(strsplit(ctimeend,/extract))
    
    c_a_to_r,itimestart,stime
    c_a_to_r,itimeend,etime
endif
;    isyear = istime(0)
;    ismon = istime(1) + imon
;    if ismon gt 12 then begin
;        ismon = ismon-12
;        isyear = isyear + 1
;    endif
;
;    iemon = istime(1) + imon + 1
;    if iemon gt 12 then iemon = iemon-12
;    
;    itimestart = [isyear,ismon,1,0,0,0]
;    
;    itimeend = [isyear,iemon,1,0,0,0]
;
;    c_a_to_r,itimestart,stime
;    c_a_to_r,itimeend,etime

time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
xrange = [0,etime-stime]

loc = where(rrtime ge stime)
sloc = loc(0)
loc = where(rrtime ge etime)
eloc = loc(0)

values = reform(data(pvar,*))
rvalues = reform(rdata(*,pvar))
case pvar of
    0: begin
        var = alog10(values)
        rvar = alog10(rvalues)
        yrange = [9,12]
        ytitle = Vars(pvar)+' at 300 km'
    end
    1: begin
        var = alog10(values)
        rvar = alog10(rvalues)
        yrange = [9,12]
        ytitle = Vars(pvar)
    end
    2: begin
        var = values
        rvar = rvalues
        yrange = [100,500]
        ytitle = Vars(pvar)
    end
    else: begin
        var = values
        rvar = rvalues
        yrange = [700,1700]
        ytitle = Vars(pvar)+' at 300 km'
    end
endcase

;if imon lt 2 then begin
;    xtitle =  ' '
;    xticknames = strarr(10) + ' '
;endif

get_position, ppp, space, sizes, imon mod 4, pos, /rect
pos(0) = pos(0)+.05
pos(2) = pos(2)+.05
;pos(3) = pos(3) - .1

plot, [0,etime-stime],/nodata,xrange = xrange,yrange = yrange, ystyle = 1, $
  xtitle = xtitle, ytitle = ytitle, xticks=xtickn, xtickv=xtickv,xminor = xminor, $
  xtickname = xtickname, pos = pos,charsize = 1.3,/noerase

oplot, time-stime,var,thick=3
oplot, rrtime(sloc:eloc)-stime,rvar(sloc:eloc),color = 254, linestyle = 2,thick=3
legend,['GITM',directory],linestyle=[0,2],color=[0,254],pos = [pos(2) - .2,pos(1)+.05],$
  /norm,box=0


;endfor
closedevice



end