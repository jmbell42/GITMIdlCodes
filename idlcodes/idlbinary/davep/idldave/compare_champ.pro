if n_elements(date1new) eq 0 then date1new = ''
;if n_elements(date2) eq 0 then date2 = ''
date1new = ask('perturbation date (yyyy-mm-dd): ',date1new)
;date2 = ask('base date (yyyy-mm-dd): ',date2)
if n_elements(ndays) eq 0 then ndays = 1
ndays = fix(ask('number of days: ',tostr(ndays)))

date1 = date1new
iyear1 = fix(strmid(date1,0,4))
imonth1 = fix(strmid(date1,5,2))
iday1n = fix(strmid(date1,8,2))

;iyear2 = fix(strmid(date2,0,4))
;imonth2 = fix(strmid(date2,5,2))
;iday2 = fix(strmid(date2,8,2))

reread = 1

if n_elements(iday1) eq 0 then iday1 = 0
if iday1n ne iday1 then begin
    reread = 1  
endif else begin
    if (n_elements(MassDensity) gt 0) then begin
        answer = ask('whether to re-read data','n')
        if (strpos(mklower(answer),'n') gt -1) then reread = 0
    endif
endelse

iday1 = iday1n
if (reread) then begin

    nChampMax = 50000L
    MassDensity = fltarr(nChampMax)
    cWind = fltarr(nChampMax)
    ChampPosition1 = fltarr(3,nChampMax)
    ChampTime1  = dblarr(nChampMax)
    ChampLocalTime1 = fltarr(nChampMax)
    zen1 = fltarr(nChampmax)
    ChampPosition2 = fltarr(3,nChampMax)
    ChampTime2  = dblarr(nChampMax)
    ChampLocalTime2 = fltarr(nChampMax)
    zen2 = fltarr(nChampmax)
    t = ' '
    line = 0L
   
    for iCD = 0, ndays - 1 do begin
        ntimes1 = 0
        year1 = strmid(date1,0,4)
        month1 = strmid(date1,5,2)
        day1 = tostr(strmid(date1,8,2) + iCD)
        daysinm = d_in_m(fix(year1),fix(month1))
        if day1 gt daysinm then begin
            day1 = '00'
            month1 = tostr(month1+1)
        endif
        
        champdir = '~/UpperAtmosphere/CHAMP/data/'+year1+'/'
        sdate = year1+'-'+month1+'-'+day1
        print, 'Working on '+sdate+ '...'
        realdate1 = date_conv(sdate,'r')
        
                                ;   champdir = '~/CHAMP/data/'+tostr(iyear2)+'/'
                                ;   realdate2 = date_conv(date2,'r')
        
        
        doy1 = strmid(tostr(realdate1),4,3)
;    doy2 = strmid(tostr(realdate2),4,3)
        if doy1 lt 100 then doy1 = '00'+tostr(fix(doy1))
        doy1 = chopr(doy1,3)
        yr = strmid(tostr(iyear1),2,2)
        champ_file_a = champdir+'Density_3deg_'+yr+'_'+doy1+'.ascii'
        champ_file_w = champdir+'Wind_3deg_'+yr+'_'+doy1+'.ascii'
        
        close,/all
        openr,1,champ_file_a
;    openr,2,champ_file_w
        readf,1,t
        readf,1,t
;    readf,2,t
        
        while (not eof(1)) do begin
            readf,1,t
            tarr = strsplit(t,/extract)
            year = fix(tarr(0))
            day = fix(tarr(1))
            seconds = float(tarr(2))
            lat =float(tarr(4))
            long = float(tarr(5))
            height = float(tarr(6))
            chlocaltime = float(tarr(7))
            density = float(tarr(8))
            density400 = float(tarr(9))
            density410 =float(tarr(10))

;        readf,2,t
;        tarr = strsplit(t,/extract)
;        wind = float(tarr(7)) 
            
            year = 2000. + year
            rdate = year*1000+day
            
            sdate = date_conv(rdate,'s')
            iDay = fix(strmid(sdate,0,2))
            itime = [iYear1, iMonth1, iDay1, 0,0,0]
            c_a_to_r, iTime, BaseTime

            ChampTime1(line) = seconds+ basetime + 3600. * 24. * iCD
            ChampPosition1(0,line) = long
            ChampPosition1(1,line) = lat
            ChampPosition1(2,line) = height
            ChampLocalTime1(line) = chlocaltime
            MassDensity(line) = density
                                ;       cWind(line) = wind
            
            line = line + 1
            
            
        endwhile
        
        close,1,2
    endfor
    
    ntimes1 = line - 1
    
    ChampDensity1    = fltarr(nTimes1)
    ChampAltitude1   = fltarr(nTimes1)
;    ChampWind1       = fltarr(nTimes1)
;    Zenith1          = zen1(0:nTimes1-1)
    
    ChampTime1 = ChampTime1(0:ntimes1-1)
    ChampDensity1  = MassDensity(0:ntimes1-1)/1.e-12
    ChampAltitude1 = ChampPosition1(2,0:ntimes1-1)
    ChampLocalTime1 = ChampLocalTime1(0:ntimes1-1)
;    ChampWind1 = cWind(0:ntimes1-1)
    hour1 = (ChampTime1/3600.0 mod 24.0) + fix((ChampTime1-basetime)/(24.0*3600.0))*24.0
;;;;; File 2 ;;;;;;;;;;;;;
;      line = 0L
;      ntimes2 = 0
;    yr = strmid(tostr(iyear2),2,2)
;    champ_file_a = champdir+'Density_3deg_'+yr+'_'+tostr(doy2)+'.ascii'
;    champ_file_w = champdir+'Wind_3deg_'+yr+'_'+tostr(doy2)+'.ascii'
;    
;    close,/all
;    openr,1,champ_file_a
;;    openr,2,champ_file_w
;    readf,1,t
;    readf,1,t
;    
;    while (not eof(1)) do begin
;        readf,1,t
;        tarr = strsplit(t,/extract)
;        year = fix(tarr(0))
;        day = fix(tarr(1))
;        seconds = float(tarr(2))
;        lat =float(tarr(4))
;        long = float(tarr(5))
;        height = float(tarr(6))
;        chlocaltime = float(tarr(7))
;        density = float(tarr(8))
;        density400 = float(tarr(9))
;        density410 =float(tarr(10))
;        
;  ;      readf,2,t
;  ;      tarr = strsplit(t,/extract)
;  ;      wind = float(tarr(7)) 
;        
;        year = 2000. + year
;        rdate = year*1000+day
;        
;        sdate = date_conv(rdate,'s')
;        iDay = fix(strmid(sdate,0,2))
;        itime = [iYear2, iMonth2, iDay2, 0,0,0]
;        c_a_to_r, iTime, BaseTime
;        
;        ChampTime2(line) = seconds+ basetime
;        ChampPosition2(0,line) = long
;        ChampPosition2(1,line) = lat
;        ChampPosition2(2,line) = height
;        ChampLocalTime2(line) = chlocaltime
;        MassDensity(line) = density
;  ;      cWind(line) = wind
;        zsun,rdate,ChampTime2(line)/3600.,lat,long,zenith,azimuth,solfac
;        Zen2(line) = zenith
;        
;        line = line + 1
;    endwhile
;    
;    close,1,2
;    ntimes2 = ntimes2 + line - 1
;
;    ChampTime2 = ChampTime2(0:ntimes2-1)
;    ChampDensity2    = fltarr(nTimes2)
;    ChampAltitude2   = fltarr(nTimes2)
;  ;  ChampWind2       = fltarr(nTimes2)
;    Zenith2          = zen2(0:nTimes2-1)
;
;ChampDensity2  = MassDensity(0:ntimes2-1)/1.e-12
;ChampAltitude2 = ChampPosition2(2,0:ntimes2-1)
;;ChampWind2 = cWind(0:ntimes2-1)
;ChampLocalTime2 = ChampLocalTime2(0:ntimes2-1)
;hour2 = (ChampTime2/3600.0 mod 24.0) + fix((ChampTime2-basetime)/(24.0*3600.0))*24.0

;;;;;;;;; file 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nOrbits = 0

day   = where(champlocaltime1 gt 6.0 and champlocaltime1 lt 18.0,nPtsDay)
night = where(champlocaltime1 lt 6.0 or  champlocaltime1 gt 18.0,nPtsNight)

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

nY = max(DayOrbitStart - DayOrbitEnd)

xDay1 = fltarr(nOrbits,nY)
yDay1 = fltarr(nOrbits,nY)
cDay1 = fltarr(nOrbits,nY)

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
        xDay1(iOrbit-1, iY) = hour1(DayOrbitStart(iOrbit-1))
        yDay1(iOrbit-1, iY) = ChampPosition1(1,Day(i))
        cDay1(iOrbit-1, iY) = ChampDensity1(Day(i))

    endif
    
endfor

for iOrbit = 0, nOrbits-2 do begin
    l = where(xday1(iOrbit,*) eq 0,c)
    if (c gt 0) then begin
        for j = 0,c-1 do begin
            xDay1(iOrbit,l(j)) = xDay1(iOrbit,l(j)-1)
            yDay1(iOrbit,l(j)) = yDay1(iOrbit,l(j)-1)
            cDay1(iOrbit,l(j)) = cDay1(iOrbit,l(j)-1)
        endfor
    endif
endfor

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

nY = max(NightOrbitStart - NightOrbitEnd)
;nY = max(abs(nightorbitstart(1:nnorbits-2)-nightorbitend(2:nnorbits-1)))+1
xNight1 = fltarr(nNorbits,nY)
yNight1 = fltarr(nNorbits,nY)
cNight1 = fltarr(nNorbits,nY)

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

        xNight1(iNorbit-1, iY) = hour1(NightorbitStart(iNorbit-1))
        yNight1(iNorbit-1, iY) = ChampPosition1(1,Night(i))
        cNight1(iNorbit-1, iY) = ChampDensity1(Night(i))

    endif

endfor

for iOrbit = 0, nOrbits-2 do begin
    l = where(xNight1(iOrbit,*) eq 0,c)
    if (c gt 0) then begin
        for j = 0,c-1 do begin
            xNight1(iOrbit,l(j)) = xNight1(iOrbit,l(j)-1)
            yNight1(iOrbit,l(j)) = yNight1(iOrbit,l(j)-1)
            cNight1(iOrbit,l(j)) = cNight1(iOrbit,l(j)-1)
        endfor
    endif
endfor

;;;;;;;;; file 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;nOrbits = 0
;
;day   = where(zenith2 lt 90.0 ,nPtsDay)
;night = where(zenith2 ge 90.0 ,nPtsNight)
;
;for i = 1, nPtsDay-1 do begin
;    
;    if (day(i)-day(i-1) gt 1) then begin
;        if (nOrbits eq 0) then begin
;            DayOrbitStart = day(i)
;            DayOrbitEnd   = day(i-1)
;        endif else begin
;            if (day(i)-day(i-1) gt 25) then begin
;                DayOrbitStart = [DayOrbitStart,day(i)]
;                DayOrbitEnd   = [DayOrbitEnd  ,day(i-1)]
;            endif
;        endelse
;        if (day(i)-day(i-1) gt 25) then nOrbits = nOrbits+1
;    endif
;    
;endfor
;
;;nY = max(DayOrbitStart - DayOrbitEnd)
;nY = max(abs(dayorbitstart(1:norbits-2)-dayorbitend(2:norbits-1)))+1
;xDay2 = fltarr(nOrbits,nY)
;yDay2 = fltarr(nOrbits,nY)
;cDay2 = fltarr(nOrbits,nY)
;
;iOrbit = 0
;iY = 0
;iFound = 0
;for i = 1, nPtsDay-1 do begin
;    
;    if (day(i)-day(i-1) gt 1) then begin
;        if (day(i)-day(i-1) gt 25) then begin
;            iOrbit = iOrbit+1
;            iY = 0
;        endif
;        iFound = 1
;    endif else iY = iY + 1
;
;    if (iFound) then begin
;        xDay2(iOrbit-1, iY) = hour2(DayOrbitStart(iOrbit-1))
;        yDay2(iOrbit-1, iY) = ChampPosition2(1,Day(i))
;        cDay2(iOrbit-1, iY) = ChampDensity2(Day(i))
;    endif
;    
;endfor
;
;for iOrbit = 0, nOrbits-2 do begin
;    l = where(xday2(iOrbit,*) eq 0,c)
;    if (c gt 0) then begin
;        for j = 0,c-1 do begin
;            xDay2(iOrbit,l(j)) = xDay2(iOrbit,l(j)-1)
;            yDay2(iOrbit,l(j)) = yDay2(iOrbit,l(j)-1)
;            cDay2(iOrbit,l(j)) = cDay2(iOrbit,l(j)-1)
;        endfor
;    endif
;endfor
;
;nNOrbits = 0
;
;for i = 1, nPtsNight-1 do begin
;    
;    if (night(i)-night(i-1) gt 1) then begin
;        if (nNorbits eq 0) then begin
;            NightorbitStart = night(i)
;            NightOrbitEnd   = night(i-1)
;        endif else begin
;            if (night(i)-night(i-1) gt 25) then begin
;                NightOrbitStart = [NightOrbitStart,night(i)]
;                NightOrbitEnd   = [NightOrbitEnd  ,night(i-1)]
;            endif
;        endelse
;        if (night(i)-night(i-1) gt 25) then nNorbits = nNorbits+1
;    endif
;    
;endfor
;
;nY = max(NightOrbitStart - NightOrbitEnd)
;
;xNight2 = fltarr(nNorbits,nY)
;yNight2 = fltarr(nNorbits,nY)
;cNight2 = fltarr(nNorbits,nY)
;
;iNorbit = 0
;iY = 0
;iFound = 0
;for i = 1, nPtsNight-1 do begin
;    
;    if (night(i)-night(i-1) gt 1) then begin
;        if (night(i)-night(i-1) gt 25) then begin
;            iNorbit = iNorbit+1
;            iY = 0
;        endif
;        iFound = 1
;    endif else iY = iY + 1
;    
;    if (iFound) then begin
;        xNight2(iNorbit-1, iY) = hour2(NightorbitStart(iNorbit-1))
;        yNight2(iNorbit-1, iY) = ChampPosition2(1,Night(i))
;        cNight2(iNorbit-1, iY) = ChampDensity2(Night(i))
;    endif
;    
;endfor
;
;for iOrbit = 0, nOrbits-2 do begin
;    l = where(xNight2(iOrbit,*) eq 0,c)
;    if (c gt 0) then begin
;        for j = 0,c-1 do begin
;            xNight2(iOrbit,l(j)) = xNight2(iOrbit,l(j)-1)
;            yNight2(iOrbit,l(j)) = yNight2(iOrbit,l(j)-1)
;            cNight2(iOrbit,l(j)) = cNight2(iOrbit,l(j)-1)
;        endfor
;    endif
;endfor
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endif
   nflares = 2
 rft = dblarr(nflares)
ftime = [2003,11,02,17,15,0]
;ftime = [2005,9,7,17,25,0]
c_a_to_r,ftime,rt
rft(0) = rt
ftime = [2003,11,4,19,40,0]
;ftime = [2005,9,9,19,35,0]
c_a_to_r,ftime,rt
rft(1)=rt

xrange = mm(champtime1)
xrange = xrange - xrange(0)
xrange = mm(xday1)*3600.
xrange(0) = xrange(0) + 24.*3600
xrange(1) = xrange(1) - 24.*3600
xrange = [0,48.*3600]
yrange = [0.0,40.0]

ppp = 2
space = 0.1
pos_space, ppp, space, sizes, ny = ppp
    
get_position, ppp, space, sizes, 0, pos, /rect
pos(0) = pos(0) + 0.05
pos(2) = pos(2) - 0.05

get_position, ppp, space, sizes, 1, pos2, /rect
pos2(0) = pos2(0) + 0.05
pos2(2) = pos2(2) - 0.05

stime = min(champtime1)
etime = max(champtime1)

;satime = [2001,12,12,0,0,0]
;eatime = [2001,12,14,0,0,0]
;c_a_to_r,satime,stime
;c_a_to_r,eatime,etime

time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
;xtickname = ['00','06','12','18','00']
;xtickn = 4
;xminor = 4
;xtickv = [86400.,108000.,129600.,151200.,172800]
;xtitle = 'Jul 15, 2004 Universal Time'

if iday1 lt 10 then sday = '0'+tostr(iday1) else sday = tostr(iday1)
if imonth1 lt 10 then smonth = '0'+tostr(imonth1) else smonth = tostr(imonth1)
run = strmid(tostr(iyear1),2,2)+smonth+sday
psfile_2dd = 'compare_'+run+'_Champ.ps'



;; Plots ;;
;nX = min([max(n_elements(CDay1(*,0))),max(n_elements(CDay2(*,0)))])
;nY = min([max(n_elements(cDay1(0,*))),max(n_elements(CDay2(0,*)))])
nX = n_elements(Cday1(*,0))
nY = n_elements(cday1(0,*))
;champdiff = (cday1(0:nX-2,0:nY-2)-cday2(0:nX-2,0:nY-2))/cday1(0:nX-2,0:nY-2)
setdevice, psfile_2dd, 'p', 5

makect, 'all'

levels = findgen(61) * (max(cday1)-min(cday1))/60.0 + min(cday1)
levels = findgen(61) * (12.5)/60.0 
;levels = findgen(61) * 9.0/60.0
linelevels = findgen(7) * 10.0/6.0

ytickv = [-90,-60,-30,0,30,60,90]

contour, cday1(0:nx-2,0:ny-2), $
  xday1(0:nX-2,0:nY-2)*3600.0, yday1(0:nX-2,0:nY-2), $
  /fill, pos = pos, yrange = [-90,90], ystyle = 1, $
  xtickname = xtickname, xtitle = xtitle, xtickv = xtickv, $
  xminor = xminor, xticks = xtickn, xstyle = 1, charsize = 1.2, $
  ytickv = ytickv, yticks = 7, yminor = 6, $
  ytitle = 'Latitude (Deg)',   $
  thick = 3, levels = levels,xrange = xrange
 for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-90,90],linestyle = 2
endfor

ctpos = [pos(2)+0.01,pos(1),pos(2)+0.03,pos(3)]
plotct,254,ctpos,mm(levels),$
  'CHAMP Dayside Mass Density (10!E-12!N kg/m!E3!N)',/right
;nX = n_elements(Cnight1(*,0))
;nY = n_elements(cnight1(0,*))
levels = findgen(61) * 1.2*(max(cnight1))/60.0

;stime = min(champtime1)
;etime = max(champtime1)
;time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
contour, cnight1(0:nX-2,0:nY-2), $
  xnight1(0:nX-2,0:nY-2)*3600.0, ynight1(0:nX-2,0:nY-2), $
  /fill, pos = pos2, yrange = [-90,90], ystyle = 1,  $
  xtickname = xtickname, xtitle = xtitle, xtickv = xtickv, $
  xminor = xminor, xticks = xtickn, xstyle = 1, charsize = 1.2, $
  ytickv = ytickv, yticks = 7, yminor = 6, $
  ytitle = 'Latitude (Deg)',   $
  thick = 3, levels = levels,/noerase,xrange = xrange
 for ifl = 0, nflares -1 do begin
    oplot, [rft(ifl)-1,rft(ifl)+1]-stime,[-90,90],linestyle = 2
endfor

ctpos = [pos2(2)+0.01,pos2(1),pos2(2)+0.03,pos2(3)]
plotct,254,ctpos,mm(levels),$
  'CHAMP Nightside Mass Density (10!E-12!N kg/m!E3!N)',/right

xyouts, pos(2)-.2,pos(3) + .01,'Local time = '+tostrf(mean(champlocaltime1(day))),/norm
xyouts, pos(2)-.2,pos2(3) + .01,'Local time = '+tostrf(mean(champlocaltime1(night))),/norm
closedevice
;;;;;;;;;;;; data ;;;;

;maxden1 = max(cday1,imax)
;md = max(champdensity1,im)
;print, 'max at position 1 (lon,lat,alt): ',champposition1(*,im)
;c_r_to_a,ta,champtime1(im)
;print, 'at: ', ta, ' and LT: ',champlocaltime1(im)
;orb1 = xday1(imax)
;orb2 = min(abs(xday2(*,0) - orb1),iorb2)
;iorb2 = iorb2 + 1
;lat1 = yday1(imax)
;lat2 = min(abs(yday2(iorb2,*) - lat1),ilat2)
;
;maxden2 = cday2(iorb2,ilat2)
;im2 = where(champdensity2 eq maxden2)
;print, 'max at position 2 (lon,lat,alt): ',champposition2(*,im2)
;
;maxdiff = (maxden1-maxden2)/maxden1*100
;
;print, 'Difference at closest previous time and position: ',maxdiff, ' percent'
;c_r_to_a,ta2,champtime2(im2)
;print, 'at: ',ta2,  ' and LT: ',champlocaltime2(im2)
;
;
;
;c_r_to_a, tmax,champtime1(imax)
;maxpos = ChampPosition1(*,imax)

end

