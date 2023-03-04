if n_elements(d) eq 0 then d = ''
  d = ask('directory search string (include wildcards): ',d)

  directories = file_search(d)
  print, directories

  ndirs = n_elements(directories)
  base = intarr(ndirs)

  if n_elements(f) eq 0 then f =''
  f = ask('date and time to plot (dd_hhmm, -1 for all): ',f)
  if strpos(f,'-1') ge 0 then begin
     plotall = 1 
     f1 = '1D*'
  endif else begin
     plotall = 0
     f1 = f
  endelse

  flen = strlen(d)
  if strpos(d,'*') ne -1 then flen = flen - 1

  if plotall then f1 = '1D*'
  file = file_search(directories(0)+'/*'+f1+'*')
  nfiles_new = n_elements(file)
  if n_elements(file) eq 0 then begin
     print, "No matching files... "
     stop
  endif

  if nfiles_new gt 1 then begin
     ift = 0
     type = ' '
     filetype = strarr(nfiles_new)
     for ifile = 0, nfiles_new - 1 do begin
        l1 = strpos(file(ifile),'/',/reverse_search)+1
        type = strmid(file(ifile),l1,5)
        if ifile eq 0 then filetype(0) = type
        
        if filetype(ift) ne type then begin
           ift = ift + 1
           filetype(ift) = type
        endif
     endfor
     filetype = filetype(0:ift)
     display, filetype
     if n_elements(ft) eq 0 then ft = 0
     ft = fix(ask('which filetype: ',tostr(ft)))
     whichtype = filetype(ft)
     if plotall then f1 = '*'
     files = file_search('*'+whichtype+'*'+f1+'*.bin')
     nfiles_new = n_elements(filelist_new)
;print, filelist_new
  endif

nfiles = n_elements(files)

for ifile = 0, nfiles - 1 do begin
   fn = files(ifile)
   gitm_read_bin, fn, data,time,nvars,vars,version
   
   nalts = n_elements(data(0,0,0,*))
   alts = reform(data(2,0,0,0:nalts-1))/1000.
   
   if ifile eq 0 then begin
      for ivar = 0, nvars - 1 do print, tostr(ivar),'   ', vars(ivar)
      if n_elements(nvarstoplot) eq 0 then nvarstoplot = 1
      nvarstoplot = fix(ask('number of vars to plot ',tostr(nvarstoplot)))
      
      if n_elements(nvarsold) eq 0 then nvarsold = -1
      if n_elements(var) eq 0 or nvarstoplot ne nvarsold then var = intarr(nvarstoplot)+3
      nvarsold = nvarstoplot
      vvar = intarr(nvarstoplot) - 1
      value = fltarr(nvarstoplot,nalts,ndirs)
      nmvars = 11
      mvalue = fltarr(11,nalts,ndirs)
      velvalue = fltarr(nvarstoplot,nalts,ndirs)
      species = strarr(nvarstoplot)
      tempvalue = fltarr(nalts,ndirs)
      vvelvalue = fltarr(nalts,ndirs)
      plotvel = 0
      mvars = findgen(11) + 13
      
      for ivar = 0, nvarstoplot - 1 do begin
         var(ivar) = fix(ask('variable to plot: ',tostr(var(ivar))))
         
         if strpos(vars(var(ivar)),'[') ge 0 and strpos(vars(var(ivar)),'difference') lt 0 then begin
            plotvel = 1
            l1 = strpos(vars(var(ivar)),'[')
            l2 = strpos(vars(var(ivar)),']')
            species(ivar) = strmid(vars(var(ivar)),l1+1,l2-1)
            vvar(ivar) = 3 ;where(strpos(vars,species(ivar)) ge 0 and strpos(vars,'V') ge 0 )
         endif
      endfor
   endif


mass = fltarr(nvars)
mass(4) = 16
mass(5) = 32
mass(6) = 28
mass(7) = 14
mass(8) = 30

pressure = fltarr(nvarstoplot,nalts)
dp = fltarr(nvarstoplot,nalts)
;for ivar = 0, nvarstoplot - 1 do begin
;   pressure(ivar,*) = data(15,0,0,*) * data(var(ivar),0,0,*)*1.38e-23
;   dp(ivar,*) = deriv(alts*1000.,pressure(ivar,*))/(mass(var(ivar))  *1.66e-27 * data(var(ivar),0,0,*))
;endfor

if plotall then title = 'plot_'+chopr('000'+tostr(ifile),4)+'.ps' else title='plot.ps'
setdevice, title,'p',5,.95
loadct,39
ppp=4
space = 0.08
pos_space, ppp, space, sizes

if n_elements(var) gt 1 then xtitle = 'Comparison' else xtitle = vars(var)
ytitle = 'Altitude (m)'
tempvar = where(vars eq 'Temperature')
for idir = 0, ndirs - 1 do begin
   for ivar = 0, nvarstoplot - 1 do begin
      if nfiles_new eq 1 then begin
         file = file_search(directories(idir)+'/*'+f1+'*')
      endif else begin
         file = fn
         l1 = strpos(fn,whichtype)+5
         allfile = '1DALL'+strmid(file,l1)
;         file = file_search(directories(idir)+'/'+'1DALL'+'*'+f+'*')
      

      get_1d_profile,file,var(ivar),coordinates,profile
      value(ivar,*,idir) = profile
      
      if vvar(ivar) ge 0 then begin
         get_1d_profile,file,vvar(ivar),coordinates,profile
         velvalue(ivar,*,idir) = profile
      endif

     
   endelse

   endfor

   if tempvar ge 0 then begin
      
      get_1d_profile,file,tempvar,coordinates,profile
      tempvalue(*,idir) = profile
      get_1d_profile,allfile,18,coordinates,profile
      vvelvalue(*,idir) = profile
      

   endif
endfor

if ifile eq 0 then begin
   if n_elements(dolog) eq 0 then dolog = 'n'
   dolog = ask('whether to plot log: ',dolog)
  
   
   if n_elements(mini) eq 0 then mini = 0.0
   if n_elements(maxi) eq 0 then maxi = 0.0
   mini = float(ask('minimum value to plot (0 for auto): ', tostrf(mini)))
   maxi = float(ask('maximum value to plot (0 for auto): ', tostrf(maxi)))
endif
 if dolog eq 'y' then value = alog10(value)
if mini eq 0 then minv = min(value(*,2:nalts-3,*))-.1*abs(min(value(*,2:nalts-3,*))) else minv = mini
if maxi eq 0 then maxv = max(value(*,2:nalts-3,*))+.1*abs(max(value(*,2:nalts-3,*))) $
else maxv = maxi
xrange = [minv,maxv]

root = strmid(directories(0),0,flen)

yrange = mm(alts)
;yrange(0) = 
;-------------------------
get_position, ppp, space, sizes, 0, pos, /rect

plot,fltarr(nalts),alts,/nodata,xrange = xrange,background=0,$
  ytitle = ytitle,yrange = yrange,pos=pos,/noerase,xtickname=strarr(10)+' ',xtitle=xtitle,$
     ystyle=  1,xstyle = 1

if nvars gt 1 then begin
   cl = findgen(nvarstoplot)*(245/(nvarstoplot))+245/(nvarstoplot)
   linestyle = intarr(nvarstoplot)
   if ndirs gt 1 then begin
      linestyle = indgen(ndirs)
   endif 
endif else begin
   linestyle = intarr(ndirs)
   cl = findgen(ndirs)*(245/(ndirs))+245/(ndirs)
endelse

for idir = 0, ndirs - 1 do begin
   for ivar = 0, nvarstoplot - 1 do begin
      oplot,value(ivar,*,idir),coordinates/1000.,color=cl(ivar),linestyle = linestyle(idir),$
            thick=3
   endfor
endfor

legend,vars(var),box = 0,colors=cl,pos=[pos(2)-.2,pos(3)-.01],/norm,$
       linestyle = 0,thick=3

if ndirs gt 1 then legend,directories,box=0,linestyle = linestyle,pos=[pos(2)-.2,pos(1)+.2],/norm
;-------------------------
plotm = 0
if plotm then begin
clm = findgen(nmvars)*(245/(nmvars))+245/(nmvars)
   linestyle = intarr(nmvars)
 if ifile eq 0 then begin
      if n_elements(minm) eq 0 then begin
         minm = 0
         maxm = 0
      endif
      minm = float(ask('minimum mom to plot (0 for auto): ', tostrf(minm)))
      maxm = float(ask('maximum mom to plot (0 for auto): ', tostrf(maxm)))
   endif
   if minm eq 0 then minmom = min(mvalue) else minmom = minm
   if maxm eq 0 then maxmom = max(mvalue) else maxmom = maxm
   xrange = [minmom,maxmom]
get_position, ppp, space, sizes, 2, pos, /rect

plot,fltarr(nalts),alts,/nodata,xrange = xrange,background=0,xtitle=xtitle,$
  ytitle = ytitle,yrange =yrange,pos=pos,/noerase,ystyle = 1,xstyle = 1

for idir = 0, ndirs - 1 do begin
   for mvar = 0, nmvars - 1 do begin
      oplot,mvalue(mvar,*,idir),coordinates/1000.,color=clm(mvar),linestyle = linestyle(idir),$
      thick=3
   endfor
endfor

legend,vars(mvars),box = 0,colors=clm,pos=[pos(0)+.01,pos(3)-.01],/norm,$
  linestyle = 0,thick=3

endif else begin

;yrange(0) = 100
get_position, ppp, space, sizes, 2, pos, /rect
;xrange = [-.3,.1]
plot,fltarr(nalts),alts,/nodata,xrange = xrange,background=0,xtitle=xtitle,$
  ytitle = ytitle,yrange =yrange,pos=pos,/noerase,ystyle = 1,xstyle = 1

for idir = 0, ndirs - 1 do begin
   for ivar = 0, nvarstoplot - 1 do begin
      oplot,value(ivar,*,idir),coordinates/1000.,color=cl(ivar),linestyle = linestyle(idir),$
      thick=3
   endfor
endfor

legend,vars(var),box = 0,colors=cl,pos=[pos(0)+.01,pos(3)-.01],/norm,$
  linestyle = 0,thick=3

endelse

;-------------------------
plotvel=0
if plotvel then begin
  
   
      xtitle = 'Pressure Gradient'
      xrange = [mintemp,maxtemp]
      get_position, ppp, space, sizes, 1, pos, /rect
  
    plot,fltarr(nalts),alts,/nodata,xrange = xrange,background=0,xtitle=xtitle,$
           ytitle=ytitle,pos=pos,/noerase,thick=3,ystyle=  1,xstyle = 1

      for idir = 0, ndirs - 1 do begin
         for ivar = 0, nvarstoplot - 1 do begin
            if vvar(ivar) ge 0 then begin
               oplot,dp(ivar,*),coordinates/1000.,color=cl(ivar),linestyle = linestyle(idir),$
               thick=3
            endif
            oplot,-9.8*(6372/(6372.+alts))^2,coordinates/1000.
            
         endfor
      endfor
      
      legend,[species,'Gravity'],colors = [cl,0],box=0,linestyle=0,pos = [pos(2)-.2,pos(3)-.01],/norm,thick = fltarr(nvarstoplot+1)+3
;-------------------------

   xtitle = 'Vertical Velocity'
   if n_elements(minv) eq 0 then minv = 0.0
   if n_elements(maxv) eq 0 then maxv = 0.0
   minv = float(ask('minimum value for velocity plot (0 for auto): ', tostrf(minv)))
   maxv = float(ask('maximum value for velocity plot (0 for auto): ', tostrf(maxv)))
   
if minv eq 0 then minv = min(velvalue(*,2:nalts-3,*))-.1*min(velvalue(*,2:nalts-3,*))
if maxv eq 0 then maxv = max(velvalue(*,2:nalts-3,*))+.1*max(velvalue(*,2:nalts-3,*))
xrange = [minv,maxv]
;yrange = [-
   get_position, ppp, space, sizes, 3, pos, /rect
   plot,fltarr(nalts),alts,/nodata,xrange = xrange,background=0,xtitle=xtitle,$
        yrange = yrange,pos=pos,/noerase, ytickname=strarr(10)+ ' ',xstyle = 1
   for idir = 0, ndirs - 1 do begin
      for ivar = 0, nvarstoplot - 1 do begin
         if vvar(ivar) ge 0 then begin
            oplot,velvalue(ivar,*,idir),coordinates/1000.,color=cl(ivar),linestyle = linestyle(idir),$
                  thick=3
         endif
      endfor
   endfor
   
endif


plottemp = 1
plotvvel = 1
if plottemp and tempvar ge 0 then begin
   xtitle = 'Temperature'
yrange = mm(alts)
   if ifile eq 0 then begin
      if n_elements(mint) eq 0 then begin
         mint = 0
         maxt = 0
      endif
      mint = float(ask('minimum temp to plot (0 for auto): ', tostrf(mint)))
      maxt = float(ask('maximum temp to plot (0 for auto): ', tostrf(maxt)))
   endif
   if mint eq 0 then mintemp = min(tempvalue) else mintemp = mint
   if maxt eq 0 then maxtemp = max(tempvalue) else maxtemp = maxt
   xrange = [mintemp,maxtemp]
   get_position, ppp, space, sizes, 1, pos, /rect
  
    plot,fltarr(nalts),alts,/nodata,xrange = xrange,background=0,xtitle=xtitle,$
           ytitle=ytitle,yrange = yrange,pos=pos,/noerase,$
         ystyle=  1,xstyle = 1,ytickname=strarr(10)+' '
    oplot,tempvalue,alts,color = 60,thick=3
  

if plotvvel then begin
  xtitle = 'Vertical Velocity'

   if ifile eq 0 then begin
      if n_elements(minve) eq 0 then begin
         minve = 0
         maxve = 0
      endif
      minve = float(ask('minimum vel to plot (0 for auto): ', tostrf(minve)))
      maxve = float(ask('maximum vel to plot (0 for auto): ', tostrf(maxve)))
   endif
   if minve eq 0 then minvel = min(vvelvalue) else minvel = minve
   if maxve eq 0 then maxvel = max(vvelvalue) else maxvel = maxve
   xrange = [minvel,maxvel]
   get_position, ppp, space, sizes, 3, pos, /rect
  
    plot,fltarr(nalts),alts,/nodata,xrange = xrange,background=0,xtitle=xtitle,$
           ytitle=ytitle,yrange = yrange,pos=pos,/noerase,$
         ystyle=  1,xstyle = 1,ytickname=strarr(10)+' '
    oplot,vvelvalue,alts,color = 60,thick=3
  
;-------------------------
closedevice
endif
endif
endfor
;
;setdevice,'velocity.ps','p',5,.95
;ppp = 2
;space = 0.01
;pos_space, ppp, space, sizes,ny=ppp
;get_position, ppp, space, sizes, 0, pos, /rect
;xrange = mm(data(18:23,0,0,*))
;
;plot,fltarr(nalts-4),alts,/nodata,xrange = xrange,background=0,xtitle=xtitle,$
;  ytitle = 'Velocity',yrange = [90,500],ystyle=1,pos=pos,/noerase
;for iv = 18, 23 do begin
;   oplot, data(iv,0,0,2:nalts-3),coordinates(2:nalts-3)/1000.,color=(iv-18)*40+40,thick=3
;endfor
;legend,vars(18:23),color=findgen(23-18+1)*40.+40.,box=0, pos=[pos(0)+.05,pos(3)-.05],$
;       /norm,linestyle=0
;
;
;
;    closedevice



;close,93
;openw,93,'gitm1ddata.txt'
;
;printf, 93, vars(2:*),format='(36A16)'
;printf,93,' '
; 
;for ialt = 2, nalts - 3 do begin
;   printf,93,tostrf(data(2:*,0,0,ialt)), format='(36G12.5)'
;endfor
;
;close,93

end