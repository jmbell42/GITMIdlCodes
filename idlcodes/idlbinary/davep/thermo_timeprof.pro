GetNewData = 1
plotall = 1
plotenergy = 1

files = file_search('3DALL*')
nfiles_new = n_elements(files)

if n_elements(nfiles) eq 0 then nfiles = 0
if nfiles_new ne nfiles then getnewdata = 1 else getnewdata = 0
if getnewdata eq 0 then begin
    GetNewData = fix(ask('whether to get new data: ',tostr(GetNewData)))
endif
nfiles = nfiles_new

if GetNewData eq 1 then begin
itimearr = intarr(6,nfiles)
rtime = fltarr(nfiles)
  for ifile = 0, nfiles - 1 do begin
      fn = files(ifile)
      print, 'Reading file ',fn
      
      read_thermosphere_file, fn, nvarst, nalts, nlats, nlons, $
        vars, data, rb, cb, bl_cnt
      
      if ifile eq 0 then alldata = fltarr(nfiles,nvarst,nlons,nlats,nalts)
      
      alldata(ifile,*,*,*,*) = data
      itimearr(*,ifile) = get_gitm_time(fn)
      c_a_to_r,itimearr(*,ifile),rt
      rtime(ifile) = rt
      alts = reform(data(2,0,0,*))/1000.
      lons = reform(data(0,*,0,0))/!dtor
      lats = reform(data(1,0,*,0))/!dtor
      
  endfor

endif


for ivar = 0, nvarst - 1 do print, tostr(ivar)+'  '+vars(ivar)

if n_elements(pvar) eq 0 then pvar = -1
pvar = fix(ask('which variable to plot (-1 for all):  ',tostr(pvar)))
if pvar eq -1 then nvars = nvarst -3 else nvars = 1
enervars = [3,5,10]
glbavg = fltarr(nfiles,nvars,nalts-4)
re = 6378.

for ifile = 0, nfiles - 1 do begin
for ivar = 0, nvars - 1 do begin

if nvars gt 1 then wv = 3+ivar else wv = pvar


    for ialt = 2, nalts - 3 do begin
        celltot = 0
        for ilon = 1, nlons - 3 do begin
            for ilat = 1, nlats - 3 do begin
                
                latavg = (lats(ilat)+lats(ilat+1))/2.
                cellvol = ((re+alts(ialt))^2*abs(sin(latavg*!dtor))*(alts(ialt+1)-alts(ialt)) * $
                           (lats(ilat+1)-lats(ilat))*!dtor * (lons(ilon+1)-lons(ilon))*!dtor)
                glbavg(ifile,ivar,ialt-2) = glbavg(ifile,ivar,ialt-2) + $
                  (alldata(ifile,wv,ilon,ilat,ialt) * cellvol)
                celltot = celltot+cellvol
            endfor
        endfor
        
        totvol = 4/3.*!pi*((re+alts(ialt+1))^3 - (re+alts(ialt))^3)
        glbavg(ifile,ivar,ialt-2) = glbavg(ifile,ivar,ialt-2)/celltot
        
    endfor
endfor
endfor

stime = rtime(0)
etime = max(rtime)
time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
loadct, 39

;plotcolors = findgen(ndirs)*(254-10)/(nd-1.)+10


yrange = [100,600]
xrange = mm(glbavg)

ppp = 2
space = 0.05
pos_space, ppp, space, sizes,ny=ppp
get_position, ppp, space, sizes, 0, pos0, /rect
get_position, ppp, space, sizes, 1, pos1, /rect

!p.charsize = 1.3

proftitle = 'profile.ps'

setdevice, proftitle,'p',5,.95

colors = 254*indgen(nfiles)/nfiles + 254/nfiles
palt = 20

plot, xrange, yrange,/nodata,color = 1, background = 255, xrange = xrange, $
  yrange = yrange,charsize = 1.3,$
  xstyle=1, ystyle=1,pos = pos0,/noerase

for ifile = 0, nfiles - 1 do begin
    oplot,glbavg(ifile,0,*), $
      alts,thick = 3,color = colors(ifile)
endfor
yrange = mm(glbavg(*,0,palt))
plot,rtime-stime,/nodata,xrange = [0,etime-stime],xtitle=xtitle,xtickv=xtickv,xtickn=xticks,$
  xminor=xminor,pos=pos1,/noerase,yrange = yrange
for ifile = 0,nfiles - 1 do begin
    plots,rtime(ifile)-stime,glbavg(ifile,0,palt),psym = sym(1),symsize = 2,color=colors(ifile)
endfor

xyouts,pos0(2) - .2,pos0(3)+.02,'Global Average',/norm

closedevice




end