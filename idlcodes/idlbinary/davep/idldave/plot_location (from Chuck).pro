oplotother = 'n'
GetNewData = 1
fpi = 0
;if n_elements(plottype) eq 0 then plottype = 1
;plottype = fix(ask("plot type (1 for 1D, 2 for altitude contour): ",$
;                   tostr(plottype)))

if n_elements(whichlon) eq 0 then whichlon = 0
whichlon = float(ask('which longitude: (0.0 for subsolar)', $ 
                     tostrf(whichlon)))

if n_elements(whichlat) eq 0 then whichlat = 0
whichlat = float(ask('which latitude: (0.0 for subsolar)', $
                     tostrf(whichlat)))


filelist_new = findfile('3DUSR_t010415_1[2345]*.bin')
nfiles_new = n_elements(filelist_new)

if n_elements(nfiles) gt 0 then begin
    if (nfiles_new eq nfiles) then default = 'n' else default = 'y'
    GetNewData = mklower(strmid(ask('whether to reread data',default),0,1))
    if (GetNewData eq 'n') then GetNewData = 0 else GetNewData = 1
endif

if n_elements(latold) eq 0 then begin
    latold = 0.0
    lonold = 0.0
endif

if whichlat ne latold or whichlon ne lonold then begin
    print, 'Coordinates not the same as previous run, recalculating... '
    GetNewData = 1
endif
compare = 1
if compare then begin
   if n_elements(basedir) eq 0 then basedir = ' '
   basedir = ask('base directory: ',basedir)
   
   filelist_new_base = findfile(basedir+'/3DUSR_t010415_1[2345]*.bin')

endif

if (GetNewData) then begin
    nfiles = n_elements(filelist_new)
    sscoords = fltarr(2,nfiles)
    iTimeArray = intarr(6,nFiles)
    
    for iFile = 0, nFiles-1 do begin
        
        filename = filelist_new(iFile)
        filename_base = filelist_new_base(iFile)
        
        print, 'Reading file ',filename
        
        read_thermosphere_file, filename, nvars, nalts, nlats, nlons, $
          vars, data, rb, cb, bl_cnt
        if compare then begin
      read_thermosphere_file, filename_base, nvars_base, nalts_base, nlats_base, nlons_base, $
          vars_base, data_base, rb_base, cb_base, bl_cnt_base
   endif
           
        if iFile eq 0 then begin
            ssdata = fltarr(nvars,nfiles,nalts)
            ssdata_base = fltarr(nvars,nfiles,nalts)
            realtime = fltarr(nfiles)
        endif

            if (strpos(filename,"save") gt 0) then begin
                
                fn = findfile(filename)
                if (strlen(fn(0)) eq 0) then begin
                    print, "Bad filename : ", filename
                    stop
                endif else filename = fn(0)
                
                l1 = strpos(filename,'.save')
                fn2 = strmid(filename,0,l1)
                len = strlen(fn2)
                l2 = l1-1
                while (strpos(strmid(fn2,l2,len),'.') eq -1) do l2 = l2 - 1
                l = l2 - 13
                year = fix(strmid(filename,l, 2))
                mont = fix(strmid(filename,l+2, 2))
                day  = fix(strmid(filename,l+4, 2))
                hour = float(strmid(filename, l+7, 2))
                minu = float(strmid(filename,l+9, 2))
                seco = float(strmid(filename,l+11, 2))
            endif else begin
                year = fix(strmid(filename,07, 2))
                mont = fix(strmid(filename,09, 2))
                day  = fix(strmid(filename,11, 2))
                hour = float(strmid(filename,14, 2))
                minu = float(strmid(filename,16, 2))
                seco = float(strmid(filename,18, 2))
            endelse
            
            itime = [year,mont,day,fix(hour),fix(minu),fix(seco)]
       
        
        iTimeArray(*,iFile) = itime
        if year lt 50 then iyear = year + 2000 else iyear = year + 1900
             stryear = strtrim(string(iyear),2)
        strmth = strtrim(string(mont),2)
        strday = strtrim(string(day),2)
        uttime = hour+minu/60.+seco/60./60.
        
        
        strdate = stryear+'-'+strmth+'-'+strday
        strdate = strdate(0)
        zsun,strdate,uttime ,0,0,zenith,azimuth,solfac,$
          lonsun=lonsun,latsun=latsun
        
        
        if lonsun lt 0.0 then lonsun = 360.0 - abs(lonsun)
                       
        if (whichlon ne 0.0) then lonsun = whichlon
              
        if (whichlat ne 0.0) then latsun = whichlat

        longdeg = data(0,*,0,0) * 180 / (!pi)
        degdiff = 10000.
        degdiffnew = 0.
        

        for i = 0, nlons - 1 do begin
            if (longdeg(i) ge 0.0 and longdeg(i) le 360.0) then begin
                degdiffnew = abs(longdeg(i) - lonsun)
                if (degdiffnew lt degdiff) then begin
                    degdiff = degdiffnew
                    long_i = i
                endif
            endif
        endfor
               
        if longdeg(long_i) lt lonsun then begin
            loniL = long_i
            loniH = long_i + 1
        endif else begin
            loniL = long_i - 1
            loniH = long_i
        endelse
        rlon = 1.0- (lonsun - longdeg(loniL))/(longdeg(loniH)-longdeg(loniL))

        
        latdeg = data(1,0,*,0) * 180 / (!pi)
        degdiffl = 10000.
        degdifflnew = 0.
        for i = 0, nlats - 1 do begin
            if (latdeg(i) ge -90.0 and latdeg(i) le 90.0) then begin
                degdifflnew = abs(latdeg(i) - latsun)
                if (degdifflnew lt degdiffl) then begin
                    degdiffl = degdifflnew
                    lat_i = i

                endif
            endif
        endfor
        
        if latdeg(lat_i) lt latsun then begin
            latiL = lat_i
            latiH = lat_i + 1
        endif else begin
            latiL = lat_i - 1
            latiH = lat_i
        endelse
        rlat = 1.0- (latsun - latdeg(latiL))/(latdeg(latiH)-latdeg(latiL))

        sscoords(0,iFile) = long_i
        sscoords(1,iFile) = lat_i
        
        for i = 0, nAlts - 1 do begin
            for j = 0, nvars - 1 do begin
               ssdata(j,iFile,i) = $
                  (  rLon)*(  rLat)*data(j,loniL, latiL, i) + $
                  (1-rLon)*(  rLat)*data(j,loniH, latiL, i) + $
                  (  rLon)*(1-rLat)*data(j,loniL, latiH, i) + $
                  (1-rLon)*(1-rLat)*data(j,loniH, latiH, i)
               
               if compare then begin
                  ssdata_base(j,iFile,i) = $
                     (  rLon)*(  rLat)*data_base(j,loniL, latiL, i) + $
                     (1-rLon)*(  rLat)*data_base(j,loniH, latiL, i) + $
                     (  rLon)*(1-rLat)*data_base(j,loniL, latiH, i) + $
                     (1-rLon)*(1-rLat)*data_base(j,loniH, latiH, i)
               endif
            endfor
         endfor
        
        
        print, 'Coordinates: ',ssdata(0,iFile,0)*180/!pi,' Long. ', ssdata(1,iFile,0)*180/!pi,' Lat.'
    endfor
nalts = nalts - 2
endif


ssdata = reform(ssdata(*,*,0:nalts-1))
ssdata_base = reform(ssdata_base(*,*,0:nalts-1))
latold = whichlat
lonold = whichlon
if compare then value = (ssdata - ssdata_base)/ssdata_base*100 else value = ssdata

for i=0, nfiles-1 do begin
    c_a_to_r, iTimeArray(*,i),rtime
    realtime(i) = rtime
endfor


stime = realtime(0)
etime = realtime(nfiles-1)
ta = [2001,04,15,13,40,0]
c_a_to_r,ta,stime
ta = [2001,04,15,15,0,0]
c_a_to_r,ta,etime
time_axis,stime, etime, btr, etr, xtickname,xtitle,xtickv,xminor,xtickn

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


pos = [.1,.1,.9,.55]
pos1 = pos
pos2 = pos
pos1(1) = pos(3) + .02
pos1(3) = pos1(1) + .2
pos2(1) = pos(3) + .22
pos2(3) = pos2(1) + .2
;if plottype eq 1 then begin
    if (n_elements(iAlt1) eq 0) then iAlt1 = 5
    if (n_elements(iAlt2) eq 0) then iAlt2 = 25
    
    for i=0,nalts-1 do print, tostr(i)+'. '+string(data(2,0,0,i)/1000)
    iAlt1 = fix(ask('1st altitude to plot',tostr(iAlt1)))
    iAlt2 = fix(ask('2nd altitude to plot',tostr(iAlt2)))
    
    if ivar eq 24 then begin
        yrange1 = [max(abs(value(iVar,*,iAlt1)))*(-1.1),$
                   max(abs(value(iVar,*,iAlt1)))*(1.1)]
        yrange2 = [max(abs(value(iVar,*,iAlt2)))*(-1.1),$
                   max(abs(value(iVar,*,iAlt2)))*(1.1)]
    endif else begin
        yrange1 = [80,150];[.5*min(value(iVar,*,iAlt1)),1.1*max(value(iVar,*,iAlt1))]
        yrange2 = [80,250];[.5*min(value(iVar,*,iAlt2)),1.1*max(value(iVar,*,iAlt2))]
    endelse


    if n_elements(op1d) eq 0 then op1d = 'n'
    op1d = ask('overplot 1d: ',op1d)

    if op1d eq 'y' then begin
        dir = ask('directory for 1d files: ',dir)
        get_1d_gitm,data1d,alts1d,n1dalts,vars1d,time1d,dir
        i1dvar = where(vars1d eq vars(iVar))            
        alt11d = where(alts1d(0,*) eq data(2,0,0,iAlt1)/1000., isalt1)
        alt21d = where(alts1d(0,*) eq data(2,0,0,iAlt2)/1000., isalt2)
        if isalt1 gt 0 and isalt2 gt 0 then begin
            data11d = data1d(0,*,i1dVar,alt11d)
            data21d = data1d(0,*,i1dVar,alt21d)
        endif else begin
            for acount = 0, n1dalts-1 do begin
                if alts1d(0,acount) lt data(2,0,0,iAlt1)/1000. then a1low = acount
                if alts1d(0,acount) lt data(2,0,0,iAlt2)/1000. then a2low = acount
            endfor
            
            ralt1 = 1.0 - (data(2,0,0,iAlt1)/1000.- alts1d(0,a1low))/ $
              (alts1d(0,a1low+1) - alts1d(0,a1low))
            ralt2 = 1.0 - (data(2,0,0,iAlt2)/1000. - alts1d(0,a2low))/ $
              (alts1d(0,a2low+1) - alts1d(0,a2low))
            
            data11d =  ralt1 * data1d(0,*,i1dVar,a1low) + $
              (1-ralt1)*data1d(0,*,i1dVar,a1low+1)
            data21d =  ralt2 * data1d(0,*,i1dVar,a2low) + $
              (1-ralt2)*data1d(0,*,i1dVar,a2low+1)
        endelse
        
    endif
   
    if oplotother  eq 'y' then begin
        if n_elements(otherfile) eq 0 then otherfile = ' '
        otherfile = ask('save file: ',otherfile)
        restore, otherfile
    endif

    if n_elements(ptitle) eq 0 then ptitle = 'plot.ps'
    ptitle = ask('Filename to plot to',ptitle)
    setdevice, ptitle,'p',5,.95
    loadct, 39
    title = 'Time Evolution of '+ strtrim(vars(ivar),2) 
    ntimes = n_elements(realtime)
    plot,realtime-stime,value(iVar,*,iAlt1), /nodata, color = 1, background = 255,$
      xtickname = strarr(10)+' ', xminor = xminor,xtickv = xtickv, $
      xticks = xtickn, xstyle = 1, charsize = 1.2,$
      ytitle = vars(iVar)+' ('+tostr(data(2,0,0,ialt1)/1000)+' km)',$
      yrange = yrange1, pos = pos1,/noerase
    oplot,realtime-stime, value(iVar,*,iAlt1), linestyle=2,color = 254,$
      thick=3
    if oplotother eq 'y' then begin 
        oplot,ort-ost, othervalue(iVar,*,iAlt1),linestyle=1,color = 254,$
          thick=3 
    endif
    oplot,realtime-stime, fltarr(ntimes)
    if op1d eq 'y' then oplot,time1d-stime,data11d,color=254,$
      thick=3

    plot,realtime-stime,value(iVar,*,iAlt2), /nodata, color = 1, background = 255,$
      xtickname = strarr(10)+ ' ', xticks = xtickn, xminor = xminor,$
      xstyle = 1, charsize = 1.2, $
      ytitle = vars(iVar)+' ('+tostr(data(2,0,0,ialt2)/1000)+' km)',$
      xtickv=xtickv,$
      yrange = yrange2, pos = pos2,/noerase
   
     oplot,realtime-stime, value(iVar,*,iAlt2), linestyle=2,color = 254,$
      thick=3
    oplot,realtime-stime, fltarr(ntimes)
    if oplotother eq 'y' then begin 
        oplot,ort-ost, othervalue(iVar,*,iAlt2),linestyle=1,color = 254,$
          thick=3 
    endif
    if op1d eq 'y' then oplot,time1d-stime, data21d,color=254,$
      thick=3
    if op1d eq 'y' then begin
        legend, ['3D GITM','1D GITM'],linestyle = [2,0],color=[254,254]
    endif

;print max and min on graph
   ;maxstr = 'maximum: '+strtrim(string(max(value(iVar,*,iAlt))),2)
   ;minstr = 'minimum: '+strtrim(string(min(value(iVar,*,iAlt))),2)
   ;xyouts,0.83,.5,maxstr,charsize = 1.,/normal
   ;xyouts,.83,.47,minstr,/normal,charsize=1.
 
 if oplotother eq 'y' then begin
        v = (reform(value(ivar,*,*)) - reform(othervalue(ivar,*,*))) $
          /(reform(value(ivar,*,*)))
    endif else begin
        v = reform(value(ivar,*,*))
    endelse
    newtime = fltarr(n_elements(ssdata(0,*,0)),n_elements(ssdata(0,0,*)))
    newalts = fltarr(n_elements(ssdata(0,*,0)),n_elements(ssdata(0,0,*)))
    for i = 0, n_elements(ssdata(0,0,*))-1 do begin
        for j = 0, n_elements(ssdata(0,*,0))-1 do begin
            newtime(j,i) = realtime(j)
            newalts(j,i) = ssdata(2,j,i)/1000.
            if v(j,i) ne v(j,i) then v(j,i) = 0

         endfor
        
    endfor

   

    if n_elements(log) eq 0 then log = 'n'
    log = ask('plot alog10: (y/n)', log)
    if log eq 'y' then v = alog10(v)
    
;    setdevice,'contour.ps','l',5,.95
    maxi = max(v)
    mini = -10;min(v)
    if oplotother eq 'y' then begin
        val = max([abs(mini),abs(maxi)])
        maxmin = [-val,val]
        maxi = val
        mini = -val
    endif else begin
        maxmin = [mini,maxi]
    endelse
    nl = 40
   if ivar ne 24 then levels = findgen(31) * (maxi-mini) / 30 + mini else $
    levels = 250.0*findgen(nl+1)/nl-125.0


    makect, 'mid'

     contour,v,newtime-stime,newalts,$
      /follow, /fill, /noerase,$
      nlevels = 30, pos = pos, levels = levels, $
      yrange = yrange1, ystyle = 1, ytitle = 'Altitude (km)', $
      xtickname = xtickname, xtitle = xtitle,xticks = xtickn,xtickv = xtickv, $
      xminor = xminor, xstyle = 1, charsize = 1.2,xrange = [btr,etr]
     
    ctpos = pos
    ctpos(0) = pos(2)+0.025
    ctpos(2) = ctpos(0)+0.03
    
    
    if oplotother eq 'y' then cttitle = 'Percent Difference' else $
      cttitle = '[e-] (Percent Difference)' ;vars(ivar)
    plotct, 255, ctpos, maxmin, cttitle, /right
    closedevice
    


    othervalue = value
    ost = stime
    ort = realtime
;    if oplotother ne 'y' then begin;
;        save, otherssdata,ost,ort, filename = 'other.sav'
;    endif
loadct,39
setdevice,'prof.ps','p',5,.95
iv = [3,9]
nlines = n_elements(iv)
colors=get_colors(nlines)
pos = [.05,.05,.55,.6]
maxv = max(value(iv(0):iv(nlines-1),*,*))
minv = min(value(iv(0):iv(nlines-1),*,*))
plot,v(9,*),newalts(9,*),pos=pos,xtitle='Cooling rate (Percent Difference)',ytitle='Altitude (km)',$
     color = 0,thick=3,charsize=1.3,yrange=[80,140],xrange=[0,500],/nodata

for i = 0, nlines - 1 do begin

     v = reform(value(iv(i),*,*))
     if iv(i) eq 9 then v = -1 * v
;oplot,v(7,*),newalts(0,*),color=colors(0),thick=3
oplot,v(8,*),newalts(0,*),color=colors(i),thick=3
;oplot,v(9,*),newalts(0,*),color=colors(1),thick=3
;oplot,v(10,*),newalts(0,*),color=colors(2),thick=3
;oplot,[0,0],[0,1000],thick=1,linestyle = 2
endfor

strtime=['NLTE Rad Cooling','Conduction'];vars(iv);strarr(nlines)
;strtime(0) = '2001-04-15: 14:00'
;strtime(1) = '2001-04-15: 14:15'
;strtime(2) = '2001-04-15: 14:30'
p = pos(3)-.06
xbeg = pos(0)+.1


usersym,[0,0,2,2,0],[0,2,2,0,0],/fill
legend,strtime, position=[xbeg,p],/norm,color=colors,pspacing=5,box=0,linestyle=0,thick=3
       
;legend,label,position=[xbeg,p-.02],/norm,/horizontal,box=0
;xyouts, xbeg-.07,p-.0385,'',/norm

closedevice
end
