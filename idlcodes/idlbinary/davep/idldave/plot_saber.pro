;file = 'timed_l2av7_saber_200509070542_v01.cdf'
;date = '20050907'
files = file_search('timed*.cdf')
nfiles = n_elements(files)


nrecsmax = 300
naltsmax  = 500
iline = 0

reread = 1
if n_elements(fileold) eq 0 then fileold = ' ' 
if files(0) eq fileold then begin
    reread = 'n'
    reread = ask('whether to reread data: ',reread)
    if strpos(reread,'y') ge 0 then reread = 1 else reread = 0
endif
fileold = files(0)
if reread then begin
    nrecs = intarr(nfiles)
    nalts = intarr(nfiles)
    altitude = fltarr(naltsmax,nfiles*nrecsmax)
    latitude = fltarr(naltsmax,nfiles*nrecsmax)
    longitude = fltarr(naltsmax,nfiles*nrecsmax)
    no = altitude
    temp = altitude
    density = altitude
    sza = altitude
    o2 = altitude
    o2_unfilt = altitude
    no120 = fltarr(nfiles*nrecsmax)
    orbitstime = fltarr(nfiles)
    date = fltarr(nfiles*nrecsmax)
    time = altitude
    szaave = date
    slt = sza
    sltave = szaave

nvars = 5

    for ifile = 0, nfiles - 1 do begin
        file = files(ifile)
        id = cdf_open(file)
        result = cdf_inquire(id)
        
        cdf_control,id,var='event',/z,get_var_info=v
        nrecs(ifile) = v.maxrec
        nzVars = result.nzVars
        natts = result.natts
        svars = strarr(nzVars)

        for i=0,nzVars-1 do begin
            r = cdf_varinq(id,i,/z)
            svars(i) = r.name
            if ifile eq 0 then  print, r.name, i
        endfor
        
        
        cdf_varget, id, 1, event,rec_count=nrecs(ifile),/z
        cdf_varget, id, 16, t,rec_count=nrecs(ifile),/z
        cdf_varget, id, 2, dte,rec_count=nrecs(ifile),/z
        cdf_varget, id, 33,lon,rec_count=nrecs(ifile),/z
        cdf_varget, id, 32, lat,rec_count=nrecs(ifile),/z
        cdf_varget, id, 31, alt,rec_count=nrecs(ifile),/z
        cdf_varget, id, 34, tpsza,rec_count=nrecs(ifile),/z
        cdf_varget, id, 27, tpszaave,rec_count=nrecs(ifile),/z
        cdf_varget, id, 36, tpslt,rec_count=nrecs(ifile),/z
        cdf_varget, id, 29, tpsltave,rec_count=nrecs(ifile),/z
        cdf_varget, id, 89, no_ver,rec_count=nrecs(ifile),/z
        cdf_varget, id, 55, dens,rec_count=nrecs(ifile),/z
        cdf_varget, id, 53, ktemp,rec_count=nrecs(ifile),/z
        cdf_varget, id, 91, no_ver120,rec_count=nrecs(ifile),/z
        cdf_varget, id, 70, o2_ver,rec_count=nrecs(ifile),/z
        cdf_varget, id, 68, o2_ver_unfilt,rec_count=nrecs(ifile),/z
        
        nalts(ifile) = n_elements(alt(*,0))
        
        altitude(0:nalts(ifile)-1,iline:nrecs(ifile)+iline-1) = alt  
        latitude(0:nalts(ifile)-1,iline:nrecs(ifile)+iline-1) = lat
        longitude(0:nalts(ifile)-1,iline:nrecs(ifile)+iline-1) = lon  
        no(0:nalts(ifile)-1,iline:nrecs(ifile)+iline-1) = no_ver
        o2(0:nalts(ifile)-1,iline:nrecs(ifile)+iline-1) = o2_ver
        o2_unfilt(0:nalts(ifile)-1,iline:nrecs(ifile)+iline-1) = o2_ver_unfilt
        temp(0:nalts(ifile)-1,iline:nrecs(ifile)+iline-1) = ktemp
        density(0:nalts(ifile)-1,iline:nrecs(ifile)+iline-1) = dens
        no120(iline:nrecs(ifile)+iline-1) = no_ver120
        date(iline:nrecs(ifile)+iline-1) = dte
        time(0:nalts(ifile)-1,iline:nrecs(ifile)+iline-1) = t
        sza(0:nalts(ifile)-1,iline:nrecs(ifile)+iline-1) = tpsza
        szaave(iline:nrecs(ifile)+iline-1) = tpszaave
        slt(0:nalts(ifile)-1,iline:nrecs(ifile)+iline-1) = tpslt
        sltave(iline:nrecs(ifile)+iline-1) = tpsltave
        iline = iline + nrecs(ifile)
        cdf_close,id

        cdate = tostr(dte(0))
        hour = t(0)/1000./3600.
        ih = fix(hour)
        im = fix((hour-ih)*60.)
        is  = fix(((hour-ih)*60-im)*60)
        iy = fix(strmid(cdate,0,4))
        doy = fix(strmid(cdate,4,3))
        dt = fromjday(iy,doy)
        imo = dt(0)
        id = dt(1)
        it = [iy,imo,id,ih,im,is]
        c_a_to_r,it,rt
        orbitstime(ifile) = rt
    endfor
    maxalts = max(nalts)
    altitude = altitude(0:maxalts-1,0:iline-1)
    latitude = latitude(0:maxalts-1,0:iline-1)
    longitude = longitude(0:maxalts-1,0:iline-1)
    no = no(0:maxalts-1,0:iline-1)
    o2 = o2(0:maxalts-1,0:iline-1)
    o2_unfilt=o2_unfilt(0:maxalts-1,0:iline-1)
    temp = temp(0:maxalts-1,0:iline-1)
    density = density(0:maxalts-1,0:iline-1)
    time = time(0:maxalts-1,0:iline-1)
    no120 = no120(0:iline-1)
    date = date(0:iline-1)
    szaave = szaave(0:iline-1)
    sza = sza(0:maxalts-1,0:iline-1)
    sltave = sltave(0:iline-1)
    slt = slt(0:maxalts-1,0:iline-1)


    ntimes = n_elements(altitude(0,*))
    data = fltarr(nvars,maxalts,iline)
    rtime = dblarr(maxalts,ntimes)
    cdate = tostr(date(0))
    hour = time(0,0)/1000./3600.
    ih = fix(hour)
    im = fix((hour-ih)*60.)
    is  = fix(((hour-ih)*60-im)*60)
    iy = fix(strmid(cdate,0,4))
    doy = fix(strmid(cdate,4,3))
    dt = fromjday(iy,doy)
    imo = dt(0)
    id = dt(1)
    it = [iy,imo,id,ih,im,is]
    c_a_to_r,it,rt
    rtime(*,0) = rt

    for itime = 1, ntimes -1 do begin
        for ialt = 0, maxalts - 1 do begin
            if no(ialt,itime) lt 0 then begin
                no(ialt,itime) = (no(ialt,itime-1)) 
                o2(ialt,itime) = (o2(ialt,itime-1)) 
                o2_unfilt(ialt,itime) = (o2_unfilt(ialt,itime-1)) 
                temp(ialt,itime) = (temp(ialt,itime-1))
                altitude(ialt,itime) = (altitude(ialt,itime-1))
                density(ialt,itime) = (density(ialt,itime-1))
            endif           
            hour = time(ialt,itime)/1000./3600.
            ih = fix(hour)
            im = fix((hour-ih)*60.)
            is  = fix(((hour-ih)*60-im)*60)
            
            cdate = tostr(date(itime))
            iy = fix(strmid(cdate,0,4))
            doy = fix(strmid(cdate,4,3))
            dt = fromjday(iy,doy)
            imo = dt(0)
            id = dt(1)
            if ih gt 23 then begin
                ih = ih - 24
            endif
            it = [iy,imo,id,ih,im,is]
            c_a_to_r,it,rt
            rtime(ialt,itime) = rt
;if rt eq stime then stop
        endfor
    endfor
    Vars = ['NO_ver','O2_ver','Temperature','Density','O2_ver(unfiltered)']
    data(0,*,*) = no
    data(1,*,*) = o2
    data(2,*,*) = temp
    data(3,*,*) = density
    data(4,*,*) = o2_unfilt
endif

stime  = rtime(0,0)
etime = max(rtime)
c_r_to_a,ist,stime
c_r_to_a,iet,etime

print,' '
print,'Available time range',ist,' through ',iet
if n_elements(istarttime) eq 0 then istarttime = ist
if n_elements(iendtime) eq 0 then iendtime = iet

istarttime = fix(strsplit(ask('start time: ',strjoin(tostr(istarttime),' ')),/extract))
iendtime = fix(strsplit(ask('end time: ',strjoin(tostr(iendtime),' ')),/extract))
c_a_to_r,istarttime,stime
c_a_to_r,iendtime,etime

time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn

hour = time/1000./3600.
xrange = [0,etime-stime]
yrange = [90,150]
display,vars
if n_elements(pvar) eq 0 then pvar = 0
pvar = fix(ask('which variable to plot: ',tostr(pvar)))
value = reform(data(pvar,*,*))

alt = findgen(11)*5+100
display,alt
if n_elements(palt1) eq 0 then palt1 = 0
if n_elements(palt2) eq 0 then palt2 = 0
palt1 = fix(ask('1st altitude to plot: ',tostr(palt1)))
palt2 = fix(ask('2nd altitude to plot: ',tostr(palt2)))
alocs1 = where(altitude(*,0) ge alt(palt1)-2.5 and altitude(*,0) lt alt(palt1)+2.5)
alocs2 = where(altitude(*,0) ge alt(palt2)-2.5 and altitude(*,0) lt alt(palt2)+2.5)

nomax1 = fltarr(ntimes)
nomax2 = fltarr(ntimes)
z_no = fltarr(ntimes)
amin = 90
for itime = 0, ntimes - 1 do begin
    imin = max(where(altitude(*,itime) ge amin))
    nomaxt = max(value(0:imin,itime),im)
    nomax1(itime) = mean(value(alocs1,itime))
    nomax2(itime) = mean(value(alocs2,itime))
    z_no(itime) = altitude(im)
endfor
noorbavg = fltarr(nfiles)
nozorbavg = fltarr(nfiles)
szaorbavg = fltarr(nfiles)
orbitstime = [orbitstime,max(rtime)]
orbittime = fltarr(nfiles)
;for ifile = 0, nfiles - 1 do begin
;    locs = where(rtime(0,*) ge orbitstime(ifile) and rtime(0,*) lt orbitstime(ifile+1))
;    noorbavg1(ifile) = mean(nomax1(locs));
;    noorbavg1(ifile) = mean(nomax2(locs))
;    orbittime(ifile) = (orbitstime(ifile) + orbitstime(ifile+1))/2.
;    nozorbavg(ifile) = mean(z_no(locs))
;endfor

nflares = 8
 rft = dblarr(nflares)
ftime = [2005,01,15,22,40,0]
c_a_to_r,ftime,rt
rft(0) = rt
ftime = [2005,01,17,9,20,0]
c_a_to_r,ftime,rt
rft(1)=rt

ftime = [2003,10,28,11,0,0]
c_a_to_r,ftime,rt
rft(2)=rt
ftime = [2003,11,2,17,15,0]
c_a_to_r,ftime,rt
rft(3)=rt
ftime = [2003,11,4,19,40,0]
c_a_to_r,ftime,rt
rft(4)=rt
ftime = [2005,01,20,6,45,0]
c_a_to_r,ftime,rt
rft(5)=rt
ftime = [2005,09,7,17,25,0]
c_a_to_r,ftime,rt
rft(6)=rt
ftime = [2005,9,9,19,35,0]
c_a_to_r,ftime,rt
rft(7)=rt
;------- All Data -------------------
nflares = 1
 rft = dblarr(nflares)
;ftime = [2003,11,02,17,15,0]
ftime = [2005,1,20,6,45,0]
c_a_to_r,ftime,rt
rft(0) = rt
;ftime = [2003,11,4,19,40,0]
ftime = [2005,1,20,6,45,0]
c_a_to_r,ftime,rt
rft(1)=rt


file = vars(pvar)+'_'+tostr(istarttime(0))+chopr('0'+tostr(istarttime(1)),2)+ $
  chopr('0'+tostr(istarttime(2)),2)+'.ps'
setdevice,file,'p',5,.95
loadct, 39
ppp = 4
space = 0.03
pos_space, ppp, space, sizes, ny = ppp
get_position, ppp, space, sizes, 0, pos, /rect
get_position, ppp, space, sizes, 1, pos1, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
pos(1) = pos1(1)

locs = where(altitude gt 90 and value gt 0)
if n_elements(islog) eq 0 then islog = 'y'
islog = ask('whether to plot log: ',islog)

if islog eq 'y' then logno = alog10(value) else logno = value
range  = mm(logno(locs))

levels = findgen(31) * (range(1)-range(0)) / 30 + range(0)

contour,logno,rtime-stime,altitude,/fill,/follow,$
  levels=levels,yrange=yrange,xrange = xrange,pos=pos,xstyle=1,$
  xtickname = strarr(10)+ ' ',xtickv=xtickv,xticks=xtickn,xminor=xminor,$
  charsize = 1.3,ytitle='Altitude',/noerase
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor
;oplot, [0,etime-stime],[120,120],linestyle = 2,thick = 2
ctpos = pos
if islog eq 'y' then title = 'Log '+vars(pvar) else title = vars(pvar)
ctpos(0) = pos(2)+0.025
ctpos(2) = ctpos(0)+0.03
maxmin = range
plotct, 255, ctpos, maxmin, title, /right

get_position, ppp, space, sizes, 2, pos, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
;pos(1) = pos(1) + 0.2
pos1 = pos
pos1(1) = (pos(1)+pos(3))/2+.01

locs = where(nomax2 gt 0 and rtime(0,*) ge stime and rtime(0,*) le etime)

yrange = mm(nomax2(locs))
plot, rtime(0,locs)-stime,nomax2(locs),min_value=0,pos=pos1,xtickname=strarr(10)+' ',$
  xticks=xtickn,xtickv=xtickv,xminor=xminor,charsize=1.3,$
  ytitle = vars(pvar)+'!C('+tostr(Alt(palt2))+')',thick = 3,/noerase,$
  xrange=xrange,yrange=yrange,psym=sym(1),ystyle = 1,symsize=.8
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor

pos(3) = (pos(1)+pos(3))/2-.01
locs = where(nomax1 gt 0 and rtime(0,*) ge stime and rtime(0,*) le etime)
yrange = mm(nomax1(locs))
plot, rtime(0,locs)-stime,nomax1(locs),min_value=0,pos=pos,xtickname=strarr(10)+' ',$
  xticks=xtickn,xtickv=xtickv,xminor=xminor,charsize=1.3,$
  ytitle = vars(pvar)+'!C('+tostr(Alt(palt1))+')',thick = 3,/noerase,$
  xrange=xrange,yrange=yrange,psym=sym(1),ystyle = 1,symsize=.8
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor

;yrange = [90,150]
;axis,yaxis=1,yrange=yrange,ystyle=1,ytitle='Altitude of '+vars(pvar)+' Peak',/save
;oplot, rtime(0,locs)-stime,z_no(locs),psym=sym(4),color = 70,symsize=.5

get_position, ppp, space, sizes, 3, pos, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
yrange = [0,90]
plot, rtime(0,locs)-stime,szaave(locs),pos=pos,xtickname=xtickname,$
  xticks=xtickn,xtickv=xtickv,xminor=xminor,xtitle=xtitle,charsize=1.3,$
  ytitle = 'SZA',thick = 3,/noerase,$
  xrange=xrange,yrange=yrange,psym=sym(4),symsize=.8
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor
;yrange = [90,150]
;axis,yaxis=1,yrange=yrange,ystyle=1,ytitle='Altitude of '+vars(pvar)+' Peak',/save
;oplot, orbittime-stime,nozorbavg,thick = 3,color = 70,symsize=.5,psym=-sym(4)


;pos(1) = pos(1) + 0.2
;locs = where(no120 gt 0 and rtime(0,*) ge stime and rtime(0,*) le etime)
;yrange = mm(no120(locs))
;plot, rtime(0,*)-stime,no120,min_value=0,pos=pos,xtickname=xtickname,$
;  xticks=xtickn,xtickv=xtickv,xminor=xminor,xtitle=xtitle,charsize=1.3,$
;  ytitle = 'NO Volume Emmision Rate !C(120 km )(erg/cm!U3!N/s)',thick = 3,/noerase,$
;  xrange=xrange,yrange=yrange


closedevice

;----------- Dayside -----------------------
file = vars(pvar)+'_'+tostr(istarttime(0))+chopr('0'+tostr(istarttime(1)),2)+ $
  chopr('0'+tostr(istarttime(2)),2)+'_day.ps'
setdevice,file,'p',5,.95
loadct, 39
ppp = 4
space = 0.03
pos_space, ppp, space, sizes, ny = ppp
get_position, ppp, space, sizes, 0, pos, /rect
get_position, ppp, space, sizes, 1, pos1, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
pos(1) = pos1(1)

minsza = min(szaave)
szalocs = where(szaave le minsza + 20)

noday = value(*,szalocs)
rtimeday = rtime(*,szalocs)
altday = altitude(*,szalocs)
avelt = mean(sltave(szalocs))
locs = where(altday gt 90 and noday gt 0)
;if islog eq 'y' then noday = alog10(noday)
range  = mm(noday(locs))
;range(1) = 1e-10

levels = findgen(31) * (range(1)-range(0)) / 30 + range(0)
yrange = [90,150]
contour,noday,rtimeday-stime,altday,/fill,/follow,$
  levels=levels,yrange=yrange,xrange = xrange,pos=pos,xstyle=1,$
  xtickname = strarr(10)+ ' ',xtickv=xtickv,xticks=xtickn,xminor=xminor,$
  charsize = 1.3,ytitle='Altitude',/noerase
;oplot, [0,etime-stime],[120,120],linestyle = 2,thick = 2
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor
xyouts, pos(2) - .2,pos(3) + .04,'Local time: '+tostrf(avelt),/norm
xyouts, pos(2) - .2,pos(3) + .02,'Min SZA: '+tostrf(minsza),/norm
ctpos = pos
title = vars(pvar)
ctpos(0) = pos(2)+0.025
ctpos(2) = ctpos(0)+0.03
maxmin = range
plotct, 255, ctpos, maxmin, title, /right

get_position, ppp, space, sizes, 2, pos, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
;pos(1) = pos(1) + 0.2
pos1 = pos
pos1(1) = (pos(1)+pos(3))/2+.01

locs = where(nomax2 gt 0 and rtime(0,*) ge stime and rtime(0,*) le etime and $
            szaave le minsza+20)

yrange = mm(nomax2(locs))
plot, rtime(0,locs)-stime,nomax2(locs),min_value=0,pos=pos1,xtickname=strarr(10)+' ',$
  xticks=xtickn,xtickv=xtickv,xminor=xminor,charsize=1.3,$
  ytitle =vars(pvar)+'!C('+tostr(Alt(palt2))+')',thick = 3,/noerase,$
  xrange=xrange,yrange=yrange,psym=sym(1),ystyle = 1,symsize=.8
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor

pos(3) = (pos(1)+pos(3))/2-.01
locs = where(nomax1 gt 0 and rtime(0,*) ge stime and rtime(0,*) le etime and $
            szaave le minsza+20)
yrange = mm(nomax1(locs))
plot, rtime(0,locs)-stime,nomax1(locs),min_value=0,pos=pos,xtickname=strarr(10)+' ',$
  xticks=xtickn,xtickv=xtickv,xminor=xminor,charsize=1.3,$
  ytitle =vars(pvar)+'!C('+tostr(Alt(palt1))+')',thick = 3,/noerase,$
  xrange=xrange,yrange=yrange,psym=sym(1),ystyle = 1,symsize=.8
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor

get_position, ppp, space, sizes, 3, pos, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
;pos(1) = pos(1) + 0.2
yrange = [0,90]
plot, rtime(0,locs)-stime,szaave(locs),pos=pos,xtickname=xtickname,$
  xticks=xtickn,xtickv=xtickv,xminor=xminor,xtitle=xtitle,charsize=1.3,$
  ytitle ='SZA',thick = 3,/noerase,$
  xrange=xrange,yrange=yrange,psym=sym(4),symsize=.8
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor
;yrange = [90,150]
;axis,yaxis=1,yrange=yrange,ystyle=1,ytitle='Altitude of '+vars(pvar)+' Peak',/save
;oplot, daytavg-stime,nozdayavg,thick = 3,color = 70,symsize=.5,psym=-sym(4)

closedevice
;----------- Nightside -----------------------
file =vars(pvar)+'_'+tostr(istarttime(0))+chopr('0'+tostr(istarttime(1)),2)+ $
  chopr('0'+tostr(istarttime(2)),2)+'_night.ps'
setdevice,file,'p',5,.95
loadct, 39
ppp = 4
space = 0.03
pos_space, ppp, space, sizes, ny = ppp
get_position, ppp, space, sizes, 0, pos, /rect
get_position, ppp, space, sizes, 1, pos1, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
pos(1) = pos1(1)

maxsza = max(szaave)
szalocs = where(szaave ge maxsza - 20)
nonight = value(*,szalocs)
rtimenight = rtime(*,szalocs)
altnight = altitude(*,szalocs)
avelt = mean(sltave(szalocs))
locs = where(altnight gt 90 and nonight gt 0)
range  = mm(nonight(locs))

levels = findgen(31) * (range(1)-range(0)) / 30 + range(0)
yrange = [90,150]
contour,nonight,rtimenight-stime,altnight,/fill,/follow,$
  levels=levels,yrange=yrange,xrange = xrange,pos=pos,xstyle=1,$
  xtickname = strarr(10)+ ' ',xtickv=xtickv,xticks=xtickn,xminor=xminor,$
  charsize = 1.3,ytitle='Altitude',/noerase
;oplot, [0,etime-stime],[120,120],linestyle = 2,thick = 2
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor
xyouts, pos(2) - .2,pos(3) + .04,'Local time: '+tostrf(avelt),/norm
xyouts, pos(2) - .2,pos(3) + .02,'Max SZA: '+tostrf(maxsza),/norm
ctpos = pos
title = vars(pvar)
ctpos(0) = pos(2)+0.025
ctpos(2) = ctpos(0)+0.03
maxmin = range
plotct, 255, ctpos, maxmin, title, /right

get_position, ppp, space, sizes, 2, pos, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
;pos(1) = pos(1) + 0.2

pos1 = pos
pos1(1) = (pos(1)+pos(3))/2+.01

locs = where(nomax2 gt 0 and rtime(0,*) ge stime and rtime(0,*) le etime and $
            szaave ge maxsza-20)

yrange = mm(nomax2(locs))
plot, rtime(0,locs)-stime,nomax2(locs),min_value=0,pos=pos1,xtickname=strarr(10)+' ',$
  xticks=xtickn,xtickv=xtickv,xminor=xminor,charsize=1.3,$
  ytitle = vars(pvar)+'!C('+tostr(Alt(palt2))+')',thick = 3,/noerase,$
  xrange=xrange,yrange=yrange,psym=sym(1),ystyle = 1,symsize=.8
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor

pos(3) = (pos(1)+pos(3))/2-.01
locs = where(nomax1 gt 0 and rtime(0,*) ge stime and rtime(0,*) le etime and $
            szaave le maxsza-20)

yrange = mm(nomax1(locs))
plot, rtime(0,locs)-stime,nomax1(locs),min_value=0,pos=pos,xtickname=strarr(10)+' ',$
  xticks=xtickn,xtickv=xtickv,xminor=xminor,charsize=1.3,$
  ytitle =vars(pvar)+'!C('+tostr(Alt(palt1))+')',thick = 3,/noerase,$
  xrange=xrange,yrange=yrange,psym=sym(1),ystyle = 1,symsize=.8
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor


get_position, ppp, space, sizes, 3, pos, /rect
pos(0) = pos(0) + 0.1
pos(2) = pos(2) - .1
;pos(1) = pos(1) + 0.2

plot, rtime(0,locs)-stime,szaave,pos=pos,xtickname=xtickname,$
  xticks=xtickn,xtickv=xtickv,xminor=xminor,xtitle=xtitle,charsize=1.3,$
  ytitle = 'SZA',thick = 3,/noerase,$
  xrange=xrange,yrange=yrange,psym=sym(4),symsize=.8
for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-1000,1000],linestyle = 2
endfor

;yrange = [90,150]
;axis,yaxis=1,yrange=yrange,ystyle=1,ytitle='Altitude of '+vars(pvar)+' Peak',/save
;oplot, nighttavg-stime,noznightavg,thick = 3,color = 70,symsize=.5,psym=-sym(4)


closedevice

end

