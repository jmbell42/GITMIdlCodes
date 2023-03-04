GetNewData = 1
plotall = 1
plotenergy = 1

files = file_search('3D*')

for ifile = 0, n_elements(files) - 1 do print, tostr(ifile)+'   '+files(ifile)
ifile = 0
if n_elements(filenum) eq 0 then filenum = 0
filenum = fix(ask('which file: ',tostr(filenum)))

l = 24
l2 = strlen(files(filenum))
filenamenew = strmid(files(filenum),l2 - l)
l1 = 17
year = strmid(files(filenum),l2 - l1,2)
month =strmid(files(filenum),l2 - l1 + 2,2)
day = strmid(files(filenum),l2 - l1 + 4,2)
hour =strmid(files(filenum),l2 - l1+7,2)
min = strmid(files(filenum),l2 - l1+9,2)
sec = strmid(files(filenum),l2 - l1+11,2)

if n_elements(filename) eq 0 then filename = ' '
if filenamenew eq filename then begin
    GetNewData = 0
    GetNewData = fix(ask('whether to get new data: ',tostr(GetNewData)))
endif
filename = filenamenew

if GetNewData eq 1 then begin
    fn = filename
    print, 'Reading file ',fn
    
    read_thermosphere_file, fn, nvarst, nalts, nlats, nlons, $
      vars, data, rb, cb, bl_cnt
    
    alts = reform(data(2,0,0,*))/1000.
    lons = reform(data(0,*,0,0))/!dtor
    lats = reform(data(1,0,*,0))/!dtor

endif

for ivar = 0, nvarst - 1 do print, tostr(ivar)+'  '+vars(ivar)

if n_elements(whichvar) eq 0 then whichvar = -1
whichvar = fix(ask('which variable to plot (-1 for all):  ',tostr(whichvar)))
if whichvar eq -1 then nvars = nvarst -3 else nvars = 1
enervars = [3,5,10]
glbavg = fltarr(nvars,nalts-4)
zonalavg = fltarr(nvars,nlats-4,nlats-4)
re = 6378.
for ivar = 0, nvars - 1 do begin

if nvars gt 1 then wv = 3+ivar else wv = whichvar

for ialt = 2, nalts - 3 do begin
    celltot = 0
    for ilon = 1, nlons - 3 do begin
        for ilat = 1, nlats - 3 do begin

            latavg = (lats(ilat)+lats(ilat+1))/2.
            cellvol = ((re+alts(ialt))^2*abs(sin(latavg*!dtor))*(alts(ialt+1)-alts(ialt)) * $
                       (lats(ilat+1)-lats(ilat))*!dtor * (lons(ilon+1)-lons(ilon))*!dtor)
            glbavg(ivar,ialt-2) = glbavg(ivar,ialt-2) + $
              (data(wv,ilon,ilat,ialt) * cellvol)
            celltot = celltot+cellvol
        endfor
    endfor

;    for ilat = 2, nlats - 3 do begin
;       zonalavg(ivar,ialt-2,ilat-2) = mean(data(wv,2:nlons-3,ilat,ialt))
;    endfor

    totvol = 4/3.*!pi*((re+alts(ialt+1))^3 - (re+alts(ialt))^3)
    glbavg(ivar,ialt-2) = glbavg(ivar,ialt-2)/celltot

endfor
endfor
fl = fn(0)
l1 = strpos(fl,'.bin')
l = l1 - 13
year = fix(strmid(fl,l, 2))
mont = strmid(fl,l+2, 2)
day  = strmid(fl,l+4, 2)
hour = float(strmid(fl, l+7, 2))
if ifile eq 0 then minu = 0 else minu = float(strmid(filename, l+9, 2))
seco = 0

itime = [year,fix(mont),fix(day),fix(hour),fix(minu),fix(seco)]
c_a_to_r,itime,rt
rtime = rt

if year lt 50 then iyear = year + 2000 else iyear = year + 1900
stryear = strtrim(string(iyear),2)
strmth = strtrim(mont,2)
strday = strtrim(day,2)
uttime = hour+minu/60.+seco/60./60.

strdate = stryear+'-'+strmth+'-'+strday

celltotl = 0
celltoth = 0
;;;;;;;; Highlats ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
locs = where(abs(data(1,0,*,0)/!dtor) ge 60. and abs(data(1,0,*,0)/!dtor) le 90.)
nlocs = n_elements(locs)
szaarr = fltarr(nlons,n_elements(locs))

for iloc = 0, nlocs - 1 do begin
    for ilon = 0, nlons - 1 do begin
         glon = data(0,ilon,locs(iloc),0)/!dtor
        if glon gt 180.0 then glon = glon - 360.0
        glat = data(1,0,locs(iloc),0)/!dtor
        zsun,strdate,uttime ,glat,glon, zenith,azimuth,solfac
        szaarr(ilon,iloc) = zenith
    endfor
endfor


highavg = fltarr(nvars,nalts-4)
for ivar = 0, nvars - 1 do begin
    if nvars gt 1 then  wv = 3 + ivar 
    for ialt = 2, nalts - 3 do begin
        celltot = 0
        for ilon = 1, nlons - 2 do begin
            for iloc = 1, nlocs - 1 do begin
                
                latavg = (lats(locs(iloc))+lats(locs(iloc)+1))/2.
                cellvol = ((re+alts(ialt))^2*abs(sin(latavg*!dtor))*(alts(ialt+1)-alts(ialt)) $
                           * (lats(locs(iloc)+1)-lats(locs(iloc)))*!dtor * (lons(ilon+1)-lons(ilon))*!dtor)
                highavg(ivar,ialt-2) = highavg(ivar,ialt-2) + $
                  data(wv, ilon, locs(iloc),ialt)*cellvol
                celltot = celltot + cellvol

            endfor
        endfor
        highavg(ivar,ialt-2) = highavg(ivar,ialt-2)/celltot
    endfor
endfor

;;;;;;;;;;;Low lats ;;;;;;;;;;;;;;;;;;;;;
                
locs = where(abs(data(1,0,*,0)/!dtor) le 30.)
nlocs = n_elements(locs)
szaarr = fltarr(nlons,n_elements(locs))

for iloc = 0, nlocs - 1 do begin
    for ilon = 0, nlons - 1 do begin
        glon = data(0,ilon,locs(iloc),0)/!dtor
        if glon gt 180.0 then glon = glon - 360.0
        glat = data(1,0,locs(iloc),0)/!dtor
        zsun,strdate,uttime ,glat,glon, zenith,azimuth,solfac
        szaarr(ilon,iloc) = zenith
    endfor
endfor


lowdayavg = fltarr(nvars,nalts-4)
lownitavg = fltarr(nvars,nalts-4)

for ivar = 0, nvars - 1 do begin
    if nvars gt 1 then  wv = 3 + ivar
    for ialt = 2, nalts - 3 do begin
        celltoth = 0
        celltotl = 0
temp = 0
count = 0
        for ilon = 1, nlons - 2 do begin
            for iloc = 0, nlocs - 1 do begin
        
                if szaarr(ilon,iloc) lt 30. then begin
                    latavg = (lats(locs(iloc))+lats(locs(iloc)+1))/2.
                    cellvol = ((re+alts(ialt))^2*abs(sin(latavg*!dtor))*(alts(ialt+1)-alts(ialt)) $
                               * (lats(locs(iloc)+1)-lats(locs(iloc)))*!dtor * (lons(ilon+1)-lons(ilon))*!dtor)
                    lowdayavg(ivar,ialt-2) = lowdayavg(ivar,ialt-2) + $
                      data( wv, ilon, locs(iloc),ialt)*cellvol
                    celltoth = celltoth + cellvol
                ;    temp = temp + alldata( wv, ilon, locs(iloc),ialt)
                ;  print, ilon, iloc, lons(ilon),lats(locs(iloc))
                    
count = count + 1
                endif

                if szaarr(ilon,iloc) gt 150. then begin
                    latavg = (lats(locs(iloc))+lats(locs(iloc)+1))/2.
                    cellvol = ((re+alts(ialt))^2*abs(sin(latavg*!dtor))*(alts(ialt+1)-alts(ialt)) $
                               * (lats(locs(iloc)+1)-lats(locs(iloc)))*!dtor * (lons(ilon+1)-lons(ilon))*!dtor)
                    lownitavg(ivar,ialt-2) = lownitavg(ivar,ialt-2) + $
                      data(wv, ilon, locs(iloc),ialt)*cellvol
                    celltotl = celltotl + cellvol
;                      print, ilon, iloc, lons(ilon),lats(locs(iloc)),szaarr(ilon,iloc)
                endif

            endfor
        endfor

        lowdayavg(ivar,ialt-2) = lowdayavg(ivar,ialt-2)/celltoth
        lownitavg(ivar,ialt-2) = lownitavg(ivar,ialt-2)/celltotl

     endfor
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if n_elements(plottype) eq 0 then plottype = 0
if plotall ne 1 then begin

    print, '0)  Global Average'
    print, '1)  High-Latitude Average'
    print, '2)  Low-Latitude Day Average'
    print, '3)  Low-Latitude Night Average'
    print, '4)  Zonal Average'

    plottype = fix(ask('which type of plot: ',tostr(plottype))) 
endif
   
loadct, 39

;plotcolors = findgen(ndirs)*(254-10)/(nd-1.)+10

if n_elements(plotlog) eq 0 then plotlog = 0
plotlog = fix(ask('whether to make plot log (0/1): ',tostr(plotlog)))
if plotlog then begin
    glbplot = alog10(glbavg)
    highplot = alog10(highavg) 
    lowdayplot = alog10(lowdayavg) 
    lownitplot = alog10(lownitavg) 
endif else begin
    glbplot = glbavg
    highplot = highavg
    lowdayplot = lowdayavg
    lownitplot = lownitavg
endelse

yrange = [90,500]
if nvars gt 1 then xrange = [-.1,.1] else xrange = mm([glbplot,lowdayplot])
xrange(0) = 0
ppp = 6
space = 0.08
pos_space, ppp, space, sizes
get_position, ppp, space, sizes, 0, pos0, /rect
get_position, ppp, space, sizes, 1, pos1, /rect
get_position, ppp, space, sizes, 2, pos2, /rect
get_position, ppp, space, sizes, 3, pos3, /rect
get_position, ppp, space, sizes, 5, pos4, /rect
!p.charsize = 1.3

if nvars eq 1 then colors = 0 else colors = (254)/nvars*indgen(nvars) + 30

if nvars eq 1 then proftitle = strmid(vars(whichvar),0,4)+'_prof.ps' else $
  proftitle = 'profile.ps'

if strpos(proftitle,'[') gt -1 then proftitle = strmid(proftitle,1)
setdevice, proftitle,'p',5,.95

;;;;; GLOBAL AVERAGE PLOT;;;;;;;;;;;;;;;
plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
  yrange = yrange,charsize = 1.3,$
  xstyle=1, ystyle=1,pos = pos0,/noerase
if ivar eq 1 then plottitle = Vars(whichvar) else plottitle = ' '
for ivar = 0, nvars - 1 do begin
    oplot,glbplot(ivar,*), $
      alts,thick = 3,color = colors(ivar),linestyle = ivar
endfor
xyouts,pos0(0) + .3,pos0(3) + .03,plottitle,/norm
xyouts,pos0(0) + .1,pos0(1)-.06,'Global Average',/norm

;;;;; HIGH-LATITUDE AVERAGE PLOT;;;;;;;;;;;;;;;
;xrange = [-.1,.1];[-1*max(abs(mm(highavg))),max(abs(mm(highavg)))]
plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange,$
  yrange = yrange,charsize = 1.3,ytickname=strarr(10)+' ',$
  xstyle = 1,ystyle = 1, pos = pos1,/noerase

for ivar = 0, nvars - 1 do begin
    oplot,highplot(ivar,*), $
      alts,thick = 3,color = colors(ivar),linestyle = ivar
endfor

xyouts,pos1(0) + .1,pos1(1)-.06,'High-lat Average',/norm

;;;;; LOW-LATITUDE DAY AVERAGE PLOT;;;;;;;;;;;;;;;
;xrange = [-.1,.1];[-1*max(abs(mm(lowdayavg))),max(abs(mm(lowdayavg)))]
plot, xrange, yrange,/nodata,color = 1, background = 255,$
  yrange = yrange,charsize = 1.2,$
  xstyle = 1,ystyle = 1,pos = pos2,/noerase
for ivar = 0, nvars - 1 do begin
    oplot,lowdayplot(ivar,*), $
      alts,thick = 3,color = colors(ivar),linestyle = ivar
endfor

xyouts,pos2(0) + .07,pos2(1)-.06,'Low-lat Day Average',/norm

;;;;; LOW-LATITUDE NIGHT AVERAGE PLOT;;;;;;;;;;;;;;;
;xrange = [-.1,.1];[-1*max(abs(mm(lownitavg))),max(abs(mm(lownitavg)))]
plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
  yrange = yrange, ytickname = strarr(10)+' ',charsize = 1.2,$
  xstyle = 1,ystyle = 1,pos = pos3,/noerase

for ivar = 0, nvars - 1 do begin
      oplot,lownitplot(ivar,*), $
      alts,thick = 3,color = colors(ivar),linestyle = ivar
endfor
xyouts,pos3(0) + .05,pos3(1)-.06,'Low-lat Night Average',/norm

if nvars gt 1 then begin
    legend,vars(3:9),linestyle=findgen(nvars-1),color=colors,pos=[.01,.3],/norm,box=0,$
      thick=3
 endif

closedevice
;------------------------------------------------------------------------------
;
;;;;;;;;;Low altitude zoom;;;;;;;;;;;
;plotdumb
;plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
;  yrange = [100,200],charsize = 1.3,$
;  xstyle=1, pos = pos0,/noerase
;
;for ivar = 0, nvars - 2 do begin
;      oplot,glbplot(ivar,*), $
;      alts,thick = 3,color = colors(ivar),linestyle = ivar
;endfor
;xyouts,pos0(0) + .1,pos0(1)-.06,'Global Average',/norm
;plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
;  yrange = [100,200],ytickname = strarr(10) + ' ',charsize = 1.3,$
;  xstyle = 1,ystyle = 1, pos = pos1,/noerase
;
;for ivar = 0, nvars - 2 do begin
;      oplot,highplot(ivar,*), $
;      alts,thick = 3,color = colors(ivar),linestyle = ivar
;endfor
;xyouts,pos1(0) + .1,pos1(1)-.06,'High-lat Average',/norm
;plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
;  yrange = [100,200], charsize = 1.2,$
;  xstyle = 1,ystyle = 1,pos = pos2,/noerase
;
;for ivar = 0, nvars - 2 do begin
;      oplot,lowdayplot(ivar,*), $
;      alts,thick = 3,color = colors(ivar),linestyle = ivar
;endfor
;xyouts,pos2(0) + .07,pos2(1)-.06,'Low-lat Day Average',/norm
;plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
;  yrange = [100,200], ytickname=strarr(10)+' ',charsize = 1.2,$
;  xstyle = 1,ystyle = 1,pos = pos3,/noerase
;
;for ivar = 0, nvars - 2 do begin
;      oplot,lownitplot(ivar,*), $
;      alts,thick = 3,color = colors(ivar),linestyle = ivar
;endfor
;xyouts,pos3(0) + .05,pos3(1)-.06,'Low-lat Night Average',/norm
;if nvars gt 1 then begin
;    legend,vars(3:9),linestyle=findgen(nvars-1),color=colors,pos=[.01,.3],/norm,box=0,$
;      thick=3
;endif
;
;closedevice
;
;
;if plotenergy and nvars gt 1 then begin
;
;colors = (254)/3*indgen(3) + 30
;setdevice,'energy.ps','p',5,.95
;ppp=6
;space = 0.08
;pos_space, ppp, space, sizes
;xrange = [0,1.0]
;
;plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
;  yrange = yrange,charsize = 1.3,$
;  xstyle=1, pos = pos0,/noerase
;
;for ivar = 0, 2 do begin
;    oplot,glbplot(enervars(ivar)-3,*), $
;      alts,thick = 3,color = colors(ivar),linestyle = ivar
;endfor
;xyouts,pos0(0) + .1,pos0(1)-.06,'Global Average',/norm
;;xrange = [-.1,.1];[-1*max(abs(mm(highavg))),max(abs(mm(highavg)))]
;plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange,$
;  yrange = yrange,charsize = 1.3,ytickname=strarr(10)+' ',$
;  xstyle = 1,ystyle = 1, pos = pos1,/noerase
;
;for ivar = 0, 2 do begin
;    oplot,highplot(enervars(ivar)-3,*), $
;      alts,thick = 3,color = colors(ivar),linestyle = ivar
;endfor
;xyouts,pos1(0) + .1,pos1(1)-.06,'High-lat Average',/norm
;;xrange = [-.1,.1];[-1*max(abs(mm(lowdayavg))),max(abs(mm(lowdayavg)))]
;plot, xrange, yrange,/nodata,color = 1, background = 255,$
;  yrange = yrange,charsize = 1.2,$
;  xstyle = 1,ystyle = 1,pos = pos2,/noerase
;for ivar = 0,  2 do begin
;    oplot,lowdayplot(enervars(ivar)-3,*), $
;      alts,thick = 3,color = colors(ivar),linestyle = ivar
;endfor
;xyouts,pos2(0) + .07,pos2(1)-.06,'Low-lat Day Average',/norm
;;xrange = [-.1,.1];[-1*max(abs(mm(lownitavg))),max(abs(mm(lownitavg)))]
;plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
;  yrange = yrange, ytickname = strarr(10)+' ',charsize = 1.2,$
;  xstyle = 1,ystyle = 1,pos = pos3,/noerase
;
;for ivar = 0, 2 do begin
;      oplot,lownitplot(enervars(ivar)-3,*), $
;      alts,thick = 3,color = colors(ivar),linestyle = ivar
;endfor
;xyouts,pos3(0) + .05,pos3(1)-.06,'Low-lat Night Average',/norm
;
;if nvars gt 1 then begin
;    legend,vars(enervars),linestyle=findgen(3),color=colors,pos=[.01,.3],/norm,box=0,$
;      thick=3
;endif
;
;plot,[0,1],yrange,/nodata,color = 1, background = 255, xrange = [0,1], $
;  yrange = yrange, ytitle='Altitude',charsize = 1.2,$
;  xstyle = 1,ystyle = 1,pos = pos4,/noerase
;
;oplot,glbavg(enervars(0)-3,*)+glbavg(enervars(1)-3,*)/glbavg(enervars(2)-3,*),alts,thick=3,color = 30,linestyle = 0
;oplot,highavg(enervars(0)-3,*)+highavg(enervars(1)-3,*)/highavg(enervars(2)-3,*),alts,thick=3,color = 90,linestyle = 0
;oplot,lowdayavg(enervars(0)-3,*)+lowdayavg(enervars(1)-3,*)/lowdayavg(enervars(2)-3,*),alts,thick=3,color = 150,linestyle = 0
;xyouts,pos4(0) + .1,pos4(1)-.06,'Heating Efficiency',/norm
;
;legend,['Global','High','LowDay'],color=[30,90,150],pos=[pos4(2)-.3,pos4(3)-.01],$
;  /norm,box=0,$
;  thick=3,linestyle = 0
;closedevice
;endif


end
