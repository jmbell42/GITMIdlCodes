if (n_elements(year) eq 0) then year = '2000'
year = ask('year',year)

if (n_elements(month) eq 0) then month = '01'
month = string(fix(ask('month',month)), format='(I02)')

if (n_elements(day) eq 0) then day = '01'
day = string(fix(ask('day',day)), format='(I02)')

read_snoe,  year, month, day, noden, lats, lons, alts, ut, norbits, nlats,julday

meant = fltarr(norbits)
for iorb = 0, norbits - 1 do begin 
   thistime = reform(ut(iorb,*))
    locs = where(thistime ne -999)
    meant(iorb) = mean(thistime)
endfor

display,meant
if n_elements(whichtime) eq 0 then whichtime = 0
whichtime = fix(ask('which time to plot: ', tostr(whichtime)))

setdevice,'plot.ps','l',5,.95
pos = [.05,.05,.85,.95]
loadct, 39
den = reform(noden(whichtime,*,*))
locs = where(den gt 1)
minv = min(den(locs),max=maxv)

levels = findgen(31) * (maxv-minv) / 30 + minv

contour,den,lats(whichtime,*),alts(whichtime,*),/fill,levels=levels,$
  xrange = mm(lats(whichtime,*)),yrange=mm(alts(whichtime,*)),$
  xstyle = 1, ystyle = 1, xtitle = 'Latitude', ytitle = 'Altitude',$
  title = 'Nitric Oxide Density '+year+'-'+month+'-'+day+':'+chopl(tostrf(meant(whichtime)/3600.),4)+ ' UT Hours',$
  pos = pos,charsize=1.2,/follow

pos(0) = pos(2)+0.025
pos(2) = pos(0)+0.03
maxmin = mm(levels)
title = '[NO] #/m!U3!N'
plotct,254,pos,maxmin,title,/right,color=color
closedevice


end
    