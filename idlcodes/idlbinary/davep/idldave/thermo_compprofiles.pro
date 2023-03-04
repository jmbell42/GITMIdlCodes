GetNewData = 1
plotall = 0
if n_elements(ndirsnew) eq 0 then ndirsnew = 1
ndirsnew = fix(ask('number of directories: ',tostr(ndirsnew)))

if n_elements(ndirs) eq 0 then ndirs = 0
if ndirsnew ne ndirs then directoriesnew = strarr(ndirsnew)
ndirs = ndirsnew

for idir = 0, ndirs - 1 do begin
    directoriesnew(idir) = ask('directory '+tostr(idir+1)+': ',directoriesnew(idir))
endfor

dir = directoriesnew(0)

files = file_search(dir(0)+'/3D*')

for ifile = 0, n_elements(files) - 1 do print, tostr(ifile)+'   '+files(ifile)
ifile = 0
if n_elements(filenum) eq 0 then filenum = 0
filenum = fix(ask('which file: ',tostr(filenum)))

l = 24
l2 = strlen(files(filenum))
filenamenew = strmid(files(filenum),l2 - l)
if n_elements(filename) eq 0 then filename = ' '
if n_elements(directories) eq 0 then directories = ' '
if filenamenew eq filename and directories(0) ne directoriesnew(0) then begin
    GetNewData = 0
    GetNewData = fix(ask('whether to get new data: ',tostr(GetNewData)))
endif
directories = directoriesnew
filename = filenamenew

if n_elements(read) eq 0 then read = 0
if read then begin
    reread = 'n'
    reread = ask('whether to reread data: ',reread)
    if reread eq 'y' then getnewdata = 1 else getnewdata = 0
endif

if GetNewData eq 1 then begin
    for idir = 0, ndirs - 1 do begin
        fn = directories(idir)+'/'+filename
        
         print, 'Reading file ',fn
                
         read_thermosphere_file, fn, nvars, nalts, nlats, nlons, $
           vars, data, rb, cb, bl_cnt

         if strpos(fn,'ALL') ge 0 then ALL = 1 else ALL = 0
        
         if ALL then begin
             nvars = nvars + 1
             vars = [vars,'[O]/[N2]']
             if idir eq 0 then begin
                 hmf2 = fltarr(ndirs,nlons-4,nlats-4)
                 nmf2 = fltarr(ndirs,nlons-4,nlats-4)
             endif
         endif
         if idir eq 0 then alldata = fltarr(ndirs,nvars,nlons,nlats,nalts)

         if nvars eq n_elements(alldata(0,*,0,0,0)) then begin
             if ALL then begin
                 alldata(idir,0:nvars-2,*,*,*) = data
                 ovar = where(vars eq '[O(!U3!NP)]')
                 n2var = where(vars eq '[N!D2!N]')
                 evar = where(vars eq '[e-]')
                 on2var = where(vars eq '[O]/[N2]')
               
                 on2 = data(ovar,*,*,*)/data(n2var,*,*,*)
                 
                 for ilon = 2, nlons - 3 do begin
                     for ilat = 2, nlats - 3 do begin
                         nmf2(idir,ilon-2,ilat-2) = max(data(evar,ilon,ilat,2:nalts-3),ihmf2)
                         hmf2(idir,ilon-2,ilat-2) = data(2,0,0,ihmf2+2)
                     endfor
                 endfor
                 alldata(idir,nvars-1,*,*,*) = on2
             endif else begin
                 alldata(idir,*,*,*,*) = data
             endelse
         endif else begin
             novar = where(vars eq 'V!Dn!N(up,NO)')
             alldata(idir,0:novar-1,*,*,*) = data(0:novar-1,*,*,*)
             alldata(idir,novar:*,*,*,*) = data(novar+1:*,*,*,*)
             vars = [vars(0:novar-1),vars(novar+1:*)]
             nvars = nvars - 1
         endelse
         alts = reform(data(2,0,0,*))/1000.
         lons = reform(data(0,*,0,0))/!dtor
         lats = reform(data(1,0,*,0))/!dtor
         dlat = (lats(1) - lats(0))*!dtor
         dlon = (lons(1) - lons(0))*!dtor

         read = 1
     endfor
 endif

;;;;Global Average



for ivar = 0, nvars - 1 do print, tostr(ivar)+'  '+vars(ivar)
print, tostr(nvars)+'  Scale Height'

if n_elements(whichvar) eq 0 then whichvar = 15
whichvar = fix(ask('which variable to plot: ',tostr(whichvar)))

if whichvar eq nvars then plotscaleheight = 1 else plotscaleheight = 0
if plotscaleheight then begin
    SHdata = fltarr(ndirs,5,nalts-2)
    SHvars = [15,4,5,6,3]
    redo = 5
    wv = SHvars(0)
endif else begin
    redo = 1
    wv = whichvar
endelse

nredos = 0
while redo gt 0 do begin
    glbavg = fltarr(ndirs,nalts-2)
    re = 6378.
    for idir = 0, ndirs - 1 do begin
        for ialt = 1, nalts - 2 do begin
            celltot = 0
            for ilon = 2, nlons - 3 do begin
                for ilat = 1, nlats - 3 do begin

                    latavg = lats(ilat) + dlat/!dtor/2.
                    cellvol = ((re+alts(ialt))^2*abs(sin(latavg*!dtor))* $
                               (alts(ialt+1)-alts(ialt)) * $
                               dlat * dlon)
                    glbavg(idir,ialt-1) = glbavg(idir,ialt-1) + $
                      (alldata(idir,wv,ilon,ilat,ialt) * cellvol)
                    celltot = celltot+cellvol
                endfor
            endfor
            
            totvol = 4/3.*!pi*((re+alts(ialt+1))^3 - (re+alts(ialt))^3)
            glbavg(idir,ialt-1) = glbavg(idir,ialt-1)/celltot
        endfor
    endfor
    if plotscaleheight then SHdata(*,nredos,*) = glbavg
    redo = redo - 1
    nredos = nredos + 1
    if redo gt 0 then wv = SHvars(nredos) 
endwhile

if plotscaleheight then begin
    k = 1.381e-23
    totalden = fltarr(2,nalts-2)
    mass = fltarr(2,nalts-2)
    scaleheight = fltarr(2,nalts-2)
    SH = fltarr(2,nalts-2)
gravity = fltarr(nalts-2)
for ialt = 0, nalts - 3 do begin
    totalden(0,ialt) = SHdata(0,1,ialt)+SHdata(0,2,ialt)+SHdata(0,3,ialt)
    totalden(1,ialt) = SHdata(1,1,ialt)+SHdata(1,2,ialt)+SHdata(1,3,ialt)
    
    mass(0,ialt) = 1.66e-27*(SHdata(0,1,ialt)*16/totalden(0,ialt) + SHdata(0,2,ialt) * $
                             32/totalden(0,ialt) + SHdata(0,3,ialt)*28/totalden(0,ialt))
    mass(1,ialt) = 1.66e-27*(SHdata(1,1,ialt)*16/totalden(1,ialt) + SHdata(1,2,ialt) * $
                             32/totalden(1,ialt) + SHdata(1,3,ialt)*28/totalden(1,ialt))
    gravity(ialt) = (6.673e-11*5.9742e24)/(((6378.1+alts(ialt+1))*1000.)^2)
    
    scaleheight(0,ialt) = (k*SHdata(0,0,ialt))/(mass(0,ialt)*gravity(ialt))
    scaleheight(1,ialt) = (k*SHdata(1,0,ialt))/(mass(1,ialt)*gravity(ialt))
endfor

for ialt = 0, nalts - 4 do begin
    SH(0,ialt) = -(alts(ialt+1)-alts(ialt))/(alog(SHdata(0,4,ialt+1)) - alog(SHdata(0,4,ialt))) 
    SH(1,ialt) = -(alts(ialt+1)-alts(ialt))/(alog(SHdata(1,4,ialt+1)) - alog(SHdata(1,4,ialt)))
endfor
    glbavg = scaleheight/1000.
   
endif

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

zalt = 400
ialt400 = max(where(alts-zalt le 0))
if abs(alts(ialt400) - 400) gt abs(alts(ialt400+1) - 400) then ialt400 = ialt400 + 1

log = 0
if log then begin
    openw,1,'log.dat'
    for idir = 0, ndirs - 1 do begin
        if whichvar eq 33 then begin
            printf,1,tostr(idir) +' Glb avg NmF2 atf 400 km: '+tostrf(mean(nmf2(idir,*,*)))
        endif else begin
            printf, 1, tostr(idir)+' Glb avg at 400 km: '+tostrf(glbavg(idir,ialt400))
        endelse
    endfor
    close,1
endif
;;;;;;;; Highlats ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
locs = where(abs(alldata(0,1,0,*,0)/!dtor) ge 60. and $
            abs(alldata(0,1,0,*,0)/!dtor + dlat/!dtor/2.) le 90.5 )
nlocs = n_elements(locs)
szaarr = fltarr(nlons,n_elements(locs))

for iloc = 0, nlocs - 1 do begin
    for ilon = 0, nlons - 1 do begin
        glon = lons(ilon)
        glat = alldata(0,1,0,locs(iloc),0)/!dtor
        zsun,strdate,uttime ,glat,glon, zenith,azimuth,solfac
        szaarr(ilon,iloc) = zenith
    endfor
endfor

highavg = fltarr(ndirs,nalts-2)

for idir = 0, ndirs - 1 do begin
    for ialt = 1, nalts - 2 do begin
        celltot = 0
        for ilon = 2, nlons - 3 do begin
            for iloc = 0, nlocs - 1 do begin
                
                latavg = lats(locs(iloc)) + dlat/!dtor/2.
                cellvol = ((re+alts(ialt))^2*abs(sin(latavg*!dtor))*(alts(ialt+1)-alts(ialt)) $
                           * dlat * dlon)

                highavg(idir,ialt-1) = highavg(idir,ialt-1) + $
                  alldata(idir, wv, ilon, locs(iloc),ialt)*cellvol
                celltot = celltot + cellvol
            endfor
        endfor
        highavg(idir,ialt-1) = highavg(idir,ialt-1)/celltot
    endfor
endfor

;;;;;;;;;;;Low lats ;;;;;;;;;;;;;;;;;;;;;
                
locs = where(abs(alldata(0,1,0,*,0)/!dtor) le 30.)
nlocs = n_elements(locs)
szaarr = fltarr(nlons,nlocs)

for ilon = 0, nlons - 1 do begin
    for iloc = 0, nlocs - 1 do begin
        glon = lons(ilon)
        glat = lats(locs(iloc))
        zsun,strdate,uttime ,glat,glon, zenith,azimuth,solfac
        szaarr(ilon,iloc) = zenith
    endfor
endfor

plottest = 0

tempdayavg = fltarr(ndirs,nalts-2)
tempdayavg1 = fltarr(ndirs,nalts-2)
tempdayavg2 = fltarr(ndirs,nalts-2)
lowdayavg = fltarr(ndirs,nalts-2)
lownitavg = fltarr(ndirs,nalts-2)

for idir = 0, ndirs - 1 do begin
    for ialt = 1, nalts - 2 do begin
        celltoth = 0
        celltotl = 0
temp = 0
count = 0
        for ilon = 2, nlons - 3 do begin
            for iloc = 0, nlocs - 1 do begin

                if szaarr(ilon,iloc) lt 30. then begin
                
                    latavg = lats(locs(iloc)) + dlat/!dtor/2.

                    cellvol = ((re+alts(ialt))^2*abs(sin(latavg*!dtor))*(alts(ialt+1)-alts(ialt)) $
                               * dlon * dlat)

                    lowdayavg(idir,ialt-1) = lowdayavg(idir,ialt-1) + $
                      alldata(idir, wv, ilon, locs(iloc),ialt)*cellvol
                    if plottest then begin                  
                    tempdayavg1(idir,ialt-1) = tempdayavg1(idir,ialt-1) + $
                      (alldata(idir, 24, ilon, locs(iloc),ialt)+$
                       alldata(idir, 25, ilon, locs(iloc),ialt) + $
                       alldata(idir, 26, ilon, locs(iloc),ialt))*cellvol

                    tempdayavg(idir,ialt-1) = tempdayavg(idir,ialt-1) + $
                      (alldata(idir, 25, ilon, locs(iloc),ialt) + $
                       alldata(idir, 26, ilon, locs(iloc),ialt))*cellvol

                     tempdayavg2(idir,ialt-1) = tempdayavg2(idir,ialt-1) + $
                      (alldata(idir, 24, ilon, locs(iloc),ialt)+$
                       alldata(idir, 25, ilon, locs(iloc),ialt) + $
                       alldata(idir, 26, ilon, locs(iloc),ialt) + $
                      alldata(idir, 23, ilon, locs(iloc),ialt))*cellvol
                 endif
                    celltoth = celltoth + cellvol
                ;    temp = temp + alldata(idir, wv, ilon, locs(iloc),ialt)
                ;    print, ilon, iloc, lons(ilon),lats(locs(iloc))
                    count = count + 1
                endif

                if szaarr(ilon,iloc) gt 150. then begin

                    latavg = lats(locs(iloc)) + dlat/!dtor/2.
                    cellvol = ((re+alts(ialt))^2*abs(sin(latavg*!dtor))*(alts(ialt+1)-alts(ialt)) $
                               * dlat * dlon)

                    lownitavg(idir,ialt-1) = lownitavg(idir,ialt-1) + $
                      alldata(idir, wv, ilon, locs(iloc),ialt)*cellvol
                    celltotl = celltotl + cellvol
                endif

            endfor

        endfor
        if plottest then begin
            tempdayavg(idir,ialt-1) = tempdayavg(idir,ialt-1)/celltoth
            tempdayavg1(idir,ialt-1) = tempdayavg1(idir,ialt-1)/celltoth
            tempdayavg2(idir,ialt-1) = tempdayavg2(idir,ialt-1)/celltoth
        endif
        lowdayavg(idir,ialt-1) = lowdayavg(idir,ialt-1)/celltoth
        lownitavg(idir,ialt-1) = lownitavg(idir,ialt-1)/celltotl
    endfor
endfor


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLOTS ;;;;;;;;;;;;;;;;;

if n_elements(plottype) eq 0 then plottype = 0
;if plotall ne 1 then begin

;    print, '0)  Global Average'
;    print, '1)  High-Latitude Average'
;    print, '2)  Low-Latitude Day Average'
;    print, '3)  Low-Latitude Night Average'
;    
;    plottype = fix(ask('which type of plot: ',tostr(plottype))) 
;endif
   
loadct, 39

if ndirs eq 1 then nd = 2 else nd = ndirs
plotcolors = findgen(ndirs)*(254-10)/(nd-1.)+10
plotcolors = fltarr(ndirs)
if n_elements(plotlog) eq 0 then plotlog = 0
plotlog = fix(ask('whether to make plot log (0/1): ',tostr(plotlog)))
if plotlog then begin
    glbplot = alog10(glbavg) 
    highplot = alog10(highavg) 
    lowdayplot = alog10(lowdayavg) 
    lownitplot = alog10(lownitavg) 
endif else  begin
    glbplot = glbavg
    highplot = highavg 
    lowdayplot = lowdayavg 
    lownitplot = lownitavg
endelse

yrange = [100,200]
xrange = mm([glbplot,highplot,lownitplot,lowdayplot])

if strmid(directories(0),0,1) eq 'C' then names = ['Conduction 1','Conduction 2','Conduction 3']
if strmid(directories(0),0,1) eq 'E' then names = ['Eddy 1','Eddy 2','Eddy 3']
if strmid(directories(0),0,1) eq 'N' then names = ['N!D2!N Diss 1','N!D2!N Diss 2','N!D2!N Diss 3']
if strmid(directories(0),0,1) eq 'O' then names = $
  ['O!D2!U+!N Recombine 1','O!D2!U+!N Recombine 2','O!D2!U+!N Recombine 3 ']
if strmid(directories(0),0,2) eq 'ND' then names = ['NO Diffusion 1','NO Diffusion 2']
if strmid(directories(0),0,2) eq 'NC' then names = ['NO Cooling 1','NO Cooling 2','NO Cooling 3']
if strmid(directories(0),0,2) eq 'NO' then names = ['NO!U+!N Recombine 1','NO!U+!N Recombine 2']
if strmid(directories(0),0,1) eq 'T' then names = ['Turbopause 1','Turbopause 2','Turbopause 3']

if vars(whichvar) eq 'Temperature' then xrange = [150,1100]
;if vars(whichvar) eq 'Temperature' then xrange = [300,1900]
;if vars(whichvar) eq '[NO]'  then xrange = [0,1.0]
if vars(whichvar) eq '[O]/[N2]' then xrange = [0,10]
if vars(whichvar) eq 'V!Dn!N(up,NO)' then xrange = [-30,30]
ppp = 4
space = 0.01
pos_space, ppp, space, sizes
get_position, ppp, space, sizes, 0, pos, /rect
get_position, ppp, space, sizes, 1, pos1, /rect
get_position, ppp, space, sizes, 2, pos2, /rect
get_position, ppp, space, sizes, 3, pos3, /rect

pos(0) = pos(0) + .03
pos1(2) = pos1(2) - .03
pos2(0) = pos2(0) + .03
pos3(2) = pos3(2) - .03

pos(1) = pos(1) + .04
pos1(1) = pos1(1) + .04
pos2(1) = pos2(1) + .04
pos3(1) = pos3(1) + .04

proftitle = strmid(vars(whichvar),0,4)+ strmid(directories(0),l1,3)+'.ps'

while strpos(proftitle,'[') ge 0 do begin
    l = strpos(proftitle,'[')
    proftitle = strjoin([strmid(proftitle,0,l),strmid(proftitle,l+1)])
endwhile

while strpos(proftitle,']') ge 0 do begin
    l = strpos(proftitle,']')
    proftitle = strjoin([strmid(proftitle,0,l),strmid(proftitle,l+1)])
endwhile

if n_elements(ptitle) eq 0 then ptitle = proftitle
ptitle = ask('plot title: ',ptitle)
setdevice, ptitle,'p',5,.95
xtitle = vars(whichvar);+' (10!U14!N)'
 
if plottype eq 0 or plotall then begin

    plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
      yrange = yrange,ytitle = 'Altitude',charsize = 1.8,$
      xtitle=xtitle,$
      title = 'Global Average',xstyle=1, pos = pos,/noerase
     
     for idir = 0, ndirs - 1 do begin
         oplot, glbplot(idir,*), $
           alts,thick = 3,$
           color = plotcolors(idir), linestyle = idir
         if plotscaleheight then oplot, SH(idir,*), alts,thick=3,color=plotcolors(idir),$
           linestyle = 2
     endfor
;     legend, names,colors = plotcolors,pos=[pos(0)+.002,pos(3) - .02],$
;       linestyle=indgen(ndirs)*2,box = 0,$
;       thick = 3,/norm,charsize=.9

 endif

if plottype eq 1 or plotall then begin

    plot, xrange, yrange,/nodata,color = 1, background = 255, $
      xrange = xrange, xtickname=strarr(10)+' ',$
      yrange = yrange,ytickname=strarr(10)+' ' ,xcharsize = 1.0,ycharsize = 1.0,$
      xstyle = 1,ystyle = 1,title = 'High latitude Average', pos = pos1,/noerase
    
    for idir = 0, ndirs - 1 do begin
        oplot,highplot(idir,*), $
          alts,thick = 3,$
          color = plotcolors(idir), linestyle = idir*2
    endfor
    
endif 

if plottype eq 2 or plotall then begin
    
    plot, xrange, yrange,/nodata,color = 1, background = 255, $
      yrange = yrange, xtitle = xtitle,ytitle = 'Altitude',xcharsize = 1.0,ycharsize = 1.0,$
      xstyle = 1,ystyle = 1,title = 'Low latitude Day',pos = pos2,/noerase,xrange = xrange
    
    for idir = 0, ndirs - 1 do begin
        oplot,lowdayplot(idir,*), $
          alts,thick = 3,$
          color = plotcolors(idir), linestyle = idir*2
    endfor
    
endif

if plottype eq 3 or plotall then begin    
 
    plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
      yrange = yrange, xtitle=xtitle,ytickname = strarr(10) + ' ',xcharsize = 1.0,$
      xstyle = 1,ystyle = 1,title = 'Low latitude Night',pos = pos3,/noerase,ycharsize = 1.0
    
    for idir = 0, ndirs - 1 do begin
        oplot,lownitplot(idir,*), $
          alts,thick = 3,$
          color = plotcolors(idir), linestyle = idir*2
    endfor
    

endif

closedevice

if plottest then begin
space = 0.1
pos_space, ppp, space, sizes
get_position, ppp, space, sizes, 0, pos, /rect
get_position, ppp, space, sizes, 1, pos1, /rect
get_position, ppp, space, sizes, 2, pos2, /rect
get_position, ppp, space, sizes, 3, pos3, /rect

setdevice, 'test.ps','p',5,.95
xrange = [0,8e11]
  plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
      yrange = yrange,ytitle = 'Altitude',xcharsize = 1.0,$
      ycharsize = 1.0,xtitle = '[N2+]+[NO+]',$
      title = 'Low Lat Dayside Average',xstyle=1, pos = pos,/noerase
     
     for idir = 0, ndirs - 1 do begin
         oplot, tempdayavg(idir,*), $
           alts,thick = 3,$
           color = plotcolors(idir), linestyle = idir*2
     endfor

     legend, names,colors = plotcolors,pos=[pos(0)+.005,pos(3) - .02],$
       linestyle=indgen(ndirs)*2,box = 0,$
       thick = 3,/norm,charsize=.9

 plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
      yrange = yrange,ytickname=strarr(10)+ ' ',xcharsize = 1.0,$
      ycharsize = 1.0,xtitle = '[O2+]+[N2+]+[NO+]',$
      title = 'Low Lat Dayside Average',xstyle=1, pos = pos1,/noerase
     
     for idir = 0, ndirs - 1 do begin
         oplot, tempdayavg1(idir,*), $
           alts,thick = 3,$
           color = plotcolors(idir), linestyle = idir*2
     endfor

 plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
      yrange = yrange,ytitle = 'Altitude',xcharsize = 1.0,$
      ycharsize = 1.0,xtitle = '[O2+]+[N2+]+[NO+]+[O+]',$
      title = 'Low Lat Dayside Average',xstyle=1, pos = pos2,/noerase
     
     for idir = 0, ndirs - 1 do begin
         oplot, tempdayavg2(idir,*), $
           alts,thick = 3,$
           color = plotcolors(idir), linestyle = idir*2
     endfor

     
closedevice
endif
; if plotscaleheight then xtitle = 'Scale Height' else xtitle = vars(whichvar)
;     plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
;       yrange = [100,200], xtitle = xtitle,ytitle = 'Altitude',charsize = 1.3,$
;       xstyle=1, pos = pos1,/noerase
;     
;     for idir = 0, ndirs - 1 do begin
;         oplot, glbplot(idir,*), $
;           alts,thick = 3,$
;           color = plotcolors(idir), linestyle = idir*2
;         if plotscaleheight then oplot, SH(idir,*), alts,thick=3,color=plotcolors(idir),$
;           linestyle = 2
;     endfor
;     legend, directories,colors = plotcolors,pos=[pos(0) + .07,pos1(3) - .07],$
;       linestyle=indgen(ndirs)*2,box = 0,$
;       thick = 3,/norm
;     closedevice


;    get_position, ppp, space, sizes, 1, pos2, /rect
;    plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
;      yrange = [100,200], xtitle = vars(whichvar),ytitle = 'Altitude',charsize = 1.2,$
;      xstyle = 1,ystyle = 1,title = 'Global Average'
;
;     for idir = 0, ndirs - 1 do begin
;        oplot,glbavg(idir,*), $
;          alts,thick = 3,$
;          color = plotcolors(idir)
;    endfor
;
;    legend, directories,colors = plotcolors,pos=[.15,.9],$
;      linestyle=fltarr(ndirs),box = 0,$
;      thick = 3,/norm
;


; plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
;      yrange = [100,200], xtitle = vars(whichvar),ytitle = 'Altitude',charsize = 1.3,$
;      xstyle = 1,ystyle = 1, pos = pos1,/noerase
;    
;    for idir = 0, ndirs - 1 do begin
;        oplot,highavg(idir,*), $
;          alts,thick = 3,$
;          color = plotcolors(idir), linestyle = idir*2
;    endfor
;    
;    legend, directories,colors = plotcolors,pos=[pos(0) + .07,pos1(3) - .07],$
;      linestyle=indgen(ndirs)*2,box = 0,$
;      thick = 3,/norm
;    closedevice



; plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
;      yrange = [100,200], xtitle = vars(whichvar),ytitle = 'Altitude',charsize = 1.2,$
;      xstyle = 1,ystyle = 1,pos = pos1,/noerase
;    
;    for idir = 0, ndirs - 1 do begin
;        oplot,lowdayavg(idir,*), $
;          alts,thick = 3,$
;          color = plotcolors(idir), linestyle = idir*2
;    endfor
;    
;    legend, directories,colors = plotcolors,pos=[pos(0) + .07,pos1(3) - .07],$
;      linestyle=indgen(ndirs)*2,box = 0,$
;      thick = 3,/norm
;
;    closedevice
;endif


; plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
;      yrange = [100,200], xtitle = vars(whichvar),ytitle = 'Altitude',charsize = 1.2,$
;      xstyle = 1,ystyle = 1,pos = pos1,/noerase
;    
;    for idir = 0, ndirs - 1 do begin
;        oplot,lownitavg(idir,*), $
;          alts,thick = 3,$
;          color = plotcolors(idir), linestyle = idir*2
;    endfor
;    
;    legend, directories,colors = plotcolors,pos=[pos(0) + .07,pos1(3) - .07],$
;      linestyle=indgen(ndirs)*2,box = 0,$
;      thick = 3,/norm
;    
;closedevice
;endif




end