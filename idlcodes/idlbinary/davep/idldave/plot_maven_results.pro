;lts = ['8:13','12:28','16:47',

compare = 0
if n_elements(isevent) eq 0 then isevent = 'n'
isevent = ask('Is there an event ',isevent)

if strpos(isevent,'y') ge 0 then begin
   if n_elements(eventtime) eq 0 then eventtime = intarr(6)
   eventtime = fix(strsplit(ask('event time: ',strjoin(tostr(eventtime),' ')),/extract))
   c_a_to_r,eventtime,eventrtime
endif
mavenfile = 'maven.dat'
ntmax = 10000
temp = ' '
openr, 1, mavenfile
readf,1,temp
rtime = dblarr(ntmax)
itimearr = intarr(6,ntmax)
lat = fltarr(ntmax)
lon=fltarr(ntmax)
alt = fltarr(ntmax)
itime = 0
while not eof(1) do begin
   readf, 1, temp
   t = strsplit(temp,/extract)
   ta = fix(t(0:5))
   c_a_to_r,ta,rt
   itimearr(*,itime) = ta
   rtime(itime) = rt

   lon(itime) = t(7)
   lat(itime) = t(8)
   alt(itime) = t(9)   
   
   itime = itime +1

endwhile
ntimes = itime
close,1
lat = lat(0:ntimes-1)
lon = lon(0:ntimes-1)
alt = alt(0:ntimes-1)
rtime = rtime(0:ntimes-1)
itimearr = itimearr(*,0:ntimes-1)
locs= where(alt lt 300,ntimes)
lat = lat(locs)
lon = lon(locs)
alt = alt(locs)
rtime = rtime(locs)
itimearr = itimearr(*,locs)

if n_elements(dir) eq 0 then dir = ' '
dir = ask("which directory to plot: ",dir)

filelist = file_search(dir+'/mave*.bin')
nfiles_new = n_elements(filelist)
if n_elements(nfiles) eq 0 then nfiles = 0


if compare then begin
   if n_elements(dir_base) eq 0 then dir_base = ' '
   dir_base = ask("which baseline directory to plot: ",dir_base)
   filelist_base = file_search(dir_base+'/mave*.bin')
   nfiles_new_base = n_elements(filelist_base)

endif
if nfiles ne nfiles_new then begin
   reread = 1
endif else begin
   reread = 'n'
   reread = ask('whether to reread ',reread)
   if strpos(reread,'y') ge 0 then reread = 1 else reread = 0
endelse

if reread then begin
   mavendensity = fltarr(ntmax)
   thermo_readsat, filelist, data, time, nGITMTimes, Vars, nAlts, nSats, Files,version
   
   nFiles = n_elements(filelist)

   if compare then begin
      thermo_readsat, filelist_base, data_base, time_base, nGITMTimes_base, Vars_base, nAlts_base, nSats_base, Files_base,version
      
      nFiles_base = n_elements(filelist_base)
   endif
endif


locs = intarr(ntmax)-1
for itime = 0, ntimes - 1 do begin
   maventime = rtime(itime)
   mini = min(where(maventime - time le 0))
   if abs(maventime - time(mini)) gt abs(maventime - time(mini-1)) then mini = mini-1
   locs(itime) = mini

  
   
   

endfor

display,vars
if n_elements(pvar) eq 0 then pvar = 3
pvar = fix(ask('which variable to plot: ',tostr(pvar)))

otherlocs = where(locs gt 0,ntimes)
locs = locs(otherlocs)


gtime = time(locs)
rtime = rtime(0:ntimes-1)
alt = alt(0:ntimes-1)
lon = lon(0:ntimes-1)
lat = lat(0:ntimes-1)
rho = fltarr(ntimes)
if compare then rho_base = fltarr(ntimes)
gitmalts = reform(data(0,0,2,*))/1000.

orbitstartend = intarr(2,10000)
iorbit = 0
for itime = 0, ntimes - 1 do begin
   altfind = alt(itime)
  ihigh = min(where(altfind - gitmalts le 0))
  gitmrho = reform(data(0,locs(itime),pvar,*))
    
   ralt = (gitmalts(ihigh) - altfind)/(gitmalts(ihigh) - gitmalts(ihigh-1))
   rho(itime) = gitmrho(ihigh)-(gitmrho(ihigh) - gitmrho(ihigh-1))*ralt
   
   if compare then begin
      gitmrho_base = reform(data_base(0,locs(itime),pvar,*))
      rho_base(itime) = gitmrho_base(ihigh)-(gitmrho_base(ihigh) - gitmrho_base(ihigh-1))*ralt
   endif

if (gtime(itime) - gtime(itime-1) gt 1000) and itime gt 0 then begin
   iorbit = iorbit + 1
   orbitstartend(0,iorbit) = itime 
   orbitstartend(1,iorbit-1) = itime - 1 
   
endif
endfor

if pvar eq 3 then rho = alog10(rho)
if compare then value = (rho-rho_base)/rho_base * 100.0 else $
   value = rho

norbits = iorbit+1
orbitstartend(1,iorbit) = itime-1
orbitstartend = orbitstartend(*,0:norbits-1)
altmin = fltarr(norbits)
rhomin = fltarr(norbits)
tmin = dblarr(norbits)
rhomin_base = fltarr(norbits)
orbitpoints = (orbitstartend(1,*) - orbitstartend(0,*))
maxorbitpoint = max(orbitpoints)
orblat = fltarr(norbits,maxorbitpoint)
orblon = fltarr(norbits,maxorbitpoint)
for iorbit = 0, norbits - 1 do begin
;   minalt = min(alt(orbitstartend(0,iorbit):orbitstartend(1,iorbit)),iminalt)
   diff = alt(orbitstartend(0,iorbit):orbitstartend(1,iorbit)) - 200. 
   mindiff = min(abs(diff),iminalt)
   iminalt = iminalt + orbitstartend(0,iorbit)
;   altmin(iorbit) = minalt
   rhomin(iorbit) = rho(iminalt)
   if compare then rhomin_base(iorbit) = rho_base(iminalt)
   tmin(iorbit) = gtime(iminalt)


endfor

colors = get_colors(norbits)
setdevice,'peri.ps','p',5,.95
loadct,39
ppp = 2
space = 0.01
    pos_space, ppp, space, sizes, ny = ppp
get_position, ppp, space, sizes, 0, pos, /rect
pos(0) = pos(0)+.05
stime = time(0)
etime = max(time)
time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn, mars

if compare then begin
   val = (rhomin-rhomin_base)/rhomin_base * 100.0
   ytitle = vars(pvar)+' at 200 km'
endif else begin
   val = rhomin
   ytitle = vars(pvar)
endelse

plot, tmin - stime,val,xrange = [btr,etr], xtickname=xtickname,xtickv=xtickv,xminor=xminor,$
      xticks=xtickn,charsize=1.3,xtitle=xtitle,ytitle = ytitle,pos=pos,$
      title=vars(pvar)+'- Consecutive MAVEN Orbits at 200 km'
for iorbit = 0,norbits - 1 do begin
   plots,tmin(iorbit)-stime,val(iorbit),psym=sym(5),symsize=2.0,color=colors(iorbit)
endfor
;oplot,tmin-stime,val,color = 150,psym = 2, symsize = 3.0,thick=3
;oplot,tmin-stime,val,color = 150,thick=2

if strpos(isevent, 'y') ge 0 then begin
   oplot, [eventrtime-stime,eventrtime-stime],[0,max(val)*100],thick=4
endif
closedevice

setdevice,'plot.ps','p',5,.95 
;onrange = mm(lon)
;atrange = mm(lat)
;imit = [min(lat),min(lon),max(lat),max(lon)]

;ile = '~/idl/marsflat.jpg'
;ead_jpeg, file, image
;x = n_elements(image(0,*,0))
;y = n_elements(image(0,0,*))
;ew_image = fltarr(nx,ny)
;                               ;We usually plot with 0 lon in the
;                               ;middle, but the jpeg as 0 lon on the right...
;or i=nx/2, nx-1 do begin
;  new_image(i-nx/2,0:ny-1)  = image(2,i,*)
;  new_image(i,0:ny-1)  = image(2,i-nx/2,*)
;ndfor
;os = [.05,.05,.95,.95]
;p.position = pos
;lat = mean(latrange)
;lon = mean(latrange)
;map_set, title=' ',plat,plon,/ortho,/noborder,limit=limit,/noerase
;contour, new_image, levels = [150], /noerase, $;
;           xstyle =5, ystyle=5, thick=1.5
;map_set,/noerase



yrange = [100,300]
xrange = [min(value),max(value)]
if compare then begin
   xtitle = vars(pvar)+' Percent Difference'
endif else begin
   if pvar eq 3 then xtitle = 'log('+vars(pvar)+')' else $
   xtitle = vars(pvar)
endelse

plot,xrange,yrange,/nodata,xrange=xrange,yrange=yrange,xtitle=xtitle,$
     ytitle='Altitude (km)',pos=pos,charsize=1.3,xstyle = 1
   
     
for iorbit = 0, norbits - 1 do begin
   y = alt(orbitstartend(0,iorbit):orbitstartend(1,iorbit))
   x = value(orbitstartend(0,iorbit):orbitstartend(1,iorbit))
   oplot,x,y,color = colors(iorbit),thick=3

endfor

p = pos(1)+.06
xbeg = pos(0)+.3
label=tostr(indgen(norbits)+1)

usersym,[0,0,2,2,0],[0,2,2,0,0],/fill
legend,strarr(norbits), position=[xbeg,p],/norm,psym=8,/horizontal,color=colors,pspacing=5,box=0
legend,label,position=[xbeg,p-.02],/norm,/horizontal,box=0
xyouts, xbeg-.07,p-.0385,'Orbit #',/norm
;for iorbit = 0, norbits - 1 do begin
;   z = value(orbitstartend(0,iorbit):orbitstartend(1,iorbit))
;   x = lat(orbitstartend(0,iorbit):orbitstartend(1,iorbit))
;   y = lon(orbitstartend(0,iorbit):orbitstartend(1,iorbit))
;   
;   oplot,y,x
;endfor
closedevice
pos(2) = pos(2) - .1
yrange = [100,300]
xrange = [30,65]
setdevice,'latalt.ps','p',5,.95
plot,xrange,yrange,/nodata,xrange=xrange,yrange=yrange,xtitle='Latitude',$
     ytitle='Altitude (km)',pos=pos,charsize=1.3,xstyle = 1,/noerase

maxi = max(value)
mini = min(value)

levels = findgen(31) * (maxi-mini) / 30 + mini
colors = get_colors(31)
ilevel = intarr(ntimes)
for i = 0, ntimes - 2 do begin
   minlev = min(abs(value(i) - levels),ilev)
   ilevel(i) = ilev
   x = [lat(i),lat(i+1)]
   y = [alt(i),alt(i+1)]
   if x(0) - x(1) lt 10 then begin
      plots,x,y,color = colors(ilevel(i)),thick=2 ;,psym=sym(5),symsize=1
   endif
endfor
pos(0) = pos(2)+0.025
pos(2) = pos(0)+0.03
maxmin = mm(levels)

title = vars(pvar)
plotct,254,pos,maxmin,title,/right,color=color

;for iorbit = 0, norbits - 1 do begin
;   x = lat(orbitstartend(0,iorbit):orbitstartend(1,iorbit))
;   y = alt(orbitstartend(0,iorbit):orbitstartend(1,iorbit))

;value(orbitstartend(0,iorbit):orbitstartend(1,iorbit))
;   plots,x,y,color = colors(iorbit),thick=3

;endfor
closedevice
end

