if n_elements(nfiles) eq 0 then nfiles = 1
nfiles = fix(ask('how many flares to plot? ', tostr(nfiles)))

if n_elements(nflares) eq 0 then nflares = 0
if n_elements(flarefiles) eq 0 or nflares ne nfiles then flarefiles = strarr(nfiles)
nflares = nfiles
for iflare = 0, nfiles - 1 do begin
    flarefiles(iflare) = ask('flare file '+tostr(iflare+1)+' :',flarefiles(iflare))
endfor
close,/all
    openr,30, '/Users/dpawlows/UpperAtmosphere/SEE/wavelow'
    openr,31,'/Users/dpawlows/UpperAtmosphere/SEE/wavehigh'
    nbins = 59
    wavelow=fltarr(nbins)
    wavehigh=fltarr(nbins)
    readf,30,wavelow
    readf,31,wavehigh
    
close,30
close,31
   ;convert to nm
wavelow=wavelow/10.
wavehigh=wavehigh/10.
waveave = (wavelow+wavehigh)/2.
nlinesmax = 10000
flux = fltarr(nfiles,59,nlinesmax)


itime = intarr(6,nlinesmax)
rtime = dblarr(nfiles,nlinesmax)
iline = intarr(nfiles)
for iflare = 0, nflares - 1 do begin
    openr, 1, flarefiles(iflare)

    started = 0 
    temp = ' '
    t = 0
    while not started do begin
        readf,1,temp
        if strpos(temp,'#START') ge 0 then started = 1

    endwhile
    

    line = fltarr(59+7)
    while not eof(1) do begin
        readf,1,line
        
        itime(*,iline(iflare)) = fix(line(0:5))
        c_a_to_r, itime(*,iline(iflare)),rt
        rtime(iflare,iline(iflare)) = rt

        flux(iflare,*,iline(iflare)) = line(7:*)
        iline(iflare) = iline(iflare) + 1
    endwhile


close,1
endfor
il = max(iline)
flux = flux(*,*,0:il-1)
intflux = fltarr(nfiles,59,il)

nlinesmax = 10000
htime = dblarr(nlinesmax)
hflux = fltarr(59,nlinesmax)
readhal = 1
hline = -1
if readhal then begin
 openr, 1, 'hal.dat'

    started = 0 
    temp = ' '
    t = 0
    while not started do begin
        readf,1,temp
        if strpos(temp,'#START') ge 0 then started = 1

    endwhile
    

    line = fltarr(59+6)
    while not eof(1) do begin
       hline = hline + 1
       readf,1,line

        it = fix(line(0:5))
        c_a_to_r, it,rt
        htime(hline) = rt

        hflux(*,hline) = line(6:*)
      
    endwhile
hl=hline
hflux = hflux(*,0:hl-1)
htime = htime(0:hl-1)

close,1

endif

for i = 0, il - 2 do begin
    for iflare = 0, nflares - 1 do begin
        for iwave = 0, 58 do begin
            
            if flux(iflare,iwave,i) eq 0 then flux(iflare,iwave,i) = flux(iflare,iwave,i-1)

            if i gt 1 then begin
                intflux(iflare,iwave,i) = intflux(iflare,iwave,i - 1) + flux(iflare,iwave,i) * $
                  (rtime(iflare,i) - rtime(iflare,i-1)) 

            endif else begin
                if i eq 1 then begin
                    intflux(iflare,iwave,i) = flux(iflare,iwave,i)*(rtime(iflare,i+1)-rtime(iflare,i))
                endif
            endelse

        endfor
    endfor
endfor


itime = itime(*,0:il-1)
rtime = rtime(*,0:il-1)
satime = [2005,09,20,23,0,0]
eatime = [2005,09,21,7,0,0]
c_a_to_r,satime,stime
c_a_to_r,eatime,etime

;locs = where(rtime(0,*) ge stime and rtime(0,*) le etime)
;stop
;nt = rtime(0,locs)
;nf = flux(0,*,locs)
;nts = n_elements(nt)

nwaves = 59
wv2d = fltarr(nwaves,il-2)
t2d = dblarr(nwaves,il-2)
for i = 1, il - 2 do begin
   for iwave = 0, 58 do begin
      wv2d(iwave,i-1) = waveave(iwave)
      t2d(iwave,i-1) = rtime(0,i)
      
   endfor 
endfor

hw2d = fltarr(nwaves,hl)
ht2d = dblarr(nwaves,hl)
for i = 0, hl - 1 do begin
   for iwave = 0, 58 do begin
      hw2d(iwave,i) = waveave(iwave)
      ht2d(iwave,i) = htime(i)
   endfor
endfor


;yrange = mm(alog10(total(flux(*,56:58,*),2)))
;yrange = [-10,-3]

time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
xrange = [0,etime-stime]

;yrange(0) = 10e-7

loadct,39
;plot, rtime(0,*)-stime,/nodata,xrange = xrange,$
;  xtickname = xtickname,xtitle = xtitle, xtickv=xtickv,xticks=xtickn,xminor=xminor,$
;  pos = [.1,.1,.9,.6],ystyle=1,yrange = [-6,-2],xrange=xrange
names = strarr(nfiles)
len = strpos(flarefiles,'.',/reverse_search,/reverse_offset)
for ifile = 0, nfiles - 1 do begin
    names(ifile) = strmid(flarefiles(ifile),0,len(ifile))
endfor
ppp = 4
space = 0.01
pos_space, ppp, space, sizes,ny=ppp

setdevice, 'plot.ps','p',5,.95

yrange = [0,4e-3]
yrange = [1e-5,1e-2]
;yrange = mm(total(flux(4,56:58,0:iline(4)),2))
get_position, ppp, space, sizes, 0, pos1, /rect
pos1(0) = pos1(0) + 0.1
plot, rtime(0,*)-stime,xrange = xrange,$
  xtickname = strarr(10) + ' ', xtickv=xtickv,xticks=xtickn,xminor=xminor,$
  pos = pos1,ystyle=1,/nodata,yrange = yrange,xstyle=1,$
  ytitle='Flux (.1-.8 nm)',charsize=1.2,/ylog,/noerase


colors = findgen(nflares)*254/nflares+254/nflares
for iflare = 0, nflares - 1 do begin
;    oplot, rtime(iflare,*)-stime,alog10(total(flux(iflare,56:58,0:iline(iflare)-1),2)),color = colors(iflare), thick = 3
    oplot, rtime(iflare,*)-stime,total(flux(iflare,56:58,0:iline(iflare)-1),2),color = colors(iflare), thick = 3

endfor

legend,names,color=colors,linestyle=fltarr(nflares),box = 0, $!late
  pos = [pos1(2)-.25,pos1(3)-.03],/norm


;----------------------------------------------------------------------
yrange = mm(intflux)
yrange = [1e-4,10]
get_position, ppp, space, sizes, 1, pos1, /rect
pos1(0) = pos1(0) + 0.1
plot, rtime(0,*)-stime,xrange = xrange,$
  xtickname = xtickname,xtitle = xtitle, xtickv=xtickv,xticks=xtickn,xminor=xminor,$
  pos = pos1,ystyle=1,/nodata,yrange = yrange,xstyle=1,$
  ytitle='Integrated Flux (.1-.8 nm)',charsize=1.2,/ylog,/noerase


colors = findgen(nflares)*254/nflares+254/nflares
for iflare = 0, nflares - 1 do begin
;    oplot, rtime(iflare,*)-stime,alog10(total(flux(iflare,56:58,0:iline(iflare)-1),2)),color = colors(iflare), thick = 3
    oplot, rtime(iflare,*)-stime,total(intflux(iflare,56:58,0:iline(iflare)-1),2),color = colors(iflare), thick = 3

 endfor

legend,names,color=colors,linestyle=fltarr(nflares),box = 0, $
  pos = [pos1(2)-.25,pos1(3)-.06],/norm
closedevice

loadct,39
setdevice,'plot2.ps','p',5,.95

ppp = 2
space = 0.01
pos_space, ppp, space, sizes,ny=ppp
get_position, ppp, space, sizes, 0, pos1, /rect
pos1(0) = pos1(0) + 0.1

stime = t2d(0,0)
etime = stime + 2*3600
et = etime-stime
time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn

xrange = [0,etime-stime]
loadct,39
f = reform(flux(0,*,1:il-2))
fp = f
hp = fltarr(nwaves,hl)
for i = 0, 58 do begin
   fp(i,*) =alog10( f(i,*)/f(i,0))
   hp(i,*) = alog10(hflux(i,*) / hflux(i,0))
;   fp(58-i,*) =alog10(f(i,*))

endfor
mini = min(fp)
maxi = max(fp)
levels = findgen(31) * (maxi-mini) / 30 + mini
zrange = mm(fp)
az = 40
ax = 40
locs = where(t2d(0,*)-stime lt et)

ytitle = 'Wavelength (nm)'
ztitle = '!C!Clog!D10!N Normalized Flux'
surface,fp(*,locs),wv2d(*,locs),t2d(*,locs)-stime,/horizontal,$
        pos=pos1,az=az,ax=ax,/noerase,/upper_only,ytickname=strarr(10)+' ',$
        yticks=xtickn,ytickv=xtickv,yminor=xminor,yrange=xrange,zrange=zrange,$
        charsize=1.2;,xtickname=strarr(10)+' '


xyouts,.7,pos1(3)-.2,'Idealized flare',/norm
;xyouts,.12,pos1(1)-.0,'UT Hours',orientation=-25,/norm,charsize=1.2
;xyouts,.6,pos1(1)-.02,ytitle,orientation=17,/norm,charsize=1.2
xyouts,-.04,pos1(1)+.1,ztitle,orientation=90,/norm,charsize=1.2


stime = ht2d(0,0)
etime = max(ht2d)
get_position, ppp, space, sizes, 1, pos1, /rect
pos1(0) = pos1(0) + 0.07
pos1(1) = pos1(1) + .1
pos1(3) = pos1(3) + .1
locs = where(ht2d(0,*)-stime lt et)

surface,hp(*,locs),hw2d(*,locs),ht2d(*,locs)-stime,pos=pos1,az=az,ax=ax,/noerase,/upper_only,ytickname='!C'+xtickname,$
        yticks=xtickn,ytickv=xtickv,yminor=xminor,yrange=xrange,zrange=zrange,$
       charsize=1.2

xyouts,.7,pos1(3) - .2,'Halloween flare',/norm
xyouts,.12,pos1(1)-.0,'UT Hours',orientation=-25,/norm,charsize=1.2
xyouts,.6,pos1(1)-.02,ytitle,orientation=17,/norm,charsize=1.2
xyouts,-.04,pos1(1)+.1,ztitle,orientation=90,/norm,charsize=1.2
;contour,fp,wv2d,t2d-stime,/noerase,/t3d,zvalue=1.0,ytickname=strarr(10) + ' ',$
;        yticks=xtickn,ytickv=xtickv,yminor=xminor,yrange=xrange,xtickname=strarr(10) + ' ',$;
;        nlevels=30
       




;contour,fp,t2d-stime,wv2d,xtitle=xtitle,ytitle= 'Wavelength',$
;           xtickname=xtickname,xtickv=xtickv,xticks=xtickn,xminor=xminor,levels=levels,/fill,$
;        pos = pos1,yrange = mm(waveave),ystyle=1
;shade_surf,t2d-stime,wv2d,alog10(flux(0,*,*)),xtitle=xtitle,ytitle= 'Wavelength'
;           xtickname=xtickname,xtickv=xtickv,xtickn=xticks,xminor=xminor,pos=pos1

closedevice
end
