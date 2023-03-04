makesatfile = 0
  meantime = 12*60*60.

  if n_elements(date) eq 0 then date = ' '
  date = ask('beginning date of solar rotation to correlate: (yyyymmdd)',date)

  iyear2 = strmid(date,0,4)
  imonth2 = strmid(date,4,2)
  iday2 = strmid(date,6,2)

  day2 = jday(iyear2,imonth2,iday2)
  day3 = day2 + 31
  day1 = day2 - 27

  leapyear = isleapyear(iyear2)
  if leapyear then ndays = 366 else ndays = 365

  if day1 le 0 then begin
     iyear1 = iyear2 - 1
     ly = isleapyear(iyear1)
     if ly then day1 = 366 + day1 else day1 = 365 + day1
  endif else begin
    iyear1 = iyear2
endelse
    
if day3 gt ndays then begin
    day3 = day3 - ndays
    iyear3 = iyear2 + 1
endif else begin
   iyear3 = iyear2
endelse
time1 = fromjday(iyear1,day1)
imonth1 = time1(0)
iday1 = time1(1)

time3 = fromjday(iyear3,day3)
imonth3 = time3(0)
iday3 = time3(1)

nfiles = 3
files = strarr(nfiles)
files(0) = 'omni_min'+tostr(iyear1)+chopr('0'+tostr(imonth1),2)+'.save'
files(1) = 'omni_min'+tostr(iyear2)+chopr('0'+tostr(imonth2),2)+'.save'
files(2) = 'omni_min'+tostr(iyear3)+chopr('0'+tostr(imonth3),2)+'.save'

if files(0) eq files(1) then begin
   nfiles = nfiles - 1
   files = files(1:2)
endif else begin
   if files(1) eq files(2) then begin
      nfiles = nfiles - 1
      files = files(0:1)
   endif 
   endelse

if n_elements(vars) eq 0 then begin
   reread = 1 
endif else begin
   reread = 'n'
   reread = ask('whether to reread files: ',reread)
   if strpos(reread, 'y') ge 0 then reread = 1 else reread = 0
endelse

if reread then begin
print, 'Reading files...'
   vars = ['Vx','Vy','Vz','Bx','By','Bz'];,'IMF Clock Angle','|Bz|','Bt','dPhi_mp/dt','Rho']
nvars = n_elements(vars)
ntimesmax = 150000
data = fltarr(nvars,ntimesmax)
rtime = dblarr(ntimesmax)

ntold = 0
nttotal = 0
for ifile = 0, nfiles-1 do begin
   restore,files(ifile)
   nt = n_elements(time)
   nttotal = nttotal + nt
   rtime(ntold:nttotal-1) = time
   data(0:2,ntold:nttotal-1) = velocity
if nvars gt 3 then begin
   data(3:5,ntold:nttotal-1) = magnetic
   cangle = atan(magnetic(1,*)/magnetic(2,*))*180/!pi
   locs = where(cangle lt 0)
   cangle(locs) = 360 + cangle(locs)
endif
   if nvars gt 6 then begin
   data(6,ntold:nttotal-1) = cangle;atan(magnetic(1,*)/magnetic(2,*))*180/!pi
   data(7,ntold:nttotal-1) = abs(magnetic(2,*))
   data(8,ntold:nttotal-1) = sqrt(magnetic(0,*)^2+magnetic(1,*)^2+magnetic(2,*)^2)
   data(9,ntold:nttotal-1) = sqrt(velocity(0,*)^2+velocity(1,*)^2+velocity(2,*)^2)^(4/3.) * $
                             (sqrt(magnetic(0,*)^2+magnetic(1,*)^2+magnetic(2,*)^2))^(2/3.) * $
                             (abs(sin(cangle*!pi/180/2.)))^(8/3.)
   data(10,ntold:nttotal-1) = density
endif
   ntold = nttotal
;sqrt(velocity(0,0)^2+velocity(1,0)^2+velocity(2,0)^2)^(4/3.) * $
;                             sqrt(magnetic(0,0)^2+magnetic(1,0)^2+magnetic(2,0)^2)^(2/3.) 0 $
;                             sin(atan(magnetic(1,0)/magnetic(2,0))/2.)^(8/3.)

endfor


data = data(*,0:nttotal-1)
rtime = rtime(0:nttotal-1)
locs = where(data(0,*) lt 99990) 
itimearr = intarr(6,nttotal)
for itime = 0L, nttotal - 1 do begin
   c_r_to_a, ta, rtime(itime)
   itimearr(*,itime) = ta
endfor
data = data(*,locs)
rtime = rtime(locs)

itimearr1 = [iyear1,imonth1,iday1,0,0,0]
itimearr2 = [iyear2,imonth2,iday2,0,0,0]
itimearr3 = [iyear3,imonth3,iday3,0,0,0]

c_a_to_r,itimearr1,rt1
c_a_to_r,itimearr2,rt2
c_a_to_r,itimearr3,rt3

locs = where(rtime ge rt1 and rtime le rt3)
data = data(*,locs)
rtime = rtime(locs)

locs = where(rtime ge rt2)
data_current = data(*,locs)
t_current = rtime(locs)
ttotal = rt3-rt2
locs = where(rtime ge rt1 and rtime lt rt1+ttotal )
datatemp = data(*,locs)
ttemp = rtime(locs)

nt = n_elements(t_current)
;solrot = 27.2753*24*3600.
solrot = 26.24*24*3600.

data_previous = fltarr(nvars,nt)
t_previous = dblarr(nt)
for itime = 0L, nt - 1 do begin
   rt = t_current(itime) - solrot
   mint = min(abs(rt - ttemp),im)
   
   if abs(rt - ttemp(im)) ge 3600/50. then begin
      t_previous(itime) = -99999. 
   endif else begin
      t_previous(itime) = ttemp(im)
      data_previous(*,itime) = datatemp(*,im)
   endelse

endfor

locs = where(t_previous gt 0)
t_previous = t_previous(locs)
t_current = t_current(locs)
data_previous = data_previous(*,locs)
data_current = data_current(*,locs)

if nvars gt 3 then begin
   locs = where(data_previous(3,*) gt -100 and data_previous(3,*) lt 100 $
                and data_current(3,*) gt -100 and data_current(3,*) lt 100)
   t_previous = t_previous(locs)
   t_current = t_current(locs)
   data_previous = data_previous(*,locs)
   data_current = data_current(*,locs)
endif

if nvars gt 6 then begin
locs = wherE(data_previous(9,*) eq data_previous(9,*) and $
             data_current(9,*) eq data_current(9,*))

t_previous = t_previous(locs)
t_current = t_current(locs)
data_previous = data_previous(*,locs)
data_current = data_current(*,locs)
endif
endif


ctime = ceil(meantime / 2.)
ntimes = n_elements(t_current)
s_previous = fltarr(nvars,ntimes)
s_current = fltarr(nvars,ntimes)



for itime = 0L, ntimes -1 do begin
   time = t_current(itime)
   if (time - t_current(0) ge ctime and $
       t_current(ntimes-1) - time ge ctime) then begin
      
      locs = where(t_current ge time-ctime and t_current lt time+ctime)
      for itype = 0, nvars - 1 do begin
         s_previous(itype,itime) = mean(data_previous(itype,locs))
         s_current(itype,itime) = mean(data_current(itype,locs))
      endfor
   endif
   
   if (time - t_current(0) lt  ctime) then begin
      
      locs = where(time ge t_current(0) and time lt t_current(0) + ctime)
      for itype = 0, nvars - 1 do begin
         s_previous(itype,itime) = mean(data_previous(itype,locs))
         s_current(itype,itime) = mean(data_current(itype,locs))
      endfor
   endif

   if (t_current(ntimes - 1) - time lt ctime ) then begin
        
      locs = where(time le t_current(ntimes-1) and time gt t_current(ntimes-1) - ctime)
      for itype = 0, nvars - 1 do begin
         s_previous(itype,itime) = mean(data_previous(itype,locs))
         s_current(itype,itime) = mean(data_current(itype,locs))
      endfor

   endif
endfor
;----------------------------------------------------------------------------------------
correlation = fltarr(nvars)
rms = fltarr(nvars)
for idata = 0, nvars-1 do begin
correlation(idata) = c_correlate(data_current(idata,*),data_previous(idata,*),0)
rms(idata) = sqrt(mean((data_current(idata,*)-data_previous(idata,*))^2))/sqrt(mean((data_previous(idata,*))^2))
endfor
s_correlation = fltarr(nvars)
s_rms = fltarr(nvars)
for idata = 0, nvars-1 do begin
s_correlation(idata) = c_correlate(s_current(idata,*),s_previous(idata,*),0)
s_rms(idata) = sqrt(mean((s_current(idata,*)-s_previous(idata,*))^2))/sqrt(mean((s_previous(idata,*))^2))
endfor

  ppp = nvars
  space = 0.01
  pos_space, ppp, space, sizes, ny = ppp
  
  stime = t_current(0)
  etime = max(t_current)
  time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn

loadct,39
  setdevice,'plot.ps','p',5,.95
  for itype = 0, nvars-1 do begin
get_position, ppp, space, sizes, itype, pos, /rect
pos(2) = pos(2) - .1
pos(0) = pos(0) +.02
if itype lt nvars-1 then begin
   if itype eq 0 then begin
      plot,t_current-stime,data_current(itype,*),pos = pos,ytitle = vars(itype),/noerase,$
           xtickname = strarr(10)+' ',title = 'Raw SW and IMF comparison: '+ $
           tostr(iyear2)+'/'+chopr('0'+tostr(imonth2),2)+'/'+chopr('0'+tostr(iday2),2),$
           charsize = 1.3,xrange = xrange,xtickv=xtickv,xticks=xtickn,xminor=xminor,$
           xstyle=1
   endif else begin
      plot,t_current-stime,data_current(itype,*),pos = pos,ytitle = vars(itype),/noerase,$
           xtickname = strarr(10)+' ',$
           charsize = 1.3,xrange = xrange,xtickv=xtickv,xticks=xtickn,xminor=xminor,$
           xstyle=1
   endelse
endif else begin
   plot,t_current-stime,data_current(itype,*),pos = pos,ytitle = vars(itype),/noerase,$
        xtickname=xtickname,xtitle=xtitle,xtickv=xtickv,xticks=xtickn,xminor=xminor,$
           charsize = 1.3
endelse
oplot,t_current-stime,data_previous(itype,*),color = 220
xyouts,pos(2)+.01,pos(3)-.06,'P!DXY!N:  '+tostrf(correlation(itype)),/norm
;xyouts,pos(2)+.01,pos(3)-.08,'NRMS:  '+tostrf(rms(itype)),/norm

endfor
closedevice

;----------------

 setdevice,'splot.ps','p',5,.95
xrange = [0,etime-stime]
  time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
  for itype = 0, nvars-1 do begin
get_position, ppp, space, sizes, itype, pos, /rect
pos(0) = pos(0) +.02
;pos(2) = pos(2) - .1

if itype le nvars - 2 then begin
   if itype eq 0 then begin
      plot,t_current-stime,s_current(itype,*),pos = pos,ytitle = vars(itype),/noerase,$
           xtickname = strarr(10)+' ',thick=3,title = tostr(meantime/60.)+$
           ' minute smoothed SW and IMF comparison: '+ $
           tostr(iyear2)+'/'+chopr('0'+tostr(imonth2),2)+'/'+chopr('0'+tostr(iday2),2),$
           charsize = 1.3,xrange = xrange,xtickv=xtickv,xticks=xtickn,xminor=xminor,$
           xstyle=1

   endif else begin
      plot,t_current-stime,s_current(itype,*),pos = pos,ytitle = vars(itype),/noerase,$
          thick=3, xtickname = strarr(10)+' ',$
           charsize = 1.3,xtickv=xtickv,xticks=xtickn,xminor=xminor,xrange = xrange
   endelse
endif else begin
   plot,t_current-stime,s_current(itype,*),pos = pos,ytitle = vars(itype),/noerase,$
        xtickname=xtickname,xtitle=xtitle,xtickv=xtickv,xticks=xtickn,xminor=xminor,$
        thick=3,$
           charsize = 1.3,xrange = xrange$
           xstyle=1
endelse
oplot,t_current-stime,s_previous(itype,*),color = 220,thick=3

;     xyouts,pos(2)+.01,pos(3)-.06,'P!DXY!N: '+tostrf(s_correlation(itype)),/norm
;     xyouts,pos(2)+.01,pos(3)-.08,'NRMS:  '+tostrf(s_rms(itype)),/norm
  endfor
  closedevice
close,1
if makesatfile then begin
   ; Unshifted

    for iday = 2, 25 do begin
      doy = jday(iyear2,imonth2,fix(iday2)+(iday))
      id = fromjday(iyear2,doy)
      
      doyo = jday(iyear2,imonth2,fix(iday2)+iday-1)
      ido = fromjday(iyear2,doyo)

      openw,1,'imf_'+iyear2+chopr('0'+tostr(ido(0)),2)+chopr('0'+tostr(ido(1)),2)+'.dat'
      printf, 1, 'Data taken from omni data set and processed using carrington rotation shift'
      printf, 1, '#START'
      
      it1 = [iyear2,ido(0),ido(1),0,0,0]
      it2 = [iyear2,id(0),id(1),0,0,0]
      c_a_to_r,it1,rt1
      c_a_to_r,it2,rt2
      locs = where(t_current ge rt1 and t_current lt rt2)
      time = t_current(locs)
      newdata = data_previous(*,locs)
      nts = n_elements(time)

      if nvars gt 6 then begin
      for itime = 0, nts - 1 do begin
         c_r_to_a,ta,time(itime)
         vtotal = (newdata(0,itime)^2+newdata(1,itime)^2+newdata(2,itime)^2)^(1/2.)
         printf,1,ta,0,newdata(3:5,itime),newdata(0:2,itime),newdata(10,itime),vtotal, $
                format = '(7I,8F9.3)'
      endfor
      endif
      close,1      
   endfor

    ; Shifted up
for iday = 2, 25 do begin
      doy = jday(iyear2,imonth2,fix(iday2)+(iday))
      id = fromjday(iyear2,doy)
      
      doyo = jday(iyear2,imonth2,fix(iday2)+iday-1)
      ido = fromjday(iyear2,doyo)

      openw,1,'imf_'+iyear2+chopr('0'+tostr(ido(0)),2)+chopr('0'+tostr(ido(1)),2)+'times1.5.dat'
      printf, 1, 'Data taken from omni data set and processed using carrington rotation shift'
      printf, 1, '#START'
      
      it1 = [iyear2,ido(0),ido(1),0,0,0]
      it2 = [iyear2,id(0),id(1),0,0,0]
      c_a_to_r,it1,rt1
      c_a_to_r,it2,rt2
      locs = where(t_current ge rt1 and t_current lt rt2)
      time = t_current(locs)
      newdata = data_previous(*,locs) * 1.5
      nts = n_elements(time)

      for itime = 0, nts - 1 do begin
         c_r_to_a,ta,time(itime)
         vtotal = (newdata(0,itime)^2+newdata(1,itime)^2+newdata(2,itime)^2)^(1/2.)
         printf,1,ta,0,newdata(3:5,itime),newdata(0:2,itime),newdata(10,itime),vtotal, $
                format = '(7I,8F9.3)'
      endfor
      close,1      
   endfor

 ; Shifted down
for iday = 2, 25 do begin
      doy = jday(iyear2,imonth2,fix(iday2)+(iday))
      id = fromjday(iyear2,doy)
      
      doyo = jday(iyear2,imonth2,fix(iday2)+iday-1)
      ido = fromjday(iyear2,doyo)

      openw,1,'imf_'+iyear2+chopr('0'+tostr(ido(0)),2)+chopr('0'+tostr(ido(1)),2)+'div1.5.dat'
      printf, 1, 'Data taken from omni data set and processed using carrington rotation shift'
      printf, 1, '#START'
      
      it1 = [iyear2,ido(0),ido(1),0,0,0]
      it2 = [iyear2,id(0),id(1),0,0,0]
      c_a_to_r,it1,rt1
      c_a_to_r,it2,rt2
      locs = where(t_current ge rt1 and t_current lt rt2)
      time = t_current(locs)
      newdata = data_previous(*,locs) / 1.5
      nts = n_elements(time)

      for itime = 0, nts - 1 do begin
         c_r_to_a,ta,time(itime)
         vtotal = (newdata(0,itime)^2+newdata(1,itime)^2+newdata(2,itime)^2)^(1/2.)
         printf,1,ta,0,newdata(3:5,itime),newdata(0:2,itime),newdata(10,itime),vtotal, $
                format = '(7I,8F9.3)'
      endfor
      close,1      
   endfor

 ; Shifted right
for iday = 2, 25 do begin
      doy = jday(iyear2,imonth2,fix(iday2)+(iday))
      id = fromjday(iyear2,doy)
      
      doyo = jday(iyear2,imonth2,fix(iday2)+iday-1)
      ido = fromjday(iyear2,doyo)

      openw,1,'imf_'+iyear2+chopr('0'+tostr(ido(0)),2)+chopr('0'+tostr(ido(1)),2)+'up12.dat'
      printf, 1, 'Data taken from omni data set and processed using carrington rotation shift'
      printf, 1, '#START'
      
      it1 = [iyear2,ido(0),ido(1),0,0,0]
      it2 = [iyear2,id(0),id(1),0,0,0]
      c_a_to_r,it1,rt1
      c_a_to_r,it2,rt2
      locs = where(t_current  ge rt1 + 12*3600.  and t_current lt rt2+12*3600.)
      time = t_current(locs) - 12*3600.
if iday eq 26 then stop
      newdata = data_previous(*,locs)
      nts = n_elements(time)

      for itime = 0, nts - 1 do begin
         c_r_to_a,ta,time(itime)
         vtotal = (newdata(0,itime)^2+newdata(1,itime)^2+newdata(2,itime)^2)^(1/2.)
         printf,1,ta,0,newdata(3:5,itime),newdata(0:2,itime),newdata(10,itime),vtotal, $
                format = '(7I,8F9.3)'
      endfor
      close,1      
   endfor

; Shifted left
for iday = 2, 25 do begin
      doy = jday(iyear2,imonth2,fix(iday2)+(iday))
      id = fromjday(iyear2,doy)
      
      doyo = jday(iyear2,imonth2,fix(iday2)+iday-1)
      ido = fromjday(iyear2,doyo)

      openw,1,'imf_'+iyear2+chopr('0'+tostr(ido(0)),2)+chopr('0'+tostr(ido(1)),2)+'down12.dat'
      printf, 1, 'Data taken from omni data set and processed using carrington rotation shift'
      printf, 1, '#START'
      
      it1 = [iyear2,ido(0),ido(1),0,0,0]
      it2 = [iyear2,id(0),id(1),0,0,0]
      c_a_to_r,it1,rt1
      c_a_to_r,it2,rt2
      locs = where(t_current  ge rt1 - 12*3600.  and t_current lt rt2-12*3600.)
      time = t_current(locs) + 12*3600.
      newdata = data_previous(*,locs)
      nts = n_elements(time)

      for itime = 0, nts - 1 do begin
         c_r_to_a,ta,time(itime)
         vtotal = (newdata(0,itime)^2+newdata(1,itime)^2+newdata(2,itime)^2)^(1/2.)
         printf,1,ta,0,newdata(3:5,itime),newdata(0:2,itime),newdata(10,itime),vtotal, $
                format = '(7I,8F9.3)'
      endfor
      close,1      
   endfor
endif

end
