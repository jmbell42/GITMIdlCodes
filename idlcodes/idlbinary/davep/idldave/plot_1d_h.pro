file = file_search('1DALL*.bin')
nfiles_new = n_elements(file)
if n_elements(file) eq 0 then begin
    print, "No matching files... "
    stop
endif

nfiles = nfiles_new

gitm_read_bin, file(0), data,time,nvars,vars,version

nalts = n_elements(data(0,0,0,*))
alts = reform(data(2,0,0,0:nalts-1))



k = 1.380e-23
tvar = where(vars eq 'Temperature')

mass = fltarr(5)
H = fltarr(nfiles,5,nalts)
d = fltarr(nfiles,nalts)
n = h
grad = fltarr(nfiles,5,nalts)
for ifile = 0,nfiles - 1 do begin
   gitm_read_bin, file(ifile), data,time,nvars,vars,version
   d(ifile,*) = reform(data(tvar,0,0,*))
   for ispecies = 0, 4 do begin
      n(ifile,ispecies,*) = data(4+ispecies,0,0,*)
   endfor
endfor
mass(0) = 16
mass(1) = 32
mass(2) = 28
mass(3) = 14
mass(4) = 30

amu = 1.661e-27
g = -9.5

species = strarr(5)
species(0) = 'O'
species(1) = 'O2'
species(2) = 'N2'
species(3) = 'N'
species(4) = 'NO'
logn = alog(n)

for ifile = 0, nfiles - 1 do begin
   for ispecies = 0, 4 do begin
      l1 = strpos(vars(ispecies+4),'[')
      l2 = strpos(vars(ispecies+4),']')
      
;      h(ifile,ispecies,*) = (k*d(ifile,*))/(mass(ispecies)*amu*g)
      for ialt = 2,nalts-3 do begin
         h(ifile,ispecies,ialt) = -(alts(ialt) - alts(ialt-1))/(alog(n(ifile,ispecies,ialt)/n(ifile,ispecies,iALT-1)))

      endfor
      grad(ifile,ispecies,*) = deriv(alts,logn(ifile,ispecies,*))
 endfor
endfor


setdevice, 'plot.ps','p',5,.95
loadct,39
ppp=4
space = 0.08
pos_space, ppp, space, sizes

xrange = [0,100000]
yrange = [90,600]
get_position, ppp, space, sizes, 0, pos, /rect

plot,fltarr(nalts),alts/1000.,/nodata,xrange = xrange,background=0,$
     ytitle = ytitle,yrange = yrange,pos=pos,/noerase,xtitle=xtitle,$
     ystyle=  1

cl = findgen(5)*(245/(5))+245/(5)
for ispecies = 0, 4 do begin
   oplot, h(nfiles-1,ispecies,*),alts/1000.,color = cl(ispecies),thick=3
endfor

legend,species,color=cl,box=0,pos=[pos(2)+.01,pos(3)-.01],/norm,thick=3,linestyle=0


get_position, ppp, space, sizes, 2, pos, /rect
xrange = mm(grad)
plot,fltarr(nalts),alts/1000.,/nodata,xrange = xrange,background=0,$
     ytitle = ytitle,yrange = yrange,pos=pos,/noerase,xtitle=xtitle,$
     ystyle=  1


for ispecies = 0, 4 do begin
   oplot, grad(nfiles-1,ispecies,*),alts/1000.,color = cl(ispecies),thick=3
endfor


get_position, ppp, space, sizes, 3, pos, /rect
xrange = mm(logn)
plot,fltarr(nalts),alts/1000.,/nodata,xrange = xrange,background=0,$
     ytitle = ytitle,yrange = yrange,pos=pos,/noerase,xtitle=xtitle,$
     ystyle=  1


for ispecies = 0, 4 do begin
   oplot, logn(nfiles-1,ispecies,*),alts/1000.,color = cl(ispecies),thick=3
endfor
closedevice
end