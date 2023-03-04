if n_elements(date) eq 0 then date = ' '
date = ask("date (yyyy-mm): ",date)
cyear = strmid(date,0,4)
cmonth = strmid(date,5,2)

if n_elements(nmonths) eq 0 then nmonths = 1
nmonths = fix(ask('number of months: ',tostr(nmonths)))
fismdir = '~/FISM/BinnedFiles/Hourly/'

;read in GITM wavelength information
close,/all
openr,30, '/Users/dpawlows/SEE/wavelow'
openr,31,'/Users/dpawlows/SEE/wavehigh'
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
waveavg = (wavelow+wavehigh)/2.


nlines = 24*31*nmonths
itimearr = intarr(6,nlines)
rtime = fltarr(nlines)
fismflux = fltarr(59,nlines)
t = intarr(6)
a = fltarr(59)
 iline = 0L
nmonthbegin = fix(cmonth)
for imonth = 0, nmonths - 1 do begin
    
    cmonth = chopr('0'+tostr(nmonthbegin+imonth),2)
    fismfile = 'fismflux_hourly'+cyear+cmonth+'.dat'
    fn = file_search(fismdir+fismfile)
    
    openr,5,fn(0)
    
    temp = ' '
    while strpos(temp,'#START') lt 0 do begin
        readf,5,temp
    endwhile
    
    while not eof(5) do begin
        readf,5,t,a
        itimearr(*,iline) = t
        fismflux(*,iline) = a
        c_a_to_r,itimearr(*,iline),rt
        rtime(iline) = rt
        iline = iline + 1
    endwhile
    close, 5
    
endfor

itimearr = itimearr(*,0:iline-1)
fismflux = fismflux(*,0:iline-1)
rtime = rtime(0:iline-1)
display, waveavg
pwave = intarr(4)
pwave(0) = 56
pwave(1) = 32
pwave(2) = 18
pwave(3) = 11

for iwave = 0, 3 do begin
    pwave(iwave) = fix(ask('wavelength '+tostr(iwave)+' to plot: ',tostr(pwave(iwave))))
endfor

stime = rtime(0)
etime = max(rtime)

time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn

ppp = 4
space = 0.01
pos_space, ppp, space, sizes, ny = ppp

setdevice, 'fism'+cyear+cmonth+'.ps','p',5,.95

get_position, ppp, space, sizes, 0, pos1, /rect
pos1(0) = pos1(0) + 0.1

plot,rtime-stime,fismflux(pwave(0),*),xtickv=xtickv,xticks=xtickn,$
  xminor=xminor,xtickname=strarr(10)+' ',xstyle=1,pos=pos1,/noerase,$
  ytitle='Flux ('+tostrf(waveavg(pwave(0)))+' nm) W/m!U2!D'

get_position, ppp, space, sizes, 1, pos1, /rect
pos1(0) = pos1(0) + 0.1

plot,rtime-stime,fismflux(pwave(1),*),xtickv=xtickv,xticks=xtickn,$
  xminor=xminor,xtickname=strarr(10)+' ',xstyle=1,pos=pos1,/noerase,$
  ytitle='Flux ('+tostrf(waveavg(pwave(1)))+' nm) W/m!U2!D'

get_position, ppp, space, sizes, 2, pos1, /rect
pos1(0) = pos1(0) + 0.1

plot,rtime-stime,fismflux(pwave(2),*),xtickv=xtickv,xticks=xtickn,$
  xminor=xminor,xtickname=strarr(10)+' ',xstyle=1,pos=pos1,/noerase,$
  ytitle='Flux ('+tostrf(waveavg(pwave(2)))+' nm) W/m!U2!D'

get_position, ppp, space, sizes, 3, pos1, /rect
pos1(0) = pos1(0) + 0.1

plot,rtime-stime,fismflux(pwave(3),*),xtitle=xtitle,xtickv=xtickv,xticks=xtickn,$
  xminor=xminor,xtickname=xtickname,xstyle=1,pos=pos1,$
  ytitle='Flux ('+tostrf(waveavg(pwave(3)))+' nm) W/m!U2!D',/noerase
closedevice

;ppp = 3
;space = 0.01
;pos_space, ppp, space, sizes, ny = ppp
;
;get_position, ppp, space, sizes, 1, pos1, /rect
;pos1(0) = pos1(0) + 0.1
;setdevice,'plot.ps','p',5,.95
;plot,rtime-stime,alog10(total(fismflux(56:58,*),1)),xtitle=xtitle,xtickv=xtickv,xticks=xtickn,$
;  xminor=xminor,xtickname=xtickname,xstyle=1,pos=pos1,yrange = [-7,-3],$
;  ytitle='Flux (.1-.8 nm) W/m!U2!D',/noerase
;
;closedevice


end
