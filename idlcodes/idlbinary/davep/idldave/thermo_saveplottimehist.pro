if n_elements(ndirs) eq 0 then ndirs = 1
ndirs = fix(ask('number of save files to plot: ',tostr(ndirs)))

if n_elements(sfiles_old) eq 0 then sfiles_old = ' '
if n_elements(sfiles) eq 0 or sfiles_old(0) ne sfiles_old(0) then sfiles = strarr(ndirs)
for ifile = 0, ndirs - 1 do begin
    sfiles(ifile) = ask('name of save file ' + tostr(ifile+1)$
                        + ': ', sfiles(ifile))
endfor

reread = 1
if n_elements(ndirs_old) eq 0 then ndirs_old = 0

if ndirs eq ndirs_old and sfiles(0) eq sfiles_old(0) then begin
    reread = 'n'
    reread = ask('whether to re-restore files: ',reread)
    if strpos(reread,'y') ge 0 then reread = 1 else reread = 0
endif

l1 =  strpos(sfiles(0),'/')+1
l2 = strpos(sfiles(0),'.sav')-1
rdir = strmid(sfiles(0),0,l1)+'3DALL'+strmid(sfiles(0),l1,4)
filelist_t = file_search(rdir+'/3DALL*')
nfiles = n_elements(filelist_t)
itime = intarr(6,nfiles)
rtime = fltarr(ndirs,nfiles)

for ifile = 0, nfiles - 1 do begin
    itime(*,ifile) = get_gitm_time(filelist_t(ifile))
    c_a_to_r, itime, rt
    rtime(*,ifile) = rt
endfor

fn = filelist_t(0)

read_thermosphere_file, fn, nvars, nalts, nlats, nlons, $
  vars, datat, rb, cb, bl_cnt
nalts = n_elements(datat(0,0,0,*))
alt = reform(datat(2,0,0,*))/1000.0
lat = reform(datat(1,2:nlons-3,2:nlats-3,0))/!dtor

display,[vars,'NmF2','HmF2','O/N2']
if n_elements(pvar) eq 0 then pvar = 0
pvar = fix(ask('which variable to plot: ',tostr(pvar)))
if n_elements(pvarold) eq 0 then pvarold = 0
if pvarold ne pvar then reread = 1
pvarold = pvar
ndirs_old = ndirs
sfiles_old = sfiles
if reread then begin
    for ifile = 0, ndirs - 1 do begin
        print, 'Working on '+ sfiles(ifile)
        restore, sfiles(ifile)
        
        if ifile eq 0 then begin
            nfiles = n_elements(alldata(*,0,0,0))
            nvars = n_elements(alldata(0,*,0,0))
            nlons = n_elements(alldata(0,0,*,0))
            nlats = n_elements(alldata(0,0,0,*))
            
            data = fltarr(ndirs,nfiles,nlons-4,nlats-4)
            otherdata = fltarr(ndirs,nfiles,3,nlons-4,nlats-4)
        endif
        if pvar le 38 then begin
            data(ifile,*,*,*) = alldata(*,pvar,2:nlons-3,2:nlats-3)
            
        endif
        otherdata(ifile,*,*,*,*) = $
          allother(*,*,2:nlons-3,2:nlats-3)

    endfor
endif

iglb = 0
iday = 1
init = 2
ihlt = 3
iavg = 0
imin = 1
imax = 2
ist = 1


stime = rtime(0,0)
etime = max(rtime)
time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
xrange = [0,etime-stime]

pdata = fltarr(ndirs,nfiles,nlons-4,nlats-4)
case pvar of
    nvars:  pdata(*,*,*,*) = reform(otherdata(*,*,0,*,*))
    nvars+1:  pdata(*,*,*,*) = reform(otherdata(*,*,1,*,*))
    nvars+2:  pdata(*,*,*,*) = reform(otherdata(*,*,2,*,*))
    else: pdata(*,*,*,*) = data
endcase


     gavg = mean(pdata)
;     gstd = stddev(pdata)
     gmin = min(pdata,max=gmax)
                                
;Global
     done = 0
     vall = gmin
     valh = gmax
     nstds = 200
     gsdt = (gmax-gmin)/nstds
     
    lbins = fltarr(4,nstds)
    hbins = fltarr(4,nstds)
     for istd = 0, nstds - 1 do begin
         lbins(0,istd) = vall+istd*gsdt
         hbins(0,istd) = vall+istd*gsdt+gsdt
     endfor

;;;;;; Day, Night Hlat
     counts = fltarr(4,ndirs,nfiles,nstds)
     avgminmax = fltarr(3,4,ndirs,nfiles)
     diraves = fltarr(3,4,ndirs)
     for idir = 0, ndirs - 1 do begin
         for ifile = 0, nfiles - 1 do begin
             tdata = reform(pdata(idir,ifile,*,*))

             daylocs = where(sza le 30.0)
             nitlocs = where(sza ge 150.0)
             hlatlocs = where(sza ge 60.0 and sza le 120.0)

             avgminmax(iavg,1,idir,ifile) = mean(tdata(daylocs))
             avgminmax(imax,1,idir,ifile) = max(tdata(daylocs))
             avgminmax(imin,1,idir,ifile) = min(tdata(daylocs))
             avgminmax(iavg,2,idir,ifile) = mean(tdata(nitlocs))
             avgminmax(imax,2,idir,ifile) = max(tdata(nitlocs))
             avgminmax(imin,2,idir,ifile) = min(tdata(nitlocs))
             avgminmax(iavg,3,idir,ifile) = mean(tdata(hlatlocs))
             avgminmax(imax,3,idir,ifile) = max(tdata(hlatlocs))
             avgminmax(imin,3,idir,ifile) = min(tdata(hlatlocs))
             avgminmax(iavg,0,idir,ifile) = mean(tdata)
             avgminmax(imax,0,idir,ifile) = max(tdata)
             avgminmax(imin,0,idir,ifile) = min(tdata)


         endfor
         diraves(iavg,0,idir) = mean(avgminmax(iavg,0,idir,*))
         diraves(iavg,1,idir) = mean(avgminmax(iavg,1,idir,*))
         diraves(iavg,2,idir) = mean(avgminmax(iavg,2,idir,*))
         diraves(iavg,3,idir) = mean(avgminmax(iavg,3,idir,*))
         diraves(ist,0,idir) = stdev(avgminmax(ist,0,idir,*))
         diraves(ist,1,idir) = stdev(avgminmax(ist,1,idir,*))
         diraves(ist,2,idir) = stdev(avgminmax(ist,2,idir,*))
         diraves(ist,3,idir) = stdev(avgminmax(ist,3,idir,*))


     endfor
     
     daystats = [mean(avgminmax(iavg,0,*,*)),min(avgminmax(imin,0,*,*)),max(avgminmax(imax,0,*,*))]
     nitstats = [mean(avgminmax(iavg,1,*,*)),min(avgminmax(imin,1,*,*)),max(avgminmax(imax,1,*,*))]
     hlatstats =[mean(avgminmax(iavg,2,*,*)),min(avgminmax(imin,2,*,*)),max(avgminmax(imax,2,*,*))]
     
     daystd = stddev(avgminmax(iavg,0,*,*))
     nitst = stddev(avgminmax(iavg,1,*,*))
     hlatst = stddev(avgminmax(iavg,2,*,*))
         
     
     done = 0
     avgday = daystats(0)
     vallday = daystats(1)
     valhday = daystats(2)
     avgnit = nitstats(0)
     vallnit = nitstats(1)
     valhnit = nitstats(2)
     avghlat = hlatstats(0)
     vallhlat = hlatstats(1)
     valhhlat = hlatstats(2)
     
     dstd = (valhday-vallday)/(nstds)
     nstd = (valhnit-vallnit)/(nstds)
     hstd = (valhhlat-vallhlat)/(nstds)
     
     
     for istd = 0, nstds - 1 do begin
         lbins(1,istd) = vallday+istd*dstd
         lbins(2,istd) = vallnit+istd*nstd
         lbins(3,istd) = vallhlat+istd*hstd
         hbins(1,istd) = vallday+istd*dstd+dstd
         hbins(2,istd) = vallnit+istd*nstd+nstd
         hbins(3,istd) = vallhlat+istd*hstd+hstd
     endfor

     for idir = 0, ndirs - 1 do begin
          for ifile = 0, nfiles - 1 do begin
              for iregion = 0, 3 do begin
                  for ibin = 0, nstds - 1 do begin
                
                     tdata = reform(pdata(idir,ifile,*,*))
                     if iregion eq 0 then begin
                         l1 = where(sza ge 0)
                     endif 
                    if iregion eq 1 then begin
                         l1 = where(sza le 30.0)
                     endif 
                    if iregion eq 2 then begin
                         l1 = where(sza ge 150.0)
                     endif 
                    if iregion eq 3 then begin
                         l1 = where(abs(lat) ge 45)
                     endif 
 
                     locs = $
                       where(tdata(l1) ge lbins(0,ibin) $
                             and tdata(l1) lt hbins(0,ibin),count)

                     counts(iregion,idir,ifile,ibin) = count


                 endfor
             endfor
         endfor

     endfor
             

stime = rtime(0,0)
etime = max(rtime)
time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
xrange = [0,etime-stime]
loadct,0
ppp = 4
space = 0.01
pos_space, ppp, space, sizes, ny = ppp
setdevice, 'plot.ps','p',5,.95
get_position, ppp, space, sizes, 0, pos1, /rect
post = pos1
pos1(0) = pos1(0) + 0.1
pos1(2) = pos1(2)-.4

dirs = sfiles
if strmid(dirs(0),0,1) eq 'C' then names = ['Conduction 1','Conduction 2','Conduction 3']
if strmid(dirs(0),0,1) eq 'E' then names = ['Eddy 1','Eddy 2','Eddy 3']
if strmid(dirs(0),0,1) eq 'N' then names = ['N!D2!N Diss 1','N!D2!N Diss 2','N!D2!N Diss 3']
if strmid(dirs(0),0,1) eq 'O' then names = $
  ['O!D2!U+!N Recombine 1','O!D2!U+!N Recombine 2','O!D2!U+!N Recombine 3 ']
if strmid(dirs(0),0,2) eq 'ND' then names = ['NO Diffusion 1','NO Diffusion 2']
if strmid(dirs(0),0,2) eq 'NC' then names = ['NO Cooling 1','NO Cooling 2','NO Cooling 3']
if strmid(dirs(0),0,2) eq 'NO' then names = ['NO!U+!N Recombine 1','NO!U+!N Recombine 2']
if strmid(dirs(0),0,1) eq 'T' then names = ['Turbopause 1','Turbopause 2','Turbopause 3']

if pvar lt nvars then begin
    title = Vars(pvar) +' at '+tostr(alt(palt))+' km'
endif 
if pvar eq nvars then title = 'N!Dm!NF!D2!N'
if pvar eq nvars+1 then title = 'H!Dm!NF!D2!N'
if pvar eq nvars+2 then title = 'O/N!D2!N'

if pvar lt nvars then xtitle = vars(pvar)
if pvar eq nvars then xtitle = 'N!Dm!NF!D2!N (x 10!U12!N)'
if pvar eq nvars+1 then xtitle = 'H!Dm!NF!D2!N'
if pvar eq nvars+2 then xtitle = 'O/N!D2!N'
;    colors = findgen(ndirs)*254/ndirs + 254/ndirs
if ndirs eq 3 then colors = [0,60,120]
if ndirs eq 2 then colors = [0,80]

max1 = max(where(total(counts(0,0,*,*),3)/max(total(counts(0,0,*,*),3))*100. gt .2))

;xrange = [min(lbins),max(hbins)]
gminl=gmin
if pvar eq nvars then begin
    lbins = lbins/1.e12
    hbins = hbins/1.e12
    gminl =  gmin/1.e12
endif

xrange = [gminl,hbins(0,max1)]
    for iregion = 0, 3 do begin
        get_position, ppp, space, sizes, iregion, pos1, /rect
        pos1(0) = pos1(0) + 0.1
        pos1(2) = pos1(2)-.4
        yrange = mm(total(counts(iregion,*,*,*),3)/total(counts(iregion,0,*,*))*100.0)
        yrange(0) = 0
        
            if iregion eq 3  then begin
                plot, lbins(0,*),$
                  (total(counts(iregion,0,*,*),3))/total(counts(iregion,0,*,*))*100.0,$
                  /nodata,xtitle=xtitle,$
                  ytitle='% Counts (High-lat)',pos=pos1,charsize=1.2,/noerase,xrange=xrange,$
                  xstyle=1,thick=3,yrange=yrange
            endif
            if iregion eq 0 then begin
                plot, lbins(0,*),$
                  (total(counts(iregion,0,*,*),3))/total(counts(iregion,0,*,*))*100.0,$
                  /nodata,xrange=xrange,$
                  ytitle='% Counts (Global)',pos=pos1,charsize=1.2,/noerase,$
                  xtickname=strarr(10) + ' ',$
                  xstyle=1,thick=3,yrange=yrange
            endif
            if iregion eq 1 then begin
                plot, lbins(0,*),$
                  (total(counts(iregion,0,*,*),3))/total(counts(iregion,0,*,*))*100.0,$
                  /nodata,xrange=xrange,$
                  ytitle='% Counts (Day)',pos=pos1,charsize=1.2,/noerase,xtickname=strarr(10) + ' ',$
                  xstyle=1,thick=3
            endif
            if iregion eq 2 then begin
                plot, lbins(0,*),$
                  (total(counts(iregion,0,*,*),3))/total(counts(iregion,0,*,*))*100.0,$
                  /nodata,xrange=xrange,$
                  ytitle='% Counts (Night)',pos=pos1,charsize=1.2,/noerase,$
                  xtickname=strarr(10) + ' ',$
                  xstyle=1,thick=3,yrange=yrange
            endif
            
            for idir = 0, ndirs - 1 do begin
                oplot, lbins(0,*),$
                  (total(counts(iregion,idir,*,*),3))/total(counts(iregion,idir,*,*))*100.0,$
                  color = colors(idir),thick=3,linestyle=idir
            endfor
            
;            means = strarr(ndirs)
;            for idir = 0, ndirs - 1 do begin
;                means(idir) =  names(idir)+'  '+tostrf(diraves(iavg,iregion,idir))
;            endfor
;            legend,means,pos=[pos1(2) +0.02,pos1(3) - .04],$
;              /norm,/right,box=0
            if iregion eq 0 then begin
                if ndirs eq 2 then pos = [pos1(2) +0.02,pos1(3) + .04] else $
                   pos = [pos1(2)+.02,pos1(3) + .06]
                
            ;    pos = [pos1(2) +0.02,pos1(3) - .01]

                legend,names,color=colors,linestyle=indgen(ndirs),box=0,$
                  pos =pos,/norm,/right
            endif

endfor

;openw,1,'log.dat',/append
close,1
if pvar lt nvars then logname = strmid(names(0),0,2)+'_log_'+strmid(vars(pvar),0,2)+'.dat' 
if pvar eq nvars then logname = strmid(names(0),0,2)+'_log_nmf2.dat' 
if pvar eq nvars+1 then logname = strmid(names(0),0,2)+'_log_hmf2.dat' 
if pvar eq nvars+2 then logname = strmid(names(0),0,2)+'_log_on2.dat' 


openw,1,logname
for i = 0, 3 do begin
    idiruse = 0
    for idir = 0, ndirs - 2 do begin
        
        chi1 = reform((total(counts(i,1,*,*),3))/total(counts(i,1,*,*))*100.0)
        
        if idir eq 0 then idiruse = idir
        if idir eq 1 then idiruse =  2 
        if idir gt 1 then idiruse = idiruse + 1
        chi2 = reform((total(counts(i,idiruse,*,*),3))/total(counts(i,idiruse,*,*))*100.0)
        
        x2 = xsq_test(chi1,chi2,residual=residual)
        printf,1,strmid(names(0),0,4)+' - Region: '+tostr(i)+' '+$
          tostr(idiruse)+'-1 '+tostrf(x2(0))+' '+tostrf(x2(1))

    endfor

        printf,1,'Means and stdevs:'
    for idir = 0, ndirs - 1 do begin
      
        printf,1,'Directory: ',tostr(idir),' ',$
          ' Mean: '+tostrf(diraves(iavg,i,idir)) + ' Stdev: '+tostrf(diraves(ist,i,idir))
    endfor
    printf,1,' '
endfor
        
close,1

closedevice




end