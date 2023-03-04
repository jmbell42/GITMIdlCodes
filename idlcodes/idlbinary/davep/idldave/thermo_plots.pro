
pro labelvalue, btr, etr, mini, maxi, value, title

  if (strpos(title,'alog') gt -1 and strpos(title,'O/N') lt 0) then begin
      v = 10.0^value
      m = mean(v)
      s = abs(100.0 * stddev(v)/m)
      m = alog10(m)
  endif else begin
      v = value
      m = mean(v)
      s = abs(100.0 * stddev(v)/m)
  endelse

  oplot, [btr,etr], [m,m], linestyle = 2
  
  if (abs(m) lt 10000 and abs(m) gt 0.01) then begin
      ms = strcompress(string(m,format="(f8.2)"),/remove)
  endif else begin
      ms = strcompress(string(m,format="(e10.2)"),/remove)
  endelse

  xyouts, etr+(etr-btr)/25.0, (mini+maxi)/2, ms, $
    orient=270, align=0.5,charsize = 1.2

  xyouts, etr+(etr-btr)/200.0, (mini+maxi)/2, tostr(fix(s))+"%", $
    orient=270,align=0.5,charsize = 1.2

end


GetNewData = 1
fpi = 0

filelist_new = findfile("b0001_*.*ALL")
nfiles_new = n_elements(filelist_new)
if (nfiles_new eq 1) then begin
    filelist_new = findfile("????_*.dat")
    nfiles_new = n_elements(filelist_new)
endif

if n_elements(nfiles) gt 0 then begin
    if (nfiles_new eq nfiles) then default = 'n' else default='y'
    GetNewData = mklower(strmid(ask('whether to reread data',default),0,1))
    if (GetNewData eq 'n') then GetNewData = 0 else GetNewData = 1
endif

if (GetNewData) then begin

    thermo_readsat, filelist_new, data, time, nTimes, Vars, nAlts, nSats, Files
    nFiles = n_elements(filelist_new)

endif

if (nSats eq 1) then begin

    nPts = nTimes

    Alts = reform(data(0,0:nPts-1,2,0:nalts-1))/1000.0
    Lons = reform(data(0,0:nPts-1,0,0)) * 180.0 / !pi
    Lats = reform(data(0,0:nPts-1,1,0)) * 180.0 / !pi

    c_r_to_a, itime, time(0)
    itime(3:5) = 0
    c_a_to_r, itime, basetime
    hour = (time/3600.0 mod 24.0) + fix((time-basetime)/(24.0*3600.0))*24.0
    localtime = (Lons/15.0 + hour) mod 24.0
    
    angle = 23.0 * !dtor * $
      sin((jday(itime(0),itime(1),itime(2)) - jday(itime(0),3,21))*2*!pi/365.0)
    angle = 0
    sza =  acos(sin(angle)*sin(Lats*!dtor) + $
                cos(angle)*cos(Lats*!dtor) * $ 
                cos(!pi*(LocalTime-12.0)/12.0))

    t  = reform(data(0,0:nPts-1,4,0:nalts-1))

    ; o / n2 stuff
    o  = reform(data(0,0:nPts-1,5,0:nalts-1))
    o2 = reform(data(0,0:nPts-1,6,0:nalts-1))
    n2 = reform(data(0,0:nPts-1,7,0:nalts-1))
    n4s = reform(data(0,0:nPts-1,9,0:nalts-1))
    n = o + n2 + o2 + n4s
    k = 1.3807e-23
    mp = 1.6726e-27
    rho = o*mp*16 + o2*mp*32 + n2*mp*14
    data(0,0:nPts-1,3,0:nalts-1) = rho

    p = n*k*t
    oon  = o/n
    n2on = n2/n
    o2on = o2/n
    non = n4s/n

    oInt = fltarr(nPts)
    n2Int = fltarr(nPts)
    on2ratio = o/n2
    AltInt = fltarr(nPts)

    MaxValN2 = 1.0e21

    for i=0,nPts-1 do begin

        iAlt = nalts-1
        Done = 0
        while (Done eq 0) do begin
            dAlt = (Alts(i,iAlt)-Alts(i,iAlt-1))*1000.0
            n2Mid = (n2(i,iAlt) + n2(i,iAlt-1))/2.0
            oMid  = ( o(i,iAlt) +  o(i,iAlt-1))/2.0
            if (n2Int(i) + n2Mid*dAlt lt MaxValN2) then begin
                n2Int(i) = n2Int(i) + n2Mid*dAlt
                oInt(i)  =  oInt(i) +  oMid*dAlt
                iAlt = iAlt - 1
            endif else begin
                dAlt = (MaxValN2 - n2Int(i)) / n2Mid
                n2Int(i) = n2Int(i) + n2Mid*dAlt
                oInt(i)  =  oInt(i) +  oMid*dAlt
                AltInt(i) = Alts(i,iAlt) - dAlt/1000.0
                Done = 1
            endelse
        endwhile

    endfor

    re = 6372000.0
    r = re + Alts*1000.0
    g = 9.8 * (re/r)^2
    mp = 1.6726e-27
    k = 1.3807e-23
    mo = 16.0 * mp
    mo2 = mo*2.0

    t  = reform(data(0,0:nPts-1,4,0:nalts-1))

    o_scale_est  = k*t / (mo*g) / 1000.0
    o2_scale_est = k*t / (mo2*g) / 1000.0

    o_scale = o
    alogo = alog(o(*,1:nalts-1)/o(*,0:nalts-2))
    mini = 0.1
    loc = where(alogo ge -mini,count)
    if (count gt 0) then alogo(loc) = -mini
    o_scale(*,1:nalts-1) = - (Alts(*,1:nalts-1) - Alts(*,0:nalts-2))/$
      alogo
    o_scale(*,0) = o_scale(*,1)

    o2_scale = o2
    o2_scale(*,1:nalts-1) = -(Alts(*,1:nalts-1) - Alts(*,0:nalts-2))/$
      alog(o2(*,1:nalts-1)/o2(*,0:nalts-2))
    o2_scale(*,0) = o2_scale(*,1)

    d = Lats - Lats(0)
;    if (max(abs(d)) lt 1.0) then stationary = 1 else stationary = 0
    stationary = 1

    time2d = dblarr(nPts,nalts)
    for i=0,nPts-1 do time2d(i,*) = time(i)- time(0)

    display, vars
    if (n_elements(iVar) eq 0) then iVar = 3
    nVars = n_elements(Vars)
    print, tostr(nVars),  ".  O/N2"
    print, tostr(nVars+1),".  O/Nt"
    print, tostr(nVars+2),".  O2/Nt"
    print, tostr(nVars+3),".  N2/Nt"
    print, tostr(nVars+4),".  N4S/Nt"
    print, tostr(nVars+5),".  O Scale Height"
    print, tostr(nVars+6),".  O2 Scale Height"
    print, tostr(nVars+7),".  Pressure"
    vars = [vars,'O/N!D2!N', 'O/Nt', 'O!D2!N/Nt', 'N!D2!N/Nt', $
            'N(!U4!DS)/Nt', $
           'O Scale Height','O2 Scale Height', $
           'Pressure']
    iVar = fix(ask('variable to plot',tostr(iVar)))

    if (iVar lt nVars) then value = reform(data(0,0:nPts-1,iVar,0:nalts-1))
    if (iVar eq nVars) then value = on2ratio
    if (iVar eq nVars+1) then value = oon
    if (iVar eq nVars+2) then value = o2on
    if (iVar eq nVars+3) then value = n2on
    if (iVar eq nVars+4) then value = non

    if (iVar eq nVars+5) then value = o_scale
    if (iVar eq nVars+6) then value = o2_scale
    if (iVar eq nVars+7) then value = p

    if (min(value) gt 0) then begin
        if (n_elements(an) eq 0) then an = 'y'
        an = ask('whether you would like variable to be alog10',an)
        if (strpos(mklower(an),'y') eq 0) then begin
            value = alog10(value)
            title = 'alog10('+vars(ivar)+')'
        endif else title = vars(ivar)
    endif else title = vars(ivar)

    if (stationary and iVar ne nVars) then begin

        if (n_elements(alt1) eq 0) then alt1 = 120.0 else alt1 = alt1(0)
        if (n_elements(alt2) eq 0) then alt2 = 350.0 else alt2 = alt2(0)
        alt1 = float(ask('altitude of first cut', string(alt1)))
        alt2 = float(ask('altitude of second cut', string(alt2)))

        d = abs(alt1 - reform(Alts(0,*)))
        loc = where(d eq min(d))
        iAlt1 = loc(0)

        d = abs(alt2 - reform(Alts(0,*)))
        loc = where(d eq min(d))
        iAlt2 = loc(0)

    endif

    setdevice, 'test.ps', 'p', 5, 0.95
    loadct,39
   ; makect, 'all'

    ppp = 8
    space = 0.01
    pos_space, ppp, space, sizes, ny = ppp
    
    get_position, ppp, space, sizes, 4, pos1, /rect
    get_position, ppp, space, sizes, 7, pos2, /rect
    pos = [pos1(0)+0.05,pos2(1), pos1(2)-0.07,pos1(3)]

    mini = min(value)
    maxi = max(value)
    range = (maxi-mini)
    if (range eq 0.0) then range = 1.0
    if (mini lt 0.0 or mini-0.1*range gt 0) then mini = mini - 0.1*range $
    else mini = 0.0
    maxi = maxi + 0.1*range

    mini = float(ask('minimum values for contour',tostrf(mini)))
    maxi = float(ask('maximum values for contour',tostrf(maxi)))
    
    levels = findgen(31) * (maxi-mini) / 30 + mini

    stime = time(0)
    etime = max(time)
    time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
    

    v = reform(value(*,2:nalts-3))
    l = where(v gt maxi,c)
    if (c gt 0) then v(l) = maxi
    l = where(v lt mini,c)
    if (c gt 0) then v(l) = mini
    contour, v, time2d(*,2:nalts-3), Alts(*,2:nalts-3), $
      /follow, /fill, $
      nlevels = 30, pos = pos, levels = levels, $
      yrange = [0,500], ystyle = 1, ytitle = 'Altitude (km)', $
      xtickname = xtickname, xtitle = xtitle, xtickv = xtickv, $
      xminor = xminor, xticks = xtickn, xstyle = 1, charsize = 1.2

    ; Plot a dashed line on the altitudes where the line plots are going
    ; to be made.

  ; if (stationary) then begin
  ;     if (iVar ne nVars) then begin
  ;         oplot, [time2d(0,0),time2d(nPts-1,0)], $
  ;           [Alts(0,iAlt1),Alts(0,iAlt1)], $
  ;           linestyle = 1
  ;         oplot, [time2d(0,0),time2d(nPts-1,0)], $
  ;           [Alts(0,iAlt2),Alts(0,iAlt2)], $
  ;           linestyle = 1
  ;
  ;         if (fpi) then begin
  ;
  ;             blankstart = -1
  ;             blankend   = -1
  ;
  ;             if (sza(0) lt !pi/2) then blankstart = 0
  ;
  ;             for i=1,nPts-1 do begin
  ;                 
  ;                 if (sza(i) gt !pi/2 and sza(i-1) le !pi/2) then begin
  ;                     if blankend(0) gt -1 then blankend = [blankend,i] $
  ;                     else blankend = i
  ;                 endif
  ;                 if (sza(i) lt !pi/2 and sza(i-1) ge !pi/2) then begin
  ;                     if blankstart(0) gt -1 then blankstart=[blankstart,i] $
  ;                     else blankstart = i
  ;                 endif
  ;
  ;             endfor
  ;
  ;         endif
  ;
  ;     endif
  ; endif
title = 'log10 electron density'
    ctpos = pos
    ctpos(0) = pos(2)+0.025
    ctpos(2) = ctpos(0)+0.03
    maxmin = [mini,maxi]
    plotct, 255, ctpos, maxmin, title, /right

; Put the max and min on the plot

;  mini_tmp = min(value)
;  maxi_tmp = max(value)
;
;  r = (maxi_tmp - mini_tmp)/50.0
;
;  if (mini_tmp gt mini) then begin
;      plots, [0.0,1.0], [mini_tmp, mini_tmp], thick = 5
;      plots, [1.0,0.6], [mini_tmp, mini_tmp+r], thick = 2
;      plots, [1.0,0.6], [mini_tmp, mini_tmp-r], thick = 2
;  endif
;  if (maxi_tmp lt maxi) then begin
;      plots, [0.0,1.0], [maxi_tmp, maxi_tmp], thick = 5
;      plots, [1.0,0.6], [maxi_tmp, maxi_tmp+r], thick = 2
;      plots, [1.0,0.6], [maxi_tmp, maxi_tmp-r], thick = 2
;  endif
;
;  if (abs(mini_tmp) lt 10000.0 and abs(mini_tmp) gt 0.01) then begin
;      smin = strcompress(string(mini_tmp, format = '(f10.2)'), /remove)
;  endif else begin
;      smin = strcompress(string(mini_tmp, format = '(e12.3)'), /remove)
;  endelse
;  if (mini_tmp gt mini) then $
;    xyouts, -0.1, mini_tmp, smin, align = 0.5, charsize = 0.8, orient = 90
;
;  if (abs(maxi_tmp) lt 10000.0 and abs(maxi_tmp) gt 0.01) then begin
;      smax = strcompress(string(maxi_tmp, format = '(f10.2)'), /remove)
;  endif else begin
;      smax = strcompress(string(maxi_tmp, format = '(e12.3)'), /remove)
;  endelse
;  if (maxi_tmp lt maxi) then $
;    xyouts, -0.1, maxi_tmp, smax, align = 0.5, charsize = 0.8, orient = 90
;
;
;  get_position, ppp, space, sizes, 3, pos1, /rect
;  pos = [pos1(0)+0.05,pos1(1), pos1(2)-0.07,pos1(3)]
;
;  if (not stationary) then begin
;
;      plot, time-stime, Lons, ytitle = 'Longitude', /noerase, $
;        xtickname = strarr(10)+' ', xtickv = xtickv, $
;        xminor = xminor, xticks = xtickn, xstyle = 1, pos = pos, $
;        yrange = [0.0,360.0], ystyle = 1, thick = 3, charsize = 1.2
;
;      get_position, ppp, space, sizes, 2, pos1, /rect
;      pos = [pos1(0)+0.05,pos1(1), pos1(2)-0.07,pos1(3)]
;
;      plot, time-stime, Lats, ytitle = 'Latitude', /noerase, $
;        xtickname = strarr(10)+' ', xtickv = xtickv, $
;        xminor = xminor, xticks = xtickn, xstyle = 1, pos = pos, $
;        yrange = [-90.0,90.0], ystyle = 1, thick = 3, charsize = 1.2
;
;  endif else begin
;
;      if (iVar ne nVars) then begin
;
;          value2 = value
;          if (iVar eq nVars+5) then value2 = o_scale_est
;          if (iVar eq nVars+6) then value2 = o2_scale_est
;
;          mini = min([value(*, iAlt1),value2(*, iAlt1)])
;          maxi = max([value(*, iAlt1),value2(*, iAlt1)])
;          range = maxi-mini
;          mini = mini - 0.02*range
;          maxi = maxi + 0.02*range
;
;          mini = float(ask('minimum values for alt1',tostrf(mini)))
;          maxi = float(ask('maximum values for alt1',tostrf(maxi)))
;
;          if (fpi) then begin
;              l = where(sza gt !pi/2,c)
;          endif else c = 0
;
;          if (c gt 0) then begin
;
;              t = time-stime
;              v = reform(value(*, iAlt1))
;
;              v(l) = -2.0e32
;
;              plot, t, v, ytitle = title, $
;                /noerase, $
;                xtickname = strarr(10)+' ', xtickv = xtickv, $
;                xrange = [btr,etr], linestyle = 1, $
;                xminor = xminor, xticks = xtickn, xstyle = 1, pos = pos, $
;                thick = 3, yrange = [mini,maxi], ystyle = 1, $
;                charsize = 1.2, min_val = -1.0e32, $
;                ytickname = ['',' ','',' ','',' ','',' ','',' ','',' ']
;
;              l = where(sza le !pi/2,c)
;              if (c gt 0) then begin
;
;                  t = time-stime
;                  v = reform(value(*, iAlt1))
;                  v(l) = -2.0e32
;
;                  plot, t, v, $
;                    /noerase, $
;                    xtickname = strarr(10)+' ', xtickv = xtickv, $
;                    xrange = [btr,etr], $
;                    xminor = xminor, xticks = xtickn, xstyle = 1,  $
;                    pos = pos, $
;                    thick = 3, yrange = [mini,maxi], ystyle = 1, $
;                    charsize = 1.2, min_val = -1.0e32, $
;                    ytickname = strarr(10)+' '
;              endif
;
;          endif else begin
;              plot, time-stime, value(*, iAlt1), ytitle = title, /noerase, $
;                xtickname = strarr(10)+' ', xtickv = xtickv, $
;                xminor = xminor, xticks = xtickn, xstyle = 1, pos = pos, $
;                thick = 3, yrange = [mini,maxi], ystyle = 1, charsize = 1.2, $
;                ytickname = ['',' ','',' ','',' ','',' ','',' ','',' ']
;          endelse
;
;          labelvalue, btr, etr, mini, maxi, value(*,iAlt1), title
;  
;          if (iVar ge nVars+5) then $ 
;            oplot, time-stime, value2(*,ialt1), linestyle = 1
;
;          get_position, ppp, space, sizes, 2, pos1, /rect
;          pos = [pos1(0)+0.05,pos1(1), pos1(2)-0.07,pos1(3)]
;
;          mini = min([value(*, iAlt2),value2(*, iAlt2)])
;          maxi = max([value(*, iAlt2),value2(*, iAlt2)])
;          range = maxi-mini
;          mini = mini - 0.02*range
;          maxi = maxi + 0.02*range
;
;          mini = float(ask('minimum values for alt2',tostrf(mini)))
;          maxi = float(ask('maximum values for alt2',tostrf(maxi)))
;
;          if (fpi) then begin
;              l = where(sza gt !pi/2,c)
;          endif else c = 0
;
;          if (c gt 0) then begin
;
;              t = time-stime
;              v = reform(value(*, iAlt2))
;
;              v(l) = -2.0e32
;
;              plot, t, v, ytitle = title, $
;                /noerase, $
;                xtickname = strarr(10)+' ', xtickv = xtickv, $
;                xrange = [btr,etr], linestyle = 1, $
;                xminor = xminor, xticks = xtickn, xstyle = 1, pos = pos, $
;                thick = 3, yrange = [mini,maxi], ystyle = 1, $
;                charsize = 1.2, min_val = -1.0e32, $
;                ytickname = ['',' ','',' ','',' ','',' ','',' ','',' ']
;
;              l = where(sza le !pi/2,c)
;              if (c gt 0) then begin
;
;                  t = time-stime
;                  v = reform(value(*, iAlt2))
;                  v(l) = -2.0e32
;
;                  plot, t, v, $
;                    /noerase, $
;                    xtickname = strarr(10)+' ', xtickv = xtickv, $
;                    xrange = [btr,etr], $
;                    xminor = xminor, xticks = xtickn, xstyle = 1,  $
;                    pos = pos, $
;                    thick = 3, yrange = [mini,maxi], ystyle = 1, $
;                    charsize = 1.2, min_val = -1.0e32, $
;                    ytickname = strarr(10)+' '
;              endif
;
;          endif else begin
;              plot, time-stime, value(*,iAlt2), ytitle = title, /noerase, $
;                xtickname = strarr(10)+' ', xtickv = xtickv, $
;                xminor = xminor, xticks = xtickn, xstyle = 1, pos = pos, $
;                thick = 3, yrange = [mini,maxi], ystyle = 1, charsize = 1.2, $
;                ytickname = ['',' ','',' ','',' ','',' ','',' ','',' ']
;          endelse
;
;          labelvalue, btr, etr, mini, maxi, value(*,iAlt2), title
;
;          if (iVar ge nVars+5) then $ 
;            oplot, time-stime, value2(*,ialt2), linestyle = 1
;
;      endif else begin
;
;          v = oInt/n2Int
;
;          mini = min(v)
;          maxi = max(v)
;          range = maxi-mini
;          mini = mini - 0.02*range
;          maxi = maxi + 0.02*range
;
;          mini = float(ask('minimum values for o/n2',tostrf(mini)))
;          maxi = float(ask('maximum values for o/n2',tostrf(maxi)))
;
;          plot, time-stime, v, ytitle = 'O/N!D2!N', /noerase, $
;            xtickname = strarr(10)+' ', xtickv = xtickv, $
;            xminor = xminor, xticks = xtickn, xstyle = 1, pos = pos, $
;            thick = 3, yrange = [mini,maxi], ystyle = 1, charsize = 1.2
;
;          labelvalue, btr, etr, mini, maxi, v, 'O/N!D2!N'
;
;          get_position, ppp, space, sizes, 2, pos1, /rect
;          pos = [pos1(0)+0.05,pos1(1), pos1(2)-0.07,pos1(3)]
;
;          v = AltInt
;
;          mini = min(v)
;          maxi = max(v)
;          range = maxi-mini
;          mini = mini - 0.02*range
;          maxi = maxi + 0.02*range
;
;          mini = float(ask('minimum values for altitude',tostrf(mini)))
;          maxi = float(ask('maximum values for altitude',tostrf(maxi)))
;
;          plot, time-stime, v, ytitle = 'Altitude (km)', /noerase, $
;            xtickname = strarr(10)+' ', xtickv = xtickv, $
;            xminor = xminor, xticks = xtickn, xstyle = 1, pos = pos, $
;            thick = 3, yrange = [mini,maxi], ystyle = 1, charsize = 1.2
;  
;          labelvalue, btr, etr, mini, maxi, v, 'Altitude (km)'
;
;      endelse
;
;  endelse
;
;    get_position, ppp, space, sizes, 0, pos1, /rect
;    get_position, ppp, space, sizes, 1, pos2, /rect
;    pos = [pos1(0)+0.05,pos2(1), pos1(2)-0.07,pos1(3)]
;
;    !p.position = pos
;
;    map_set, /noerase
;    map_continents, color = 0
;
;    oplot, lons, lats, psym = 1
;
;    xyouts, lons(0), lats(0), 'Start', charsize = 1.2
;    xyouts, lons(nPts-1), lats(nPts-1), 'End', charsize = 1.2
;
    closedevice

endif else begin

    lons = reform(data(*,*, 0, 0))*180.0/!pi
    lats = reform(data(*,*, 1, 0))*180.0/!pi

    display, vars
    iVar = 3
    iVar = fix(ask('variable to plot',tostr(iVar)))

    iLevel = fix(ask('ilevel to plot','25'))

    alt = data(0,0,2,iLevel)/1000.0

    value_tmp = reform(data(*,*,iVar,iLevel))

    loc = where(lons gt 180,count)
    if count gt 0 then lons(loc) = lons(loc)-360.0

    for i = 0, nPtsSw-1 do begin
        for j = 2, nTimes-1 do begin
            if (abs(lons(i,j)-lons(i,j-1)) gt 10.0 and $
                abs(lons(i,j)+360.0-lons(i,j-1)) gt 10.0) then begin
                lons(i,j) = lons(i,j-1) + (lons(i,j-1)-lons(i,j-2))
                value_tmp(i,j) = value_tmp(i,j-1)
            endif
        endfor
    endfor

    value  = fltarr(nTimes,nPtsSw)
    for i=0,nPtsSw-1 do value(*,i) = value_tmp(i,*)

    time2d = dblarr(nTimes,nPtsSw)
    dummy  = fltarr(nTimes,nPtsSw)
    for i=0,nTimes-1 do time2d(i,*) = time(i)- time(0)
    for i=0,nTimes-1 do dummy(i,*)  = findgen(nPtsSw)

    if (min(value) gt 0) then begin
        an = ask('whether you would like variable to be alog10','y')
        if (strpos(mklower(an),'y') eq 0) then begin
            value_tmp = alog10(value_tmp)
            value = alog10(value)
            title = 'alog10('+vars(ivar)+')'
        endif else title = vars(ivar)
    endif else title = vars(ivar)

    setdevice, 'test.ps', 'p', 5, 0.95

    makect, 'all'

    ppp = 8
    space = 0.01
    pos_space, ppp, space, sizes, ny = ppp
    
    get_position, ppp, space, sizes, 2, pos1, /rect
    get_position, ppp, space, sizes, 3, pos2, /rect
    pos = [pos1(0)+0.05,pos2(1), pos1(2)-0.07,pos1(3)]

    mini = min(value)
    maxi = max(value)
    range = (maxi-mini)
    mini = mini - 0.1*range
    maxi = maxi + 0.1*range
    levels = findgen(31) * (maxi-mini) / 30 + mini

    stime = time(0)
    etime = max(time)
    time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
    xtitle = strmid(xtitle,0,12)

    contour,value(*,2:nalts-3), time2d(*,2:nalts-3), dummy(*,2:nalts-3),$
      /follow, /fill, $
      nlevels = 30, pos = pos, levels = levels, $
      ystyle = 1, ytitle = 'Swath', $
      xtickname = xtickname, xtitle = xtitle, xtickv = xtickv, $
      xminor = xminor, xticks = xtickn, xstyle = 1, charsize = 1.2

    ctpos = pos
    ctpos(0) = pos(2)+0.01
    ctpos(2) = ctpos(0)+0.03
    maxmin = [mini,maxi]
    plotct, 255, ctpos, maxmin, title, /right

; Put the max and min on the plot

    mini_tmp = min(value)
    maxi_tmp = max(value)

    r = (maxi_tmp - mini_tmp)/50.0

    plots, [0.0,1.0], [mini_tmp, mini_tmp], thick = 5
    plots, [1.0,0.6], [mini_tmp, mini_tmp+r], thick = 2
    plots, [1.0,0.6], [mini_tmp, mini_tmp-r], thick = 2

    plots, [0.0,1.0], [maxi_tmp, maxi_tmp], thick = 5
    plots, [1.0,0.6], [maxi_tmp, maxi_tmp+r], thick = 2
    plots, [1.0,0.6], [maxi_tmp, maxi_tmp-r], thick = 2

    get_position, ppp, space, sizes, 0, pos1, /rect
    get_position, ppp, space, sizes, 1, pos2, /rect
    pos = [pos1(0)+0.05,pos2(1), pos1(2)-0.07,pos1(3)]

    !p.position = pos

    map_set, /noerase, title = Vars(iVar)+' at '+tostr(fix(alt))+' km'

    iEnd = 0
    Stop = 0
    while not Stop do begin

        if (max(abs(lons(*,iEnd))) gt 150.0) then begin
            if (max(lons(*,iEnd)) gt 150.0 and $
                min(lons(*,iEnd)) lt 0) then begin
                Stop= 1
                print, "lon stop"
            endif
        endif

        if (max(abs(lats(*,iEnd))) gt 80.0) then begin
            for i = 0, nPtsSw-1 do begin
                if (abs(lats(i,iEnd)) - abs(lats(i,iEnd+1)) lt 0) then begin
                    if (lons(i,iEnd+1) - lons(i,iEnd) gt 20) then begin
                        stop = 1
                        print, "Lat stop", iEnd
                    endif
                endif
            endfor
        endif

        if (not stop) then iEnd = iEnd +1

    endwhile
    iEnd = iEnd-1

;iEnd = nTimes
    contour, value_tmp(1:nPtsSw-2,0:iEnd-1), $
      lons(1:nPtsSw-2,0:iEnd-1), lats(1:nPtsSw-2,0:iEnd-1), $
      /over, /cell_fill, nlevels = 30, levels = levels

    contour, value_tmp(1:nPtsSw-2,iEnd+2:nTimes-1), $
      lons(1:nPtsSw-2,iEnd+2:nTimes-1), $
      lats(1:nPtsSw-2,iEnd+2:nTimes-1), $
      /over, /cell_fill, nlevels = 30, levels = levels

    map_continents, color = 0

    xyouts, lons(0,0), lats(0,0), 'Start', charsize = 1.2
    xyouts, lons(nPtsSw-1,nTimes-1), lats(nPtsSw-1,nTimes-1), 'End', $
      charsize = 1.2

    closedevice

endelse

!p.position = -1

end
