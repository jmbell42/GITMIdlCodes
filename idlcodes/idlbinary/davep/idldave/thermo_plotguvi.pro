reread = 1
if (n_elements(val) gt 0) then begin
    answer = ask('whether to re-read data','n')
    if (strpos(mklower(answer),'n') gt -1) then reread = 0
endif

if (reread) then begin

    if (n_elements(dir) eq 0) then dir = '.'
    dir = ask('GITM directory',dir)

    filelist = file_search(dir+'/guvi*.bin')
    
    file = filelist(0)
    length = strpos(file,'.bin')
    ls = length-13
    
    yr = strmid(file,ls,2)
    iYear = tostr(2000+fix(yr))
    iMonth = strmid(file,ls+2,2)
    iDay = strmid(file,ls+4,2)
    cday = iday
    guvidir = '~/guvi/'+tostr(iyear)+'/'
    doy = jday(fix(iyear), fix(imonth), fix(iday))
    ndays = 1

    thermo_readsat, filelist, data, time, nTimes, Vars, nAlts, nSats, nTimes

   

    GitmAlts = reform(data(0,0,2,*))/1000.0
    GITMD = fltarr(4,nalts,ntimes)
    GitmD(0,*,*) = transpose(reform(data(0,*,4,*)))
    GitmD(1,*,*) = transpose(reform(data(0,*,6,*)))
    GitmD(2,*,*) = transpose(reform(data(0,*,5,*)))
    GitmD(3,*,*) = transpose(reform(data(0,*,15,*)))

    GitmLons = reform(data(0,*,0,0))*180.0/!pi
    GitmLats = reform(data(0,*,1,0))*180.0/!pi

     itimearray = intarr(6,ntimes)    
    for itime =0, ntimes - 1 do begin
        c_r_to_a,ta,time(itime)
        itimearray(*,itime) = ta

        
    endfor
    c_r_to_a, itime, time(0)
    itime(3:5) = 0
    ndays = round((time(ntimes-1)-time(0))/3600. /24.)

    c_a_to_r, itime, basetime
    hour = (time/3600.0 mod 24.0) + fix((time-basetime)/(24.0*3600.0))*24.0
    localtime = (reform(GitmLons(*,0))/15.0 + hour) mod 24.0
    
    bdoy = doy
    edoy = bdoy + ndays - 1
    
    naltsmax = 100
    nscansmax = 5000
    galt = fltarr(naltsmax,nscansmax)
    o = galt
    n2 = o
    o2 = o
    t = o
    msiso2 = o
    gtime = dblarr(nscansmax)
    gday = intarr(nscansmax)
    gsza = fltarr(nscansmax)
    glat = gsza
    glon=gsza
    iscan = 0
    maxscans = 0
    maxalts = 0
    for iday = 0, ndays - 1 do begin
        guvifiles = file_search(guvidir+'*GUVI*_'+iyear+chopr('00'+tostr(doy+iday),3)+ $
                                '*.sav')
        nfiles = n_elements(guvifiles)

        for ifile = 0, nfiles - 1 do begin
            restore, guvifiles(ifile)
            
            nscans = n_elements(ndpsorbit.sec)
            nalts = n_elements(ndpsorbit(0).zm)
            if nalts gt maxalts then maxalts = nalts
            if nscans gt maxscans then maxscans = nscans
            
            for is = iscan, nscans + iscan - 1 do begin
                galt(0:nalts-1,is) = ndpsorbit(is-iscan).zm
                o(0:nalts-1,is) = ndpsorbit(is-iscan).ox*10.^6
                n2(0:nalts-1,is) = ndpsorbit(is-iscan).n2*10.^6
                o2(0:nalts-1,is) = ndpsorbit(is-iscan).o2*10.^6
                t(0:nalts-1,is) = ndpsorbit(is-iscan).t
                msiso2(0:nalts-1,is) = ndpsorbit(is-iscan).ox0*10.^6
                
                tt = fromjday(fix(iyear),ndpsorbit(is-iscan).iyd)
                month = tt(0)
                day = tt(1)
                hour = fix(ndpsorbit(is-iscan).sec/3600.)
                min = fix((ndpsorbit(is-iscan).sec/3600. - hour)*60)
                sec = fix((((ndpsorbit(is-iscan).sec/3600. -hour)*60)-min)*60)
                itime = [fix(iyear),month,day,hour,min,sec]
                
                c_a_to_r,itime,rt
                gtime(is) = rt
                gsza(is) = ndpsorbit(is-iscan).sza
                glat(is) = ndpsorbit(is-iscan).glat
                glon(is) = ndpsorbit(is-iscan).glong
                
            endfor
            iscan = is
        endfor
    endfor
    nscans = iscan
    galt = galt(0:maxalts-1,0:iscan-1)
    o = o(0:maxalts-1,0:iscan-1)
    n2 = n2(0:maxalts-1,0:iscan-1)
    o2 = o2(0:maxalts-1,0:iscan-1)
    t = t(0:maxalts-1,0:iscan-1)
    msiso2 = msiso2(0:maxalts-1,0:iscan-1)
    gtime = gtime(0:iscan-1)
    glat = glat(0:iscan-1)
    glon = glon(0:iscan-1)
    gsza = gsza(0:iscan-1)
    locs = where(glon lt 0)
    glon(locs) = 360+glon(locs)
    gdata = fltarr(5,maxalts,nscans)
    gdata(0,*,*) = o
    gdata(1,*,*) = n2
    gdata(2,*,*) = O2
    gdata(3,*,*) = T
    gdata(4,*,*) = msiso2
    
    vars = ['O','N2','O2','T','MSIS_O2']

    stime = max([time(0),gtime(0)],is)
    etime = min([time(ntimes-1),gtime(nscans-1)],ie)


    times = intarr(nscans)
    gtimes = intarr(nscans)
    it = 0

    for iscan = 0, nscans-1 do begin
        dt =  gtime(iscan) - time
        loc = min(where(dt lt 0),imin)
        if loc gt 0 then begin
            minv = min([abs(dt(loc)),abs(dt(loc-1))],im)
            if im eq 1 then loc = loc-1
        endif
        if loc lt 0 then loc = ntimes-1
            
        if abs(dt(loc)) lt 100 then begin
            times(it) = loc
            gtimes(it) = iscan
            it = it+1
        endif        
    endfor
    gtold = gtime
    szaold = gsza
    gtimes =gtimes(0:it-1)
    times = times(0:it-1)
    glat = glat(gtimes)
    glon = glon(gtimes)
    galt = galt(*,gtimes)
    gtime = gtime(gtimes)
    gsza = gsza(gtimes)
    gdata = gdata(*,*,gtimes)

    gitmd = gitmd(*,*,times)
    gitmlons = gitmlons(times)
    gitmlats = gitmlats(times)
    time = time(times)

    altlocs = where(galt(*,0) lt 500)
    galt = galt(altlocs,*)
    nalts = n_elements(altlocs)
endif

display, vars
if n_elements(pvar) eq 0 then pvar = 0
pvar = fix(ask('variable to plot: ',tostr(pvar)))

display,galt(*,0)
if n_elements(palt1) eq 0 then palt1 = 0
if n_elements(palt2) eq 0 then palt2 = 0
palt1 = fix(ask('1st altitude to plot: ',tostr(palt1)))
palt2 = fix(ask('2nd altitude to plot: ',tostr(palt2)))

ntimes = n_elements(times)
gval = reform(gdata(pvar,altlocs,*))
val = fltarr(nalts,ntimes)
for itime = 0, ntimes - 1 do begin
    for ialt = 0, nalts -1 do begin
        
     loc = min(where(GitmAlts gt galt(ialt,iTime)))
     
      x = (galt(ialt,iTime) - GitmAlts(loc-1)) / $
          (GitmAlts(loc) - GitmAlts(loc-1))

      if pvar lt 3 then $
        val(ialt,iTime) = exp((1.0 - x) * alog(GitmD(pvar,loc-1,iTime)) + $
                         (      x) * alog(GitmD(pvar,loc,iTIme))) $
      else $
        val(ialt,iTime) = (1.0 - x) * (GitmRho(pvar,loc-1,iTime)) + $
                         (      x) * (GitmD(pvar,loc,iTIme))

  endfor
endfor

time2d = fltarr(nalts,ntimes)
for ialt = 0,nalts - 1 do begin
    time2d(ialt,*) = gtime
endfor

if n_elements(islog) eq 0 then islog = 'n'
islog = ask('whether to plot log: ',islog)

if islog eq 'y' then begin
    cval = alog10(val)
    gcval = alog10(gval)
endif else begin
    cval = val
    gcval = val
endelse
nflares = 2
 rft = dblarr(nflares)
;ftime = [2003,11,02,17,15,0]
ftime = [2003,11,02,17,15,0]
ftime = [2005,9,7,17,25,0]
c_a_to_r,ftime,rt
rft(0) = rt
;ftime = [2003,11,4,19,40,0]
ftime = [2003,11,4,19,40,0]
ftime = [2005,9,9,19,35,0]
c_a_to_r,ftime,rt
rft(1)=rt

stime = gtime(0)
etime = max(gtime)
time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn

file = 'guvi_'+vars(pvar)+'_'+iyear+imonth+cday+'.ps'
setdevice,file,'p',5,.95
loadct, 39
ppp = 9
space = 0.01
pos_space, ppp, space, sizes, ny = ppp
get_position, ppp, space, sizes, 0, pos, /rect
get_position, ppp, space, sizes, 1, pos1, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
pos(1) = pos1(1)
loadct, 39

range = mm(cval)
mini = range(0)
maxi = range(1)
levels = findgen(31) * (range(1)-range(0)) / 30 + range(0)

contour,gcval,time2d-stime,galt,xtickv=xtickv,xticks=xtickn,xminor=xminor, $
  ytitle='Altitude',levels = levels,pos = pos,xtickname = strarr(10) + ' ',/noerase,$
  /fill,yrange=[100,400]
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[0,600],linestyle = 2
endfor

if islog then title = 'Log['+vars(pvar)+'] (GUVI)' else title = vars(pvar)+' GUVI'
ctpos = pos
ctpos(0) = pos(2)+0.025
ctpos(2) = ctpos(0)+0.03
maxmin = [mini,maxi]
plotct, 255, ctpos, maxmin, title, /right

get_position, ppp, space, sizes, 2, pos, /rect
get_position, ppp, space, sizes, 3, pos1, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
pos(1) = pos1(1)

contour,cval,time2d-stime,galt,xtickv=xtickv,xticks=xtickn,xminor=xminor, $
  ytitle='Altitude',levels = levels,pos = pos,xtickname=strarr(10)+' ',$
  /noerase,/fill,yrange=[100,400]
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[0,600],linestyle = 2
endfor
if islog then title = 'Log['+vars(pvar)+'] (GITM)' else title = vars(pvar)+' GITM'
ctpos = pos
ctpos(0) = pos(2)+0.025
ctpos(2) = ctpos(0)+0.03
maxmin = [mini,maxi]
plotct, 255, ctpos, maxmin, title, /right

get_position, ppp, space, sizes, 4, pos, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1

yrange = mm([gval(palt2,*),val(palt2,*)])
plot,gtime-stime,gval(palt2,*),xtickv=xtickv,xticks=xtickn,xminor=xminor,$
  xrange=[0,etr],pos=pos,ytitle='['+vars(pvar)+'] ('+tostr(galt(palt2,0)) +' km)',/noerase,xtickname=strarr(10)+' ',psym = sym(1),symsize = .5,yrange=yrange
oplot,gtime-stime,val(palt2,*),color = 60,psym=sym(5),symsize = .5
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[0,1e15],linestyle = 2
endfor

legend,['GUVI'],psym=[sym(1)],color=[0],box=0,$
  pos = [pos(2)+.006,pos(3)-.04],  /norm,symsize=.5
legend,['GITM'],psym=[sym(5)],color=[60],box=0,$
  pos = [pos(2)+.006,pos(3)-.06],  /norm,symsize=.5


get_position, ppp, space, sizes, 5, pos, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1

yrange = mm([gval(palt1,*),val(palt1,*)])
plot,gtime-stime,gval(palt1,*),xtickv=xtickv,xticks=xtickn,xminor=xminor,$
  xrange=[0,etr],pos=pos,ytitle='['+vars(pvar)+'] ('+tostr(galt(palt1,0)) +' km)',$
  /noerase,xtickname=strarr(10)+' ',psym = sym(1),symsize = .5,yrange=yrange
oplot,gtime-stime,val(palt1,*),color = 60,psym=sym(5),symsize = .5
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[0,1e20],linestyle = 2
endfor

get_position, ppp, space, sizes, 6, pos, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1

plot,gtime-stime,gsza,xtickv=xtickv,xticks=xtickn,xminor=xminor,$
  xrange=[0,etr],pos=pos,ytitle='SZA',$
  /noerase,xtickname=strarr(10)+' ',psym = sym(1),symsize = .5
oplot,gtime-stime,val(palt1,*),color = 60,psym=sym(5),symsize = .5
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[0,1000],linestyle = 2
endfor

xrange = [0,etr]
readdst,iyear,dst,dsttime
;dlocs = where(dsttime ge stime and dsttime le etime)
get_position, ppp, space, sizes, 7, pos, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
plot,dsttime-stime,dst,ytitle='Dst (nT)',/noerase,pos=pos,$
  xtickv=xtickv,xticks=xtickn,xrange=xrange,$
  xtickname=strarr(10)+' ',xminor=xminor,yrange = [-100,50],ystyle=1
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor


readkp,iyear,kp,kptime
;klocs = where(kptime ge stime and kptime le etime)
get_position, ppp, space, sizes, 8, pos, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
plot,kptime-stime,kp,ytitle='Kp',/noerase,pos=pos,$
  xtickv=xtickv,xticks=xtickn,xrange=xrange,$
  xtickname=xtickname,xminor=xminor,xtitle=xtitle,yrange = [0,9]
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor

closedevice


end

