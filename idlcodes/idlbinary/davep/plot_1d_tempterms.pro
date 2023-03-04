msis = 'y'

if n_elements(d) eq 0 then d = '.'
d = ask('which gitm directory to plot: ',d)
files = file_search(d+'/1DALL*')
nfiles = n_elements(files)

for ifile = 0, nfiles - 1 do print, tostr(ifile) + '  ' + files(ifile)
if n_elements(f) eq 0 then f = 0
f = fix(ask('which file: ',tostr(f)))
file = files(f)
l1 = strpos(file,'t',/reverse_search)+1
time = strmid(file,l1,13)
allfile = file_search(d+'/1DALL*'+time+'.bin')
thmfile = file_search(d+'/1DTHM*'+time+'.bin')

gitm_read_bin, allfile, alldata,alltime,allnvars,allvars,version
gitm_read_bin, thmfile, thmdata,thmtime,thmnvars,thmvars,version
l2 = strpos(file,'/',/reverse_search)+1
msisfile = 'data.msis/'+strmid(file,l2)

gitm_read_bin,msisfile,mdata,mtime,mnvars,mvars,mversion

nalts = n_elements(alldata(0,0,0,*))
alts = reform(alldata(2,0,0,*))/1000.
malts = reform(mdata(2,0,0,*))/1000.
totalden = fltarr(nalts)
mass = fltarr(nalts)
tempunit = fltarr(nalts)
cp = tempunit

for ialt = 0, nalts - 1 do begin
    totalden(ialt) = alldata(4,0,0,ialt)+alldata(5,0,0,ialt)+ $
      alldata(6,0,0,ialt)
    
    mass(ialt) = (alldata(4,0,0,ialt)*16 + alldata(5,0,0,ialt)*32 + $
                  alldata(6,0,0,ialt)*28) / totalden(ialt) * 1.66054886e-27

    cp(ialt) =  1.38065e-23/(2 * mass(ialt))
endfor    

tempunit = mass / 1.38065e-23

chemical = where(thmvars eq 'ChemicalHeating')
oc = where(thmvars eq 'OCooling')
noc = where(thmvars eq 'NOCooling')
euvh = where(thmvars eq 'EUVHeating')
cond = where(thmvars eq 'Conduction')
;radc = where(allvars eq 'RadCooling')
jouleh = where(thmvars eq 'JouleHeating')
totabs = where(thmvars eq 'TotalAbsEUV')

rho = alldata(3,0,0,2:nalts-3)
temp = alldata(15,0,0,2:nalts-3)
mtemp = mdata(15,0,0,2:nalts-3)
chemheat = thmdata(chemical,0,0,2:nalts-3) 
;  *3600*24. / (cp(2:nalts-3) /86400.)
;ocooling = data(oc,0,0,2:nalts-3)        * tempunit(2:nalts-3); $
;  *3600*24. / (cp(2:nalts-3) /86400.)
;nocooling = data(noc,0,0,2:nalts-3)      * tempunit(2:nalts-3); $ 
;  *3600*24. / (cp(2:nalts-3) /86400.)
conduction = thmdata(cond,0,0,2:nalts-3)   
;  *3600*24. / (cp(2:nalts-3) /86400.)
radcooling = (thmdata(oc,0,0,2:nalts-3)+thmdata(noc,0,0,2:nalts-3)) * (-1) 
;  *3600*24. / (cp(2:nalts-3) /86400.)
jouleheat = thmdata(jouleh,0,0,2:nalts-3)
;  *3600*24. / (cp(2:nalts-3) /86400.)
euvheating = thmdata(euvh,0,0,2:nalts-3) 
;  *3600*24. / (cp(2:nalts-3) /86400.)
totalabseuv = thmdata(totabs,0,0,2:nalts-3)

altsnew = alts(2:nalts-3)
maltsnew = malts(2:nalts-3)
setdevice, 'temp.ps','p',5,.95
loadct,39

ppp = 6
space = 0.01
pos_space, ppp, space, sizes,ny = 3

get_position, ppp, space, sizes, 0, pos, /rect
pos(0) = pos(0) + 0.05
pos(2) = pos(2) - 0.05
pos(1) = pos(1) + 0.025

;xrange = [min([min(chemheat),min(euvheating),min(jouleheat)])$
;          ,max([max(chemheat),max(euvheating),max(jouleheat)])]
xrange = [-.08,.28]
yrange = [100,600]
plot, xrange,yrange,/nodata,pos = pos, xtitle = 'Heating rate (K)', $
  ytitle = 'Altitude (km)', charsize = 1.2, ystyle = 1,xstyle = 1

oplot, chemheat, altsnew,thick = 3
oplot, euvheating, altsnew, thick = 3, linestyle = 1
oplot, jouleheat, altsnew, thick = 3, linestyle = 2

legend, ['Chem','EUV','Joule'],linestyle = [0,1,2], pos = [pos(2) - .2,pos(3) - .05],/norm


xrange = [0,1.1*max(temp)]
get_position, ppp, space, sizes, 1, pos, /rect
pos(0) = pos(0) + 0.05
pos(2) = pos(2) - 0.05
pos(1) = pos(1) + 0.025

plot, xrange,yrange,/nodata,pos = pos, xtitle = 'Temperature (K)', $
  ytitle = 'Altitude (km)', charsize = 1.2, ystyle = 1,/noerase
;xrange = [min([min(radcooling),min(conduction)]),max(conduction)]
xrange = [-.08,.28]
;yrange = [100,800]

oplot, temp,altsnew, thick = 3
oplot, mtemp,maltsnew, thick = 3,linestyle = 2

legend, ['GITM','MSIS'],linestyle = [0,2], pos = [pos(0) + .02,pos(3) - .05], /norm



get_position, ppp, space, sizes, 2, pos, /rect
pos(0) = pos(0) + 0.05
pos(2) = pos(2) - 0.05
pos(3) = pos(3) - 0.03

plot, xrange,yrange,/nodata,pos = pos, xtitle = 'Cooling rate (K)', $
  ytitle = 'Altitude (km)', charsize = 1.2, ystyle = 1,/noerase,xstyle = 1

oplot,-1* conduction, altsnew,thick = 3
oplot,-1* radcooling, altsnew, thick = 3, linestyle = 1
legend, ['Cond','Rad'],linestyle = [0,1], pos = [pos(2) - .2,pos(3) - .05],/norm

get_position, ppp, space, sizes, 3, pos, /rect
pos(0) = pos(0) + 0.05
pos(2) = pos(2) - 0.05
pos(3) = pos(3) - 0.03

xrange = [0,1]
plot, xrange,yrange,/nodata,pos = pos, xtitle = 'Heating Efficiency', $
  ytitle = 'Altitude (km)', charsize = 1.2, ystyle = 1,/noerase,xstyle = 1

oplot,(euvheating+chemheat)/totalabseuv, altsnew,thick = 3
;oplot,-1* radcooling, altsnew, thick = 3, linestyle = 1
;legend, ['Cond','Rad'],linestyle = [0,1], pos = [pos(2) - .2,pos(3) -
;                                                          .05],/norm


;;;;Zoom;;;;;;;;;;;;;;;;;;;;;;;;;;;;
plotdumb
get_position, ppp, space, sizes, 0, pos, /rect
pos(0) = pos(0) + 0.05
pos(2) = pos(2) - 0.05
pos(1) = pos(1) + 0.025

;xrange = [min([min(chemheat),min(euvheating),min(jouleheat)])$
;          ,max([max(chemheat),max(euvheating),max(jouleheat)])]
xrange = [-.08,.28]
yrange = [100,200]
plot, xrange,yrange,/nodata,pos = pos, xtitle = 'Heating rate (K)', $
  ytitle = 'Altitude (km)', charsize = 1.2, ystyle = 1,xstyle = 1

oplot, chemheat, altsnew,thick = 3
oplot, euvheating, altsnew, thick = 3, linestyle = 1
oplot, jouleheat, altsnew, thick = 3, linestyle = 2

legend, ['Chem','EUV','Joule'],linestyle = [0,1,2], pos = [pos(2) - .2,pos(3) - .05],/norm


xrange = [0,1.1*max(temp)]
get_position, ppp, space, sizes, 1, pos, /rect
pos(0) = pos(0) + 0.05
pos(2) = pos(2) - 0.05
pos(1) = pos(1) + 0.025

plot, xrange,yrange,/nodata,pos = pos, xtitle = 'Temperature (K)', $
  ytitle = 'Altitude (km)', charsize = 1.2, ystyle = 1,/noerase
;xrange = [min([min(radcooling),min(conduction)]),max(conduction)]
xrange = [-.08,.28]
;yrange = [100,800]

oplot, temp,altsnew, thick = 3
oplot, mtemp,maltsnew, thick = 3,linestyle = 2

legend, ['GITM','MSIS'],linestyle = [0,2], pos = [pos(0) + .02,pos(3) - .05], /norm



get_position, ppp, space, sizes, 2, pos, /rect
pos(0) = pos(0) + 0.05
pos(2) = pos(2) - 0.05
pos(3) = pos(3) - 0.03

plot, xrange,yrange,/nodata,pos = pos, xtitle = 'Cooling rate (K)', $
  ytitle = 'Altitude (km)', charsize = 1.2, ystyle = 1,/noerase,xstyle = 1

oplot,-1* conduction, altsnew,thick = 3
oplot,-1* radcooling, altsnew, thick = 3, linestyle = 1
legend, ['Cond','Rad'],linestyle = [0,1], pos = [pos(2) - .2,pos(3) - .05],/norm

get_position, ppp, space, sizes, 3, pos, /rect
pos(0) = pos(0) + 0.05
pos(2) = pos(2) - 0.05
pos(3) = pos(3) - 0.03

xrange = [0,1]
plot, xrange,yrange,/nodata,pos = pos, xtitle = 'Heating Efficiency', $
  ytitle = 'Altitude (km)', charsize = 1.2, ystyle = 1,/noerase,xstyle = 1

oplot,(euvheating+chemheat)/totalabseuv, altsnew,thick = 3
;oplot,-1* radcooling, altsnew, thick = 3, linestyle = 1
;legend, ['Cond','Rad'],linestyle = [0,1], pos = [pos(2) - .2,pos(3) - .05],/norm
closedevice


end