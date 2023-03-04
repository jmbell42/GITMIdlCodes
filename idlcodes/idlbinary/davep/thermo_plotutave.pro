if n_elements(dir) eq 0 then dir = '.'
dir = ask('Which directory to plot: ',dir)
filelist = file_search(dir+'/*.bin')
;len = strpos(filelist(0),'_t')+2
;cmin1 = strmid(filelist(0),len+9,2)
;cmin2 = strmid(filelist(1),len+9,2)
;dt = fix(cmin2) - fix(cmin1)

if n_elements(dt) eq 0 then dt = 10
dt = fix(ask('the time between satellite files (Minutes): ',tostr(dt)))  ;Minutes
outdt = 15
nIntervals = 24*60./dt 
nInts = 24*60./outdt

hour = 0



if n_elements(read) eq 0 then read = 0
if read then begin
    reread = 'n'
    reread = ask('whether to reread: ',reread)
    if strpos(reread,'n') ge 0 then reread = 0 else reread = 1
endif else begin
    reread = 1
endelse

if reread then begin
    read = 1
    read_thermosphere_file, filelist(0) ,nvars, nalts, nlats, nlons, $
      vars, data, nBLKlat, nBLKlon, nBLK

    attime = strarr(3,nIntervals)
    asciitime = strarr(3,nInts)
    avgdata = fltarr(nvars,nIntervals)
    stddata  = fltarr(nvars,nIntervals)
    rtime = fltarr(nIntervals)

    alt = reform(data(2,0,0,2:nalts-3))/1000.0  
    
    display, alt
    if n_elements(plotalt) eq 0 then plotalt = 0
    plotalt = fix(ask('which altitude to plot (-1 for HmF2): ',tostr(plotalt)))

    for iint = 0, nIntervals - 1 do begin

    mins = tostr(fix((iint*dt) mod 60.))
    if iint ne 0 and mins eq '0' then hour = hour + 1
    hour = chopr('0'+tostr(hour),2)
    mins = chopr('0'+tostr(mins),2)
    filelist = file_search(dir+'/*t??????_'+hour+mins+'??*.bin')
    stop
    nfiles = n_elements(filelist)

    for ifile = 0, nfiles - 1 do begin
        fn = filelist(ifile)
        print, 'Working on file: ',fn
        read_thermosphere_file, fn ,nvars, nalts, nlats, nlons, $
              vars, data, nBLKlat, nBLKlon, nBLK
    
       
        alt = reform(data(2,0,0,2:nalts-3))/1000.0       
        
        if ifile eq 0 then begin
            len = strpos(fn,'_t')+2
           
            if iint eq 0 then begin
                srtime = fix([2000+fix(strmid(fn,len,2)),strmid(fn,len+2,2),strmid(fn,len+4,2),$
                              strmid(fn,len+7,2),strmid(fn,len+9,2),strmid(fn,len+11,2)])
            endif

            alldata = fltarr(nfiles,nvars)
            evar = where(vars eq '[e-]')
            ovar = where(vars eq '[O(!U3!NP)]')
            if ovar eq -1 then  ovar = where(vars eq '[O]')
            n2var = where(vars eq '[N!D2!N]')
        endif

        minalt = min(where(alt gt 200.0))
        ialth = min(where(alt ge 300.0))
        ialtl = ialth - 1
        
        ralt = (alt(ialth) - 300.0)/(alt(ialth) - alt(ialtl))
        
        nmf2 = max(data(evar,0,0,minalt+2:nalts-3),inmf2)
        inmf2 = inmf2 + minalt
        hmf2 = alt(inmf2)
;        if inmf2 ge nalts - 7 then begin
;            newalt = min(abs(alt-230),imin)
;            nmf2 = data(evar,0,0,imin+2)
;            hmf2 = 230.0
;            inmf2 = imin
;        endif

        if plotalt ne -1 then ialt = plotalt else ialt = inmf2

        for ivar = 0, nvars - 1 do begin
            alldata(ifile,ivar) = data(ivar,0,0,ialt)
            if ivar eq 0 then alldata(ifile,ivar) = nmf2
            if ivar eq 1 then alldata(ifile,ivar) = hmf2
            if ivar eq 2 then alldata(ifile,ivar) = data(ovar,0,0,ialt)/data(n2var,0,0,ialt)
        endfor
            
    endfor



    for ivar = 0, nvars - 1 do begin
        avgdata(ivar,iint) = mean(alldata(*,ivar))
        stddata(ivar,iint) = stddev(alldata(*,ivar))
    endfor

    attime(*,iint) = [hour,mins,'00']
    temptime = [srtime(0),srtime(1),srtime(2),attime(0,iint),attime(1,iint),0]
    c_a_to_r,temptime,rt
    rtime(iint) = rt
endfor

ertime = fix([2000+fix(strmid(fn,len,2)),strmid(fn,len+2,2),strmid(fn,len+4,2),$
              strmid(fn,len+7,2),strmid(fn,len+9,2),strmid(fn,len+11,2)])

c_a_to_r,srtime,stime
c_a_to_r,ertime,etime
endif

vars(0) = 'NmF2'
vars(1) = 'HmF2'
vars(2) = 'O/N2'

display, vars
if n_elements(whichvar) eq 0 then whichvar = 0
whichvar = fix(ask('which variable to plot: ',tostr(whichvar)))


if whichvar eq 0 or whichvar eq 1 then begin 
    plotradar = 'y'
    plotradar = ask("if you would like to plot the radar data also: ",plotradar)
    
    if plotradar eq 'y' then begin
        radardir = '/data6/gitm/Radars/'
        radars = file_search(radardir+'*')
        display,radars
        close,5
        if n_elements(iradarfile) eq 0 then iradarfile = 0
        iradarfile = fix(ask("radar file to plot: ",tostr(iradarfile)))
        
        radarfile = file_search(radars(iradarfile)+'/*.txt')
        if n_elements(radarfile) gt 0 then radarfile = radarfile(0)
        
        temp = ' '
        openr, 5, radarfile
        nmax = 20000
        radtime = intarr(6,nMax)
        radrtime = fltarr(nMax)
        raddata = fltarr(2,nMax)
        seasons = strarr(nMax)
        itime = 0
        while not eof(5) do begin
            readf, 5, temp
            arr = strsplit(temp,/extract)
            year = fix(arr(0))
            doy = fix(arr(1))
            
            if doy gt 365 then begin
                doy = doy - 365
                year = year + 1
            endif
            ut = float(arr(2))
            hour = fix(ut)
            min = fix((ut - hour)*60.0)
            sec = fix((((ut - hour)*60.0)-min)*60.0)
            
            if year lt 2000 then year = 2000 + year
            
            date = fromjday(year,doy)
            
            c_a_to_r,[year,date(0),date(1),hour,min,sec], rt
            radtime(*,itime) = [year,date(0),date(1),hour,min,sec]
            radrtime(itime) = rt
            
            raddata(0,itime) = arr(3)
            raddata(1,itime) = arr(4)
            seasons(itime) = season(doy)
            
            itime = itime + 1
        endwhile
        
;    locs = where(seasons eq seas)
        radtime = reform(radtime(*,0:itime-1))
        radrtime = reform(radrtime(0:itime-1))
        raddata = reform(raddata(*,0:itime-1))

  
        sloc = min(where(radrtime ge stime))
        eloc = max(where(radrtime le etime))
        
        radardata = reform(raddata(*,sloc:eloc))
        radarrtime = reform(radrtime(sloc:eloc))
        radartime = reform(radtime(*,sloc:eloc))
        
        radd = fltarr(2,nIntervals)
        radsd = fltarr(2,nIntervals)
        radt = fltarr(nIntervals)
        
        for itime = 0, nIntervals - 1 do begin
            hour = attime(0,itime)
            mins = attime(1,itime)
            lmin = mins - 7
            hmin = mins + 7
            
            if lmin lt 0 then lmin = 0
            if hmin gt 60 then hmin = 60
            
            radhours = where(radtime(3,*) eq hour)
            radmins = where(radtime(4,radhours) ge lmin and radtime(4,radhours) le hmin)
            
            radts = reform(radtime(*,radhours(radmins)))
            for ivar = 0, 1 do begin
                radd(ivar,itime) = mean(raddata(ivar,radhours(radmins)))
                radsd(ivar,itime) = stddev(raddata(ivar,radhours(radmins)))
            endfor
            
            c_a_to_r,[radtime(0),radtime(1),radtime(2),hour,mins,0],rt
            radt(itime) = rt
            
        endfor
    endif
endif else begin
    plotradar = 'n'
endelse

ppp = 4
ppp = 4
space = 0.01
pos_space, ppp, space, sizes, ny = ppp
get_position, ppp, space, sizes, 0, pos0, /rect
get_position, ppp, space, sizes, 1, pos1, /rect
pos0(0) = pos0(0) + .1
pos1(0) = pos1(0) + .1

stime2 = 0
etime2 = 24*3601.
time_axis, stime2, etime2,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
xtickv = [0.0,21600.0,43200.0,64800.0,86400.0]
xtickn = 4
xtickname=['00','06','12','18','24']
loadct,39

val = reform(avgdata(whichvar,*))
oval = reform(stddata(whichvar,*))

if plotradar eq 'y' then begin
    radval = reform(radd(whichvar,*))
    oradval = reform(radsd(whichvar,*))
endif

ytitle = vars(whichvar)
xtitle = 'UT Hours'
xrange = [0,etime2-stime2]
if plotradar eq 'y' then yrange = mm([val,radval]) else yrange = mm(val)
yrange = [.7*yrange(0),1.25*yrange(1)]

setdevice, 'plot.ps', 'p',5,.95
plot,rtime-rtime(0),val,/nodata,xrange=xrange,yrange=yrange,xstyle=1,ystyle=1,$
  xtickname=xtickname,xtickv=xtickv,xticks=xtickn,xminor=xminor,ytitle=ytitle,/noerase,$
  pos=pos0,charsize = 1.2,xtitle=xtitle

oplot, rtime - rtime(0),val,thick=3
if plotradar eq 'y'then oplot, rtime - rtime(0),radval,color = 254,thick=3

loadct,0
errplot,rtime-rtime(0),val-oval,val+oval,color=120
if plotradar eq 'y' then errplot,rtime-rtime(0),radval-oradval,radval+oradval,color=120

loadct,39

if plotradar eq 'y' then begin
legend,['GITM','ESR'],color=[0,254],box=0,linestyle=0,pos=[pos0(2)-.2,pos0(3)-.02],/norm,$
  thick=3
endif

closedevice
end


