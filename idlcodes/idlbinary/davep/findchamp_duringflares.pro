if n_elements(cyear) eq 0 then cyear = '2001'
cyear = ask("which year to search: ",cyear)

flarefile = '/Users/dpawlows/UpperAtmosphere/GOES/xclass/flares'+cyear+'.dat'
fn = file_search(flarefile)
if n_elements(fn) lt 1 then begin
    print, 'There is no flare file for that date'
    stop
endif

if n_elements(whichsat) eq 0 then whichsat = ' '
whichsat = ask('Champ or Grace ',whichsat)
whichsat = strlowcase(whichsat)
case whichsat of 
   'grace': champdir = '/Users/dpawlows/UpperAtmosphere/GRACE/data/'+cyear+'/'
   'champ': champdir = '/Users/dpawlows/UpperAtmosphere/CHAMP/data/'+cyear+'/'
endcase

close,/all
openr,1,fn
temp = ' '
nevents = file_lines(fn)
npointsmax = 10000
ChampDensity = fltarr(nevents,npointsmax)
ChampPosition = fltarr(nevents,3,npointsmax)
ChampTime = dblarr(nevents,npointsmax)
ChampLocalTime = fltarr(nevents,npointsmax)
npoints = intarr(nevents)

ievent = 0
while not eof(1) do begin
    
    readf,1, temp
    t = strsplit(temp,/extract)
    timearr = t(4:9)
    length = fix(t(12))
    c_a_to_r,timearr,rtime
    stime = rtime - 6*3600.
    etime = rtime + 24 * 3600.
    retime = rtime+length*60

    if t(1) gt 1e-4 then begin
    c_r_to_a,starr,stime
    c_r_to_a,etarr,etime

    cyears = strmid(tostr(starr(0)),2,2)
    doys = jday(starr(0),starr(1),starr(2))
    if timearr(1) eq 1 and timearr(2) eq 1 then begin
        doys = 1 
        cyears = strmid(tostr(timearr(0)),2,2)
    endif
    cyeare = strmid(tostr(etarr(0)),2,2)
    doye = jday(etarr(0),etarr(1),etarr(2))
    
    ndays = doye - doys + 1
    champfile = strarr(ndays)
    
    case whichsat of
       'champ': begin
          champ_start_file = champdir+'Density_3deg_'+cyears+'_'+$
                             chopr('00'+tostr(doys),3)+'.ascii'
          champ_end_file = champdir+'Density_3deg_'+cyeare+'_'+$
                           chopr('00'+tostr(doye),3)+'.ascii'
          champfile(0) = champ_start_file
       end
       'grace': begin
          champ_start_file = champdir+'Density_graceA_3deg_'+cyears+'_'+$
                             chopr('00'+tostr(doys),3)+'.ascii'
          champ_end_file = champdir+'Density_graceA_3deg_'+cyeare+'_'+$
                           chopr('00'+tostr(doye),3)+'.ascii'
          champfile(0) = champ_start_file
       end
    endcase
    
    if ndays gt 2 then begin
       case whichsat of 
          'champ': begin
             champ_mid_file = champdir+'Density_3deg_'+cyears+'_'+$
                              chopr('00'+tostr(doys+1),3)+'.ascii'
             champfile(1) = champ_mid_file
          end
          'grace': begin
             champ_mid_file = champdir+'Density_graceA_3deg_'+cyears+'_'+$
                              chopr('00'+tostr(doys+1),3)+'.ascii'
             champfile(1) = champ_mid_file
          end
       endcase

    endif

    champfile(ndays-1) = champ_end_file

    Density = [0.0]
    Lon = [0.0]
    Lat = [0.0]
    Alt = [0.0]
    Time = [0.0D]
    LocTime= [0.0]
    for iday = 0, ndays - 1 do begin
        read_champ, champfile(iday), rho, position,ctime,localtime
        
        Density = [Density,Rho]
        Lat = [Lat,reform(position(1,*))]
        Lon = [Lon,reform(position(0,*))]
        Alt = [Alt,reform(position(2,*))]
        Time = [Time, ctime]
        LocTime = [LocTime,localtime]
        npts = n_elements(rho)
        npoints(ievent) = npoints(ievent) + npts

    endfor

    ChampDensity(ievent,0:npoints(ievent)-1) = Density(1:npoints(ievent))
    ChampPosition(ievent,1,0:npoints(ievent)-1) = Lat(1:npoints(ievent))
    ChampPosition(ievent,0,0:npoints(ievent)-1) = Lon(1:npoints(ievent))
    ChampPosition(ievent,2,0:npoints(ievent)-1) = Alt(1:npoints(ievent))
    ChampTime(ievent,0:npoints(ievent)-1) = Time(1:npoints(ievent))
    ChampLocalTime(ievent,0:npoints(ievent)-1) = LocTime(1:npoints(ievent))

    nptsmax = max(npoints)-1
    ChampDen = reform(ChampDensity(ievent,0:npoints(ievent)-1))/1e-12
    ChampPos = reform(ChampPosition(ievent,*,0:npoints(ievent)-1))
    Time = reform(ChampTime(ievent,0:npoints(ievent)-1))
    ChampLT = reform(ChampLocalTime(ievent,0:npoints(ievent)-1))
    

    c_r_to_a, itime, time(0)
    itime(3:5) = 0
    ndays = round((time(npoints(ievent)-1)-time(0))/3600. /24.)

    c_a_to_r, itime, basetime
    hour = (time/3600.0 mod 24.0) + $
      fix((time-basetime)/(24.0*3600.0))*24.0


    ChampAve = fltarr(npoints(ievent))

    for iTime = 0, npoints(ievent)-1 do begin

        loc = where(abs(time-time(iTime)) lt 45.0*60.0, count)
        if (count gt 0) then begin
            ChampAve(iTime) = mean(ChampDen(loc))
        endif

    endfor

    nOrbits = 0
        
    day   = where(Champlt gt 6.0 and $
                  Champlt lt 18.0,nPtsDay)
    night = where(Champlt lt 6.0 or $
                  Champlt gt 18.0,nPtsNight)

    for i = 1, nPtsDay-1 do begin
        
        if (day(i)-day(i-1) gt 1) then begin
            if (nOrbits eq 0) then begin
                DayOrbitStart = day(i)
                DayOrbitEnd   = day(i-1)

            endif else begin
                if (day(i)-day(i-1) gt 25) then begin
                    DayOrbitStart = [DayOrbitStart,day(i)]
                    DayOrbitEnd   = [DayOrbitEnd  ,day(i-1)]
                endif
            endelse
            if (day(i)-day(i-1) gt 25) then nOrbits = nOrbits+1
        endif

    endfor

;    nY = max(DayOrbitEnd(1:norbits-1) - DayOrbitStart(0:norbits-2))+1
    nY = max(DayOrbitStart - DayOrbitEnd)

    if (nOrbits gt 0) then begin

        xDay = fltarr(nOrbits,nY)
        yDay = fltarr(nOrbits,nY)
        cDay = fltarr(nOrbits,nY)
        
        iOrbit = 0
        iY = 0
        iFound = 0
        for i = 1, nPtsDay-1 do begin
        
            if (day(i)-day(i-1) gt 1) then begin
                if (day(i)-day(i-1) gt 25) then begin
                    iOrbit = iOrbit+1
                    iY = 0
                endif
                iFound = 1
            endif else iY = iY + 1
        
            if (iFound) then begin
                xDay(iOrbit-1, iY) = hour(DayOrbitStart(iOrbit-1))
                yDay(iOrbit-1, iY) = ChampPos(1,Day(i))
                cDay(iOrbit-1, iY) = ChampDen(Day(i))
            endif

        endfor

        for iOrbit = 0, nOrbits-2 do begin
            l = where(xday(iOrbit,*) eq 0,c)
            if (c gt 0) then begin
                for j = 0,c-1 do begin
                    xDay(iOrbit,l(j)) = xDay(iOrbit,l(j)-1)
                    yDay(iOrbit,l(j)) = yDay(iOrbit,l(j)-1)
                    cDay(iOrbit,l(j)) = cDay(iOrbit,l(j)-1)
                endfor
            endif
        endfor

        DayGood = 1

    endif else DayGood = 0

    nNOrbits = 0
    
    for i = 1, nPtsNight-1 do begin

        if (night(i)-night(i-1) gt 1) then begin
            if (nNorbits eq 0) then begin
                NightorbitStart = night(i)
                NightOrbitEnd   = night(i-1)
            endif else begin
                if (night(i)-night(i-1) gt 25) then begin
                    NightOrbitStart = [NightOrbitStart,night(i)]
                    NightOrbitEnd   = [NightOrbitEnd  ,night(i-1)]
                endif
            endelse
            if (night(i)-night(i-1) gt 25) then nNorbits = nNorbits+1
        endif

    endfor

;   nY = max(NightOrbitEnd(1:norbits-1) - NightOrbitStart(0:norbits-2))+1
    ny = max(nightorbitstart-nightorbitend)
    if (nNOrbits gt 0) then begin

        xNight = fltarr(nNorbits,nY)
        yNight = fltarr(nNorbits,nY)
        cNight = fltarr(nNorbits,nY)

        iNorbit = 0
        iY = 0
        iFound = 0
        for i = 1, nPtsNight-1 do begin

            if (night(i)-night(i-1) gt 1) then begin
                if (night(i)-night(i-1) gt 25) then begin
                    iNorbit = iNorbit+1
                    iY = 0
                endif
                iFound = 1
            endif else iY = iY + 1

            if (iFound) then begin
                xNight(iNorbit-1, iY) = hour(NightorbitStart(iNorbit-1))
                yNight(iNorbit-1, iY) = ChampPos(1,Night(i))
                cNight(iNorbit-1, iY) = ChampDen(Night(i))
            endif

        endfor

        for iOrbit = 0, nNOrbits-2 do begin
            l = where(xNight(iOrbit,*) eq 0,c)
            if (c gt 0) then begin
                for j = 0,c-1 do begin
                    xNight(iOrbit,l(j)) = xNight(iOrbit,l(j)-1)
                    yNight(iOrbit,l(j)) = yNight(iOrbit,l(j)-1)
                    cNight(iOrbit,l(j)) = cNight(iOrbit,l(j)-1)
                endfor
            endif
        endfor

        NightGood = 1

    endif else NightGood = 0

sza = fltarr(npoints(ievent))
for itime = 0, npoints(ievent) - 1 do begin

    c_r_to_a, ta,time(itime)
    cdate = tostr(ta(0))+'-'+chopr('0'+tostr(ta(1)),2)+'-'+chopr('0'+tostr(ta(2)),2)
    ut = ta(3)+ta(4)/60. + ta(5)/3600.
    lat = champpos(1,itime)
    lon = champpos(0,itime)

    zsun,cdate,ut,lat,lon,zenith,aziuth,solfac
    sza(itime) = zenith
endfor

loc = where(sza le 30 or sza ge 150,count)
locday = where(sza le 30,countday)
locnight = where(sza ge 150,countnight)

if loc(0) gt -1 then begin
    rhoday = ChampDen(locday)
    rhonight = ChampDen(locnight)
    ntimeday = time(locday)
    ntimenight = time(locnight)

    rho = champden(loc)
    ntime = time(loc)

    rhoAve = fltarr(count)
    rhodayave = fltarr(countday)
    rhonightave = fltarr(countnight)
;   for iTime = 0, count-1 do begin
;
;       loc = where(abs(ntime-ntime(iTime)) lt 45.0*60.0, count)
;       if (count gt 0) then begin
;           rhoAve(iTime) = mean(rho(loc))
;       endif
;
;   endfor
    
    rhodayave = fltarr(countday)
    ntimedayave = dblarr(countday)
    i = 0
    n = 1.0
    rhodayave(0) = rhoday(0)
    for itime = 1, countday-1 do begin
        if ntimeday(itime) - ntimeday(itime-1) lt 500 then begin
            rhodayave(i) = rhodayave(i) + rhoday(itime)
            ntimedayave(i) = ntimedayave(i) + ntimeday(itime)
            n = n + 1.0
        endif else begin
            rhodayave(i) = rhodayave(i)/n
            ntimedayave(i) = ntimedayave(i)/n
            i = i + 1
            n = 1.0
            rhodayave(i) = rhoday(itime)
            ntimedayave(i) = ntimeday(itime)
        endelse
    endfor
    rhodayave(i) = rhodayave(i)/n
    rhodayave = rhodayave(0:i)
    ntimedayave(i) = ntimedayave(i)/n
    ntimedayave = ntimedayave(0:i)

    rhonightave = fltarr(countnight)
    ntimenightave = dblarr(countday)
    i = 0
    n = 1.0
    rhonightave(0) = rhonight(0)
    for itime = 1, countnight-1 do begin
        if ntimenight(itime) - ntimenight(itime-1) lt 500 then begin
            rhonightave(i) = rhonightave(i) + rhonight(itime)
            ntimenightave(i) = ntimenightave(i) + ntimenight(itime)
            n = n + 1.0
        endif else begin
            rhonightave(i) = rhonightave(i)/n
            ntimenightave(i) = ntimenightave(i)/n
            i = i + 1
            n = 1.0
            rhonightave(i) = rhonight(itime)
            ntimenightave(i) = ntimenight(itime)
        endelse
    endfor
    rhonightave(i) = rhonightave(i)/n
    ntimenightave(i) = ntimenightave(i)/n
    rhonightave = rhonightave(0:i)
    ntimenightave = ntimenightave(0:i)

    rhoave = (rhonightave+rhodayave)/2.
    ntime = (ntimenightave+ntimedayave)/2.
;        loc = where(abs(ntimeday-ntimeday(itime)) lt 45.0*60.0,count)
;        if (count gt 0) then begin
;            rhodayave(itime) = mean(rhoday(loc))
;        endif
;    endfor
;    for itime = 0, countnight-1 do begin
;        loc = where(abs(ntimenight-ntimenight(itime)) lt 45.0*60.0,count)
;        if (count gt 0) then begin
;            rhonightave(itime) = mean(rhonight(loc))
;        endif
;    endfor
    

plotcontour = 0
if plotcontour then begin
;----------- Contour plots----------------------------
    psfile = 'flare_'+tostr(timearr(0))+chopr('0'+tostr(timearr(1)),2) + $
      chopr('0'+tostr(timearr(2)),2)+'cont.ps'
    setdevice, psfile, 'p', 5

    makect, 'all'

    nX = n_elements(cDay(*,0))
    nY = n_elements(cDay(0,*))
    ppp = 2
    space = 0.02
    pos_space, ppp, space, sizes, ny = ppp
    
    get_position, ppp, space, sizes, 0, pos, /rect
    pos(0) = pos(0) + 0.05
    pos(2) = pos(2) - 0.05
    
    get_position, ppp, space, sizes, 1, pos2, /rect
    pos2(0) = pos2(0) + 0.05
    pos2(2) = pos2(2) - 0.05
    
;    levels = findgen(61) * 15.0/60.0
    levels = findgen(61) * max(cday)/60.0 
    linelevels = findgen(7) * 15.0/6.0
    stime = min(time)
    etime = max(time)
    time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
    ytickv = [-90,-60,-30,0,30,60,90]

    contour, cday(0:nX-2,0:nY-2), $
      xday(0:nX-2,0:nY-2)*3600.0, yday(0:nX-2,0:nY-2), $
      /fill, pos = pos, yrange = [-90,90], ystyle = 1, $
      xtickname = xtickname, xtitle = xtitle, xtickv = xtickv, $
      xminor = xminor, xticks = xtickn, xstyle = 1, charsize = 1.2, $
      ytickv = ytickv, yticks = 7, yminor = 6, $
      ytitle = 'Latitude (Deg)',   $
      thick = 3, levels = levels

    ctpos = [pos(2)+0.01,pos(1),pos(2)+0.03,pos(3)]
    plotct,254,ctpos,mm(levels),$
      'CHAMP Dayside Mass Density (10!E-12!N kg/m!E3!N)',/right
    

    nX = n_elements(cNight(*,0))
    nY = n_elements(cNight(0,*))
    contour, cnight(0:nX-2,0:nY-2), $
      xnight(0:nX-2,0:nY-2)*3600.0, ynight(0:nX-2,0:nY-2), $
      /fill, pos = pos2, yrange = [-90,90], ystyle = 1, $
      xtickname = xtickname, xtitle = xtitle, xtickv = xtickv, $
      xminor = xminor, xticks = xtickn, xstyle = 1, charsize = 1.2, $
      ytickv = ytickv, yticks = 7, yminor = 6, $
      ytitle = 'Latitude (Deg)',   $
      thick = 3, levels = levels, /follow,/noerase

    ctpos = [pos2(2)+0.01,pos2(1),pos2(2)+0.03,pos2(3)]
    plotct,254,ctpos,mm(levels),$
      'CHAMP Nightside Mass Density (10!E-12!N kg/m!E3!N)',/right

xyouts, pos(2)-.2,pos(3) + .01,'Local time = '+tostrf(mean(champlt(day))),/norm
xyouts, pos(2)-.2,pos2(3) + .01,'Local time = '+tostrf(mean(champlt(night))),/norm
closedevice
endif
;----------------- Line Plots ------------------------------
psfile = 'flare_'+whichsat+tostr(timearr(0))+chopr('0'+tostr(timearr(1)),2) + $
      chopr('0'+tostr(timearr(2)),2)+'line.ps'
setdevice, psfile, 'p', 5

stime = min(ntimeday)
etime = max(ntimeday)
time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
ytickv = [-90,-60,-30,0,30,60,90]

xrange = [0,etime-stime]    
yrange = mm(champden)
loadct,0
plot, ntimeday-stime, rhoday, yrange = yrange, pos = pos, $
  xtickname = strarr(10)+' ', xtickv = xtickv, xrange=xrange,$
  xminor = xminor, xticks = xtickn, xstyle = 1, charsize = 1.2, $
  ytitle = 'Mass Density (10!E-12!N kg/m!E3!N)',   /nodata

oplot,ntimeday-stime,rhoday, thick = 3,psym=sym(1),color = 170,symsize = .5
oplot,ntimenight-stime,rhonight,thick=3,psym=sym(1),symsize = .5
oplot, [rtime-stime,rtime-stime],[-1000,1000],linestyle = 2, color = 170
oplot, [retime-stime,retime-stime],[-1000,1000],linestyle = 2, color = 170

plot, ntime-stime, rhoAve, yrange = yrange, pos = pos2, $
  xtickname = xtickname, xtitle = xtitle, xtickv = xtickv,xrange=xrange, $
  xminor = xminor, xticks = xtickn, xstyle = 1, charsize = 1.2, $
  ytitle = 'Orbit Averaged Mass Density (10!E-12!N kg/m!E3!N)',   $
  thick = 3,/noerase,linestyle=2

oplot, ntimedayave-stime,rhodayave,thick=3,psym=-sym(1),color=170
oplot,ntimenightave-stime,rhonightave,thick = 3,psym=-sym(1)

oplot, [rtime-stime,rtime-stime],[-1000,1000],linestyle = 2, color = 170
oplot, [retime-stime,retime-stime],[-1000,1000],linestyle = 2, color = 170



xyouts, pos(2)-.4,pos(3) + .01,'Local time = '+tostrf(mean(champlt(day)))+' ('+$
  tostrf(mean(champlt(night)))+')' ,/norm


closedevice
;--------------------------------------------------------------------    
endif
ievent = ievent + 1
endif
endwhile
close,1





end



