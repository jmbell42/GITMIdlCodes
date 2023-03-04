filelist = file_search('3D*')
nfiles = n_elements(filelist)

if n_elements(filenameold) eq 0 then filenameold = ' '
ntypes = 1
ft = strmid(filelist(0),2,3)
ftype = [ft]
fto = ft
for ifile = 0, nfiles - 1 do begin
    ft = strmid(filelist(0),2,3)
    if ft ne fto then begin 
        ftype = [ftype,ft]
        fto = ft
        ntypes = ntypes + 1
    endif
endfor

if ntypes gt 1 then begin
    display, ftype
    if n_elements(whichtype) eq 0 then whichtype = 0
    whichtype = fix(ask('which file type: ',tostr(whichtype)))
    filelist = file_search('3D'+ftype(whichtype))
    nfiles = n_elements(filelist)
endif

display,filelist
if n_elements(fn) eq 0 then fn = 0
fn = fix(ask('which file to plot: ',tostr(fn)))
filename = filelist(fn)


 
iglb = 0
iday = 1
init = 2
ihlt = 3
iavg = 0
imin = 1
imax = 2

reread = 1
if filename eq filenameold then begin
    reread = 0
    reread = fix(ask('whether to reread: ',tostr(reread)))
endif


if reread then begin
read_thermosphere_file, filename, nvars, nalts, nlats, nlons, $
  vars, data, rb, cb, bl_cnt
alts = reform(data(2,0,0,2:nalts-3))/1000.
dataavg = get_averages(fIlename,'global,day,night,highlat')

endif
;display,vars
;if n_elements(pvar) eq 0 then pvar = 3
;pvar = fix(ask("which variable to plot: ", tostr(pvar)))

ivup = where(vars eq 'V!Dn!N(up)')
ivNO = where(vars eq 'V!Dn!N(up,NO)')
nvvars = fix(ivno(0)-ivup(0))

averages = reform(dataavg(0,0,*,ivup:ivno,*))
filenameold = filename

loadct,39
yrange = [100,200];mm(alts)
xrange = [-4,4]
setdevice,'plot.ps','p',5,.95
ppp = 4
space = 0.1
pos_space, ppp, space, sizes

get_position, ppp, space, sizes, 0, pos, /rect
plot,averages(iglb,0,*),alts,pos = pos,thick=3,charsize=1.2,xtitle='Global Ave',$
  ytitle='Altitude (km)',/noerase,yrange = yrange,ystyle =1 ,xrange= xrange
for ivar = 1, nvvars  do begin
    oplot,averages(iglb,ivar,*),alts,linestyle = ivar,thick = 3,color = 50*ivar
endfor

get_position, ppp, space, sizes, 1, pos, /rect
plot,averages(iday,0,*),alts,pos = pos,thick=3,charsize=1.2,xtitle='Day Ave',$
  ytitle=' ',/noerase,yrange = yrange,ystyle =1  ,xrange= xrange
for ivar = 1, nvvars do begin
    oplot,averages(iday,ivar,*),alts,linestyle = ivar,thick = 3,color = 50*ivar
endfor

get_position, ppp, space, sizes, 2, pos, /rect
plot,averages(init,0,*),alts,pos = pos,thick=3,charsize=1.2,xtitle='Night Ave',$
  ytitle='Altitude (km)',/noerase,yrange = yrange,ystyle =1  ,xrange= xrange
for ivar = 1, nvvars  do begin
    oplot,averages(init,ivar,*),alts,linestyle = ivar,thick = 3,color = 50*ivar
endfor

get_position, ppp, space, sizes, 3, pos, /rect
plot,averages(ihlt,0,*),alts,pos = pos,thick=3,charsize=1.2,xtitle='High-lat Ave',$
  ytitle=' ',/noerase,yrange = yrange,ystyle =1  ,xrange= xrange
for ivar = 1, nvvars  do begin
    oplot,averages(ihlt,ivar,*),alts,linestyle = ivar,thick = 3,color = 50*ivar
endfor

legend,vars(ivup:ivno),color=findgen(nvvars+1)*50,linestyle = findgen(nvvars+1),$
  box=0,pos=[.8,.95],/norm
closedevice

end
