;Should always compare...
compare = 1

if n_elements(ndirs) eq 0 then ndirs = 1
ndirs = fix(ask('number of save files to plot: ',tostr(ndirs)))
if n_elements(ndirs_old) eq 0 then ndirs_old = 0
if n_elements(sfiles) eq 0 or ndirs ne ndirs_old then sfiles = strarr(ndirs)
for ifile = 0, ndirs - 1 do begin
    sfiles(ifile) = ask('name of save file ' + tostr(ifile+1)$
                        + ': ', sfiles(ifile))
endfor

if n_elements(flarefile) eq 0 or ndirs ne ndirs_old then flarefile = strarr(ndirs)
for ifile = 0, ndirs - 1 do begin
    flarefile(ifile)  = ask('flare file '+tostr(ifile)+': ',flarefile(ifile))
endfor

reread = 1

if n_elements(sfiles_old) eq 0 then sfiles_old = ' '
if ndirs eq ndirs_old and sfiles(0) eq sfiles_old(0) then begin
    reread = 'n'
    reread = ask('whether to re-restore files: ',reread)
    if strpos(reread,'y') ge 0 then reread = 1 else reread = 0
endif

ndirs_old = ndirs
sfiles_old = sfiles
if reread then begin
    for ifile = 0, ndirs - 1 do begin
        print, 'Working on '+ sfiles(ifile)
        restore, sfiles(ifile)
        
        if ifile eq 0 then begin
            pvar = 3
            nfiles = n_elements(alldata(*,0,0,0))
            nvars = n_elements(alldata(0,*,0,0))
            nlons = n_elements(alldata(0,0,*,0))
            nlats = n_elements(alldata(0,0,0,*))
            
            data = fltarr(ndirs,nfiles,nlons-4,nlats-4)
            otherdata = fltarr(ndirs,nfiles,3,nlons-4,nlats-4)
        endif
        data(ifile,*,*,*) = alldata(*,pvar,2:nlons-3,2:nlats-3)
        otherdata(ifile,*,*,*,*) = $
          allother(*,*,2:nlons-3,2:nlats-3)
    endfor
endif

maxs = fltarr(ndirs,nfiles)
mins = fltarr(ndirs,nfiles)
maxs_t = fltarr(ndirs,nfiles)
mins_t = fltarr(ndirs,nfiles)
aves = fltarr(ndirs,nfiles)    
aves_t = fltarr(ndirs,nfiles)    
maxloc = fltarr(ndirs,nfiles)    
minloc = fltarr(ndirs,nfiles)    

if reread then begin
    if compare then begin
        if n_elements(base) eq 0 then base = ' '
        base = ask('name of base save file: ',base)
        
        restore, base
        
        basedata = reform(alldata(*,pvar,2:nlons-3,2:nlats-3))
        otherbase = allother(*,*,2:nlons-3,2:nlats-3)
        
    endif
endif

for idir = 0, ndirs - 1 do begin
    for ifile = 0, nfiles - 1 do begin
        
        maxs_t(idir,ifile) = max(data(idir,ifile,*,*),imax)
        mins_t(idir,ifile) = min(data(idir,ifile,*,*),imin)
        aves_t(idir,ifile) = mean(data(idir,ifile,*,*))
        
        if compare then begin
           
            maxs(idir,ifile) = $
              max((data(idir,ifile,*,*) - basedata(ifile,*,*))$
              /basedata(ifile,*,*)*100.0)
            mins(idir,ifile) = $
              min((data(idir,ifile,*,*) - basedata(ifile,*,*))$
              /basedata(ifile,*,*)*100.0)
            aves(idir,ifile) = $
              mean((data(idir,ifile,*,*) - basedata(ifile,*,*))$
              /basedata(ifile,*,*)*100.0)

        endif else begin
            maxs(idir,ifile) = maxs_t(idir,ifile)
            mins(idir,ifile) = mins_t(idir,ifile)
            aves(idir,ifile) = aves_t(idir,ifile)
        endelse    
        
    endfor
endfor


peak = fltarr(3,ndirs)
peakavetime = fltarr(ndirs)
for idir = 0, ndirs - 1 do begin
    peak(1,idir) = max(maxs(idir,*),imax)
    peak(0,idir) = max(aves(idir,*),iave)
    peak(2,idir) = max(mins(idir,*),imin)
    
    peakavetime(idir) = rtime(iave)
endfor

nwaves = 59
waveL = fltarr(nwaves)
waveH = fltarr(nwaves)

close,1
lowfile = '~/see/wavelow'
openr,1,lowfile
readf, 1, waveL
close,1

highfile = '~/see/wavehigh'
openr,1,highfile
readf, 1, waveH
close,1

nflarelinesmax = 10000

flareflux = fltarr(ndirs,nwaves,nflarelinesmax)
flaretime = intarr(ndirs,6,nflarelinesmax)
srtime = dblarr(ndirs,nflarelinesmax)
nlines = intarr(ndirs)
flaremax = fltarr(ndirs)
flaremaxtime = fltarr(ndirs)
for ifile = 0, ndirs - 1 do begin
    iline = 0
    start = 0 
    t = ' '
  
    close,1
    temp = fltarr(nwaves+7)
    openr,1,flarefile(ifile)

    while not start do begin
        readf,1,t
        if strpos(t,'#START') ge 0 then start = 1
    endwhile
    
    while not eof(1) do begin
        readf, 1,temp
        flaretime(ifile,*,iline) = fix(temp(0:5))
        flareflux(ifile,*,iline) = temp(7:*)
        c_a_to_r,flaretime(ifile,*,iline),rt
        srtime(ifile,iline) = rt

        iline = iline + 1
        

    endwhile
    nlines(ifile) = iline 
    close,1

   
endfor
maxline = max(nlines)
srtime = srtime(*,0:maxline -1)
flaretime = flaretime(*,*,0:maxline -1)
flareflux = flareflux(*,*,0:maxline -1)

flareenergy = fltarr(ndirs,nwaves,maxline+1)
flareenergytotal = fltarr(ndirs) 

for ifile = 0, ndirs - 1 do begin
    itime = 0
    endtime = peakavetime(ifile)
flareenergybase = fltarr(nwaves,maxline+1)
    while srtime(ifile,itime+1) le endtime do begin

        for iwave = 0, nwaves - 1 do begin

            flareenergy(ifile,iwave,itime) = $
              flareenergy(ifile,iwave,itime) + $
              0.5 *  (flareflux(ifile,iwave,itime) + flareflux(ifile,iwave,itime+1)) * $
              (srtime(ifile,itime+1) - srtime(ifile,itime))
            
            flareenergybase(iwave,itime) =  $
              flareenergybase(iwave,itime) + $
              0.5 *  (flareflux(ifile,iwave,0) + flareflux(ifile,iwave,0)) * $
              (srtime(ifile,itime+1) - srtime(ifile,itime))

        endfor

        itime = itime + 1
    endwhile

    entot = total(flareenergy(ifile,*,0:nlines(ifile)-1),2) - $
                                    total(flareenergybase(*,0:nlines(ifile)-1),1)
   
    flareenergytotal(ifile) = total(entot)
    

    flaremax(ifile) = max(flareflux(ifile,56,*),imax)
    flaremaxtime(ifile) = rtime(imax)

endfor

colors = findgen(ndirs)*254/ndirs+254/ndirs

stime = rtime(0)
etime = max(rtime)


loadct,39
ppp = 4
space = 0.01
pos_space, ppp, space, sizes, ny = ppp
setdevice, 'reaction.ps','p',5,.95

if strpos(sfiles(0),'min') ge 0 then $
len = strpos(sfiles,'min',/reverse_search,/reverse_offset) $
else len = strpos(sfiles,'.',/reverse_search,/reverse_offset)
names = strarr(ndirs)
for idir = 0, ndirs - 1 do begin
    names(idir) = strmid(sfiles(idir),0,len(idir))
endfor
time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
xrange = [0,etime-stime]

colors = findgen(ndirs)*254/ndirs + 254/ndirs
lines = fltarr(ndirs)
get_position, ppp, space, sizes, 0, pos1, /rect
post = pos1
pos1(0) = pos1(0) + 0.1
ytitle = 'Rho- Glb Avg % Diff'
yrange = mm(aves)

;plot, rtime-stime,/nodata,yrange=yrange,xrange=xrange,$
;  xtitle=xtitle,xminor=xminor,xtickname=xtickname,$
;  xticks=xtickn,xtickv=xtickv,charsize=1.2,$
;  xstyle=1,pos=pos1,/noerase,ytitle=ytitle,ystyle=8

plot, rtime-stime,/nodata,yrange=yrange,xrange=xrange,$
  xminor=xminor,xtickname=strarr(10)+'  ',$
  xticks=xtickn,xtickv=xtickv,charsize=1.2,$
  xstyle=1,pos=pos1,/noerase,ytitle=ytitle,ystyle=8

for idir = 0, ndirs - 1 do begin
    oplot,rtime-stime, aves(idir,*),color=colors(idir),thick=3,$
      linestyle=lines(idir)
endfor

legend,names,color=colors,linestyle=lines,box=0,$
  pos = [pos1(2) - .25,pos1(3) - .01],/norm


axis,yaxis=1,yrange=[0,80],ystyle=1,ytitle='Energy added at time of flare peak'

for idir = 0, ndirs - 1 do begin
   plots, peakavetime(idir)-stime, flareenergytotal(idir)/80.*10.,psym=sym(1), $
      color=colors(idir),symsize = 1.3
endfor

if compare then begin
    get_position, ppp, space, sizes, 1, pos1, /rect
    post = pos1
    pos1(0) = pos1(0) + 0.1
    ytitle = 'Rho- Max % Diff'
    yrange = mm(maxs)
    yrange = [0,30]
    ytickv=[0,5,10,15,20,25,30]
    plot, rtime-stime,/nodata,yrange=yrange,xrange=xrange,$
      xtickname=strarr(10)+' ',xminor=xminor,$
      xticks=xtickn,xtickv=xtickv,charsize=1.2,$
      xstyle=1,pos=pos1,/noerase,ytitle=ytitle,ytickv = ytickv,yticks=6,yminor=5
    
    for idir = 0, ndirs - 1 do begin
        oplot,rtime-stime, maxs(idir,*),color=colors(idir),thick=3,$
          linestyle=lines(idir)
    endfor
    
    get_position, ppp, space, sizes, 2, pos1, /rect
    post = pos1
    pos1(0) = pos1(0) + 0.1
    ytitle = 'Rho- Min % Diff'
    yrange = mm(mins)
    yrange = [-6,6]
    plot, rtime-stime,/nodata,yrange=yrange,xrange=xrange,$
      xtickname=xtickname,xtitle=xtitle,xminor=xminor,$
      xticks=xtickn,xtickv=xtickv,charsize=1.2,$
      xstyle=1,pos=pos1,/noerase,ytitle=ytitle
    
    for idir = 0, ndirs - 1 do begin
        oplot,rtime-stime, mins(idir,*),color=colors(idir),thick=3,$
          linestyle=lines(idir)
    endfor
endif


closedevice
end
