restore,'~/idllocal/spidr_client.sav'

if n_elements(startdate) eq 0 then startdate = ' '
if n_elements(enddate) eq 0 then enddate = ' '
startdate = ask('start date (yyyymmdd): ',startdate)
enddate = ask('end date: ',enddate)

params = ['hmF2','nmF2']
display,params
if n_elements(whichpar) eq 0 then whichpar = 0
whichpar = fix(ask('which param to download: ',tostr(whichpar)))

case whichpar of
    0: par = 'hmF2'
    1: par = 'foF2'
endcase

reread = 1
if n_elements(oldpar) eq 0 then oldpar = -1
if n_elements(oldstartdate) eq 0 then oldstartdate = ' '
if n_elements(oldenddate) eq 0 then oldenddate = ' '

if n_elements(isevent) eq 0 then isevent = 'n'
isevent = ask('is this an event: ',isevent)
if isevent eq 'y' then begin
   if n_elements(eventtime) eq 0 then eventtime = ' '
   eventtime = ask('time of event (yyyymmdd hhmm): ',eventtime)
   eyear = strmid(eventtime,0,4)
   emonth = strmid(eventtime,4,2)
   eday = strmid(eventtime,6,2)
   ehour = strmid(eventtime,9,2)
   emin = strmid(eventtime,11,2)
   etime =fix([eyear,emonth,eday,ehour,emin,'0'])
   c_a_to_r,etime,ertime
endif
if whichpar eq oldpar and n_elements(value) gt 0 $
  and oldstartdate eq startdate and oldenddate eq enddate then begin
    reread = 'n'
    reread = ask('whether to reread: ',reread)
    if strpos(reread,'y') ge 0 then reread = 1 else reread = 0
endif
oldstartdate = startdate
oldenddate = enddate
oldpar = whichpar

btime = [fix(strmid(startdate,0,4)),fix(strmid(startdate,4,2)),fix(strmid(startdate,6,2)),0,0,0]
ftime = [fix(strmid(enddate,0,4)),fix(strmid(enddate,4,2)),fix(strmid(enddate,6,2)),0,0,0]
c_a_to_r,btime,stime
c_a_to_r,ftime,etime
ndays = (etime - stime)/(3600.*24)
npointsperday = 24/(15/60.)
ndatapointsmax = ndays * npointsperday
if reread then begin
spidr_get_ionostation,startdate,enddate,codes,names,coordinates
ncodes = n_elements(codes)


nmax = 10000
value = fltarr(ncodes,nmax)
rtime = dblarr(ncodes,nmax)
ntimes = intarr(ncodes)
nstations = -1
station = strarr(ncodes)
scode = strarr(ncodes)
scoords = intarr(2,ncodes)
for icode = 0, ncodes-1 do begin
   print, 'Getting data for '+names(icode)+'...'
   data = spidr_get_data(par+'.'+codes(icode),btime,ftime)
   
   if n_tags(data) gt 0 then begin
      case whichpar of
         0: maxval = 600
         1: maxval = 30
         else: maxval =1.e20
      endcase
      locs = where(data.value eq data.value and data.value lt maxval,nlocs)
      
      if nlocs gt  .2*ndatapointsmax then begin
         nstations = nstations + 1
         station(nstations) = names(icode)
         scode(nstations) = codes(icode)
         scoords(*,nstations) = coordinates(*,icode)
         ntimes(nstations) = nlocs
         value(nstations,0:nlocs-1) = data.value(locs)
         
         for itime = 0, nlocs -1 do begin
             ;jtime = data.time(locs(itime))
             ;caldat,jtime,month,day,year
             jtime = data.time_8601(locs(itime))
             year = strmid(jtime,0,4)
             month = strmid(jtime,5,2)
             day = strmid(jtime,8,2)
             hour = strmid(jtime,11,2)
             min = strmid(jtime,14,2)

             it = fix([year,month,day,hour,min,'0'])
             c_a_to_r,it,rt
;             addsecs = (jtime-floor(jtime))*24*3600.
;             rt = rt + addsecs
             rtime(nstations,itime) = rt

         endfor
      endif
   endif
endfor

ntimemax = max(ntimes)
value = value(0:nstations-1,0:ntimemax-1)
rtime = rtime(0:nstations-1,0:ntimemax-1)
ntimes = ntimes(0:nstations-1)
station = station(0:nstations-1)
scode = scode(0:nstations-1)
scoords = scoords(*,0:nstations-1)
if whichpar eq 1 then begin
   locs = where(value ge 1000 and value ge 1020,count)
   if count gt 0 then value(locs) = value(locs)/1000.
   value = 1.24e10*(value)^2/1.0e12
  
endif


display, station
if n_elements(whichstation) eq 0 then whichstation = -1
whichstation = fix(ask('which station to plot (-1 for all): ',tostr(whichstation)))

if whichstation lt 0 then begin
    nplots = nstations 
    val = value
    nt = ntimes
    rt = rtime
    iplots = findgen(nplots)
endif else begin
    nplots = 1
    iplots = 0
    val = value(whichstation,*)
    rt = rtime(whichstation,*)
    nt = ntimes(whichstation)
endelse

if n_elements(doepoch) eq 0 then doepoch = 'n'
doepoch = ask('whether to do epoch ',doepoch)
if doepoch eq 'y' then begin
   newval = fltarr(nplots,ntimemax)
   nminsinday = 24*60.

   if n_elements(eptime) eq 0 then eptime = 0
   eptime = fix(ask('epoch time ',tostr(eptime)))
   pad = eptime/2.
   
   for istation = 0, nplots -1 do begin
      temp = reform(val(istation,0:ntimes(istation)-1))
      rtt= reform(rt(istation,0:ntimes(istation)-1))
      get_epoch_average,temp,rtt,eptime,epochave,newtime,neptimes = netimes, nmins= nmins


      for itime = 0,  ntimes(istation) - 1 do begin
         c_r_to_a,ta,rtt(itime)
         findmins = ta(3)*60.+ta(4)
         if findmins gt nminsinday - pad then findmins = 0
         
         locs = where(newtime(0,*)*60.+newtime(1,*)-pad le findmins and $
                      newtime(0,*)*60.+newtime(1,*)+pad gt findmins,count)

         case count of 
            1: newval(istation,itime) = val(istation,itime) - epochave(locs)
            
            else: begin
               print, 'Error with epoch subtraction'
               stop
            end
         endcase
         
      endfor
      
   endfor

   val = newval   
endif

endif 

ppp = 9
space = 0.05
pos_space, ppp, space, sizes
if n_elements(minv) eq 0 then minv = 0.0
if n_elements(maxv) eq 0 then maxv = 0.0
minv = float(ask('minimum value to plot (0 for auto): ',tostr(minv)))
maxv = float(ask('minimum value to plot (0 for auto): ',tostr(maxv)))

if params(whichpar) eq 'nmF2' then begin
   if doepoch eq 'n' then  locs = where(value ge 0 and value lt 10) else $
      locs = where(value ge -10 and value lt 10)
endif else begin
   locs = where(value eq value)
endelse

if minv eq 0 then mini = .95*min(val(locs)) else mini = minv
if maxv eq 0 then maxi = 1.05*max(val(locs)) else maxi = maxv

yrange = [mini,maxi]

;ytickn = 4
;dy = (yrange(1)-yrange(0))/(ytickn)
;ytickname = strarr(ytickn+1)
;for i = 0, ytickn do begin
;   ytickname(i) = tostr(i*dy+yrange(0))

;endfor
;ytickv = float(ytickname);indgen(ytickn+1)*dy+yrange(0)
yminor = 3
setdevice,'plot.ps','p',5,.95
time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
len = strpos(xtitle,'Uni')-1
xtitle = strmid(xtitle,0,len)

for i = 0, xtickn do begin
   len = strlen(xtickname(i)) -2
   tstr = xtickname(i)
   xtickname(i) = strmid(tstr,len)
endfor

for iplot = 0, nplots - 1 do begin
   plotnumonpage = iplot
   while plotnumonpage gt ppp do begin
      plotnumonpage = plotnumonpage - ppp
   endwhile

    if iplot mod ppp eq 0 then plotdumb
    
    if nplots eq 1 or ((plotnumonpage mod 6 eq 0 or plotnumonpage mod 7 eq 0 or $
                        plotnumonpage mod 8 eq 0 $
                        ) and iplot ne 0) then begin
        xtn = xtickname
        xtit = xtitle

    endif else begin
        xtn = strarr(10)+' '
        xtit = ' '
    endelse
    
   
    len = strpos(xtit,'Universal')
    if len ge 0 then begin
        xtit = strmid(xtit,0,len-1)+' UT'
    endif
        
    get_position, ppp, space, sizes, iplot mod ppp, pos, /rect


    if nplots eq 1 or iplot mod 3 eq 0 then begin
       plot,rt(iplots(iplot),0:nt(iplots(iplot))-1)-stime,$
            val(iplots(iplot),0:nt(iplots(iplot))-1),/nodata,$
            xtitle=xtit,xtickname=xtn,xtickv=xtickv,xticks=xtickn,xminor=xminor,$
            xrange = [btr,etr],xstyle=1,yrange = yrange,ytitle = Params(whichpar),$
            pos = pos,/noerase,charsize=1.2,ytickname=ytn,yticks=ytickn,ytickv=ytickv,$
            yminor = yminor

    endif else begin
       
       plot,rt(iplots(iplot),0:nt(iplots(iplot))-1)-stime,$
            val(iplots(iplot),0:nt(iplots(iplot))-1),/nodata,$
            xtitle=xtit,xtickname=xtn,xtickv=xtickv,xticks=xtickn,xminor=xminor,$
            xrange = [btr,etr],xstyle=1,yrange = yrange,ytickname = strarr(10)+' ',$
            pos = pos,/noerase,charsize=1.2,yticks=ytickn,ytickv=ytickv,$
            yminor = yminor

    endelse

   

    oplot,rt(iplots(iplot),0:nt(iplots(iplot))-1)-stime,$
      val(iplots(iplot),0:nt(iplots(iplot))-1),thick=3

    if isevent eq 'y' then begin
       loadct,0
       oplot,[ertime-stime,ertime-stime],[-1e5,1e5],linestyle=2,color=150
       loadct,39
    endif
    legend,[station(iplots(iplot))],box=0,pos = [pos(0)-.01,pos(3)-.001],/norm
    legend,[tostr(scoords(0,iplots(iplot)))+'N, ' +tostr(scoords(1,iplots(iplot)))+'E'],box=0,pos = [pos(0)-.01,pos(3)-.025],/norm
    
endfor
    
closedevice

end
