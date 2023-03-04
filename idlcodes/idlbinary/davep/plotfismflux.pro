if n_elements(filedate) eq 0 then filedate = ' '
filedate = ask('MM/DD/YYYY: ',filedate)
if n_elements(ndays) eq 0 then ndays = 1
ndays = fix(ask('Number of days (1 min): ',tostr(ndays)))

iwave1 = 52
iwave2 = 55



close, 30
close,31
openr,30,'/Users/dpawlows/UpperAtmosphere/SEE/wavelow'
openr,31,'/Users/dpawlows/UpperAtmosphere/SEE/wavehigh'
wavelow=fltarr(59)
wavehigh=fltarr(59)
readf,30,wavelow
readf,31,wavehigh
nwaves  = 59
waveavg = (wavehigh + wavelow)/2.

filedt = strsplit(filedate,'/',/extract)
filemonth = filedt(0)
fileday = filedt(1)
fileyear = filedt(2)
doy = ymd2dn(fileyear,filemonth,fileday)

plotname = '/Users/dpawlows/UpperAtmosphere/FISM/BinnedFiles/plots/fismplot'+tostr(filedt(0))+$
  tostr(filedt(1))+tostr(filedt(2))+$
  '.ps'
loadct, 39
setdevice,plotname,'p',5,.95
ppp = ndays+1

space = 0.01
pos_space, ppp, space, sizes, ny = ppp

keepwave1 = [0]
keepwave2 = [0]
time = [0]
;i wave out of 59...;;;


for day = 0, ndays - 1 do begin

;    file = '/Users/dpawlows/UpperAtmosphere/FISM/BinnedFiles/'+fileyear+'/fismflux' + fileyear + $
;      chopr('0'+tostr(filemonth),2) +
;      chopr('0'+tostr(fileday),2)+'.dat'
    file = '/Users/dpawlows/UpperAtmosphere/FISM/Mars/BinnedFiles/fismflux' + fileyear + $
      chopr('0'+tostr(filemonth),2) + chopr('0'+tostr(fileday),2)+'.dat'
    
    nlines = file_lines(file)/11
    temp = ' '
    timearr = intarr(6,nlines)
    ttemp = intarr(6)
    rtime = dblarr(nlines)
    fluxarr = fltarr(59,nlines)
    ftemp = fltarr(59)
    close, 5
    openr, 5, file
    while strpos(temp,'#START') lt 0 do begin
        readf,5,temp
    endwhile
    
    ft = fltarr(nlines)
    for i = 0, nlines - 1 do begin
        readf, 5, ttemp,ftemp
        timearr(*,i) = ttemp
        fluxarr(*,i) = ftemp
        keepwave1 = [keepwave1,fluxarr(iwave1,i)]
        keepwave2 = [keepwave2,fluxarr(iwave2,i)]
    endfor
    close, 5
    for i = 0, 57 do begin
        if waveavg(i) lt waveavg(i+1) then begin 
            switchi = i
            t = waveavg(switchi)
            waveavg(switchi) = waveavg(switchi+1)
            waveavg(switchi+1) = t
            ft = fluxarr(switchi,*)
            fluxarr(switchi,*) = fluxarr(switchi+1,*)
            fluxarr(switchi+1,*) = ft        
        endif
    endfor
    for i = 0, nlines - 1 do begin
        c_a_to_r, timearr(*,i), rt
        rtime(i) = rt
        time = [time,rt]
    endfor
    
    ;if day eq 0 then begin
    ;     time = rtime
    ;endif
    
   
    ;title = 'SEE flux on '+filedate
    
    get_position, ppp, space, sizes, day, pos, /rect

    pos(0) = pos(0) + 0.1
   if day ne ndays - 1 then begin
       plot, waveavg, /nodata, /ylog, yrange=[10e-7,.01],xrange=[0,1000], $
         background=255, color=1, ytitle='Flux (W/m^2)', $
         pos = pos,xstyle = 1,charsize = 1.3,thick=3,$
         /noerase, xtickname = strarr(10)+' ' 
   endif else begin
        plot, waveavg, /nodata, /ylog, yrange=[10e-7,.01],xrange=[0,1000], $
         background=255, color=1, ytitle='Flux (W/m^2)', $
         pos = pos,xstyle = 1,charsize = 1.3,thick=3,$
          xtitle = 'Wavelength (nm)',/noerase
    endelse

    for i=0, nlines-1 do begin
        oplot, waveavg, fluxarr(*,i), color=(i)*17 + 5 ,thick = 3
    endfor
    dl = tostr(filemonth)+'/'+tostr(fileday)+'/'+fileyear
    xyouts, 800,3e-3,dl,/data
doy = doy + 1

YDN2MD,fileyear,doy,m,d

fileday = d
filemonth = m
endfor
colors=intarr(nlines)
names=strarr(nlines)
label=strarr(16)
label[0]='0 UT'
label[8]='12 UT'
label[15]='23 UT'
usersym,[0,0,2,2,0],[0,2,2,0,0],/fill

for i=0,nlines-1 do begin
    colors[i]=5+17*i
    names[i]=''
endfor
p = pos(1)-.06
legend,names, position=[.08,p],/norm,psym=8,/horizontal,color=colors,pspacing=5,box=0
legend,label,position=[.08,p-.02],/norm,/horizontal,box=0

closedevice
stime = time(1)
etime = time(n_elements(time)-1)
ntimes = n_elements(time)
time_axis,  stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn


flarecontour = 1
if flarecontour then begin
    waves2d = fltarr(nwaves,nlines)
    time2d = dblarr(nwaves,nlines)
    for iwave = 0, nwaves - 1 do begin
        waves2d(iwave,*) = waveavg(iwave)
        time2d(iwave,*) = rtime
    endfor


if n_elements(fstime) eq 0 then begin
    c_r_to_a,fstime,stime
    fetime = fstime
endif
fstime = fix(strsplit(ask('flare start time: ',strjoin(tostr(fstime),' ')),/extract))
fetime = fix(strsplit(ask('flare end time: ',strjoin(tostr(fetime),' ')),/extract))

c_a_to_r, fstime,fst
c_a_to_r, fetime,fet

locs = where(time ge fst and time le fet)

setdevice,'flare.ps','p',5,.95
ppp = 2
space = 0.03
pos_space, ppp, space, sizes
    
get_position, ppp, space, sizes, 0, pos, /rect
pos(2) = pos(2) - 0.05
pos(0) = pos(0) + 0.03
fluxlog = alog10(fluxarr)
maxi = max(fluxlog(*,locs))
mini=min(fluxlog(*,locs))
levels = findgen(31) * (maxi-mini) / 30 + mini

stime = fst
etime = fet
time_axis,  stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
xrange = [btr,etr]
contour,fluxlog(*,locs),time2d(*,locs)-stime,waves2d(*,locs),xtickname=strarr(10)+' ',$
 xtickv=xtickv,xticks=xtickn,xminor=xminor,xrange=xrange,$
  yrange = mm(waveavg),xstyle=1,ystyle=1,pos=pos,/fill,levels=levels,$
  ytitle = 'Wavelength (nm)',/noerase

 ctpos = pos
 ctpos(0) = pos(2)+0.025
 ctpos(2) = ctpos(0)+0.03
 maxmin = [mini,maxi]
 plotct, 255, ctpos, maxmin, title, /right
;----------------------
tlocs = where(time ge fst and time le fet)
wlocs = where(waveavg lt 300)
get_position, ppp, space, sizes, 1, pos, /rect
pos(2) = pos(2) - 0.05
pos(0) = pos(0) + 0.03

wloc1 = min(wlocs)
wloc2 = max(wlocs)
fluxlog = alog10(fluxarr(wloc1:wloc2,tlocs))
time2d = time2d(wloc1:wloc2,tlocs)
waves2d = waves2d(wloc1:wloc2,tlocs)

maxi = max(fluxlog)
mini=min(fluxlog)
levels = findgen(31) * (maxi-mini) / 30 + mini

stime = fst
etime = fet
time_axis,  stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
xrange = [btr,etr]

contour,fluxlog,time2d-stime,waves2d,$
  xtickname=xtickname,$
  xtitle = xtitle,xtickv=xtickv,xticks=xtickn,xminor=xminor,xrange=xrange,$
  yrange = mm(waves2d),xstyle=1,ystyle=1,pos=pos,/fill,levels=levels,$
  ytitle = 'Wavelength (nm)',/noerase

 ctpos = pos
 ctpos(0) = pos(2)+0.025
 ctpos(2) = ctpos(0)+0.03
 maxmin = [mini,maxi]
 plotct, 255, ctpos, maxmin, title, /right
closedevice
endif

;setdevice,'plot.ps','p',5,.95

;
;plotname2 = '/Users/dpawlows/FISM/BinnedFiles/plots/wave'+tostr(filedt(0))+$
;  tostr(filedt(1))+tostr(filedt(2))+$
;  '.ps'
;setdevice,plotname2,'p',5,.95
;ppp = 5
;space = 0.01
;pos_space, ppp, space, sizes, ny = ppp
;
;get_position, ppp, space, sizes, 0, pos, /rect
;pos(0) = pos(0) + 0.1
;min1 = min(keepwave1(where(keepwave1 ne 0)))-.3*min(keepwave1(where(keepwave1 ne 0)))
;max1 = max(keepwave1)+.3*max(keepwave1)
;min2 = max(keepwave2(where(keepwave2 ne 0)))-.3*min(keepwave2(where(keepwave2 ne 0)))
;max2 = max(keepwave2)+.3*max(keepwave2)
;plot,time(1:n_elements(time)-1)-stime,[0,12],/nodata,/noerase,/ylog,$
;       ytitle='Flux (' +tostr(waveavg(iwave1)/10.)+'nm)', yrange =[min1,2e-3],$
;      xtickname = strarr(10)+' ',pos = pos, xtickv = xtickv, xminor = xminor, $
;      xticks = xtickn,xstyle = 1, ystyle = 1,charsize = 1.3
;
;oplot,time-stime,keepwave1,color = 254,thick=3
;
;get_position, ppp, space, sizes, 1, pos, /rect
;pos(0) = pos(0) + 0.1
;
;plot,time(1:n_elements(time)-1)-stime,[0,12],/nodata,/noerase,/ylog,$
;       ytitle='Flux (' +tostr(waveavg(iwave2)/10.)+'nm)', yrange = [1e-5,max2],$
;      xtickname = xtickname,pos = pos, xtickv = xtickv, xminor = xminor, $
;      xticks = xtickn,xstyle = 1, ystyle = 1,charsize = 1.3,xtitle = xtitle
;
;oplot,time-stime,keepwave2,color = 254,thick=3
;
;closedevice
end


