hmf2 = 0
  reread = 1
  binbykp = 0
  binoneseasononly = 1
  alt = 300

  if binoneseasononly then begin
     if n_elements(seas) eq 0 then seas = ''
     seas = ask('season to plot: ',seas)

     let = strmid(seas,0,1)
     let = strupcase(let)

     seas = let+strmid(seas,1)
  endif

if binbykp then begin
   filelist = file_search('*_*_*.txt')
endif else begin
   if binoneseasononly then begin
      filelist = file_search('*'+seas+'.txt')
   endif else begin
      filelist = file_search('*_*.txt')
   endelse
endelse

nfiles = n_elements(filelist)
filetypes = ['']
ftold = ' '
ntypes = 0

for ifile = 0, nfiles - 1 do begin
   fn = filelist(ifile)
   len = strpos(fn,'_')
   ft = strmid(fn,0,len)
   if ft ne ftold then begin
      filetypes = [filetypes,ft]
      ntypes = ntypes + 1
   endif
   ftold = ft
endfor
filetypes = filetypes(1:*)

display, filetypes
if n_elements(itype) eq 0 then itype = 0
itype = fix(ask('which radar to plot: ',tostr(itype)))

if binbykp then begin
   filelist = file_search(filetypes(itype)+'_*_*.txt')
endif else begin
   if binoneseasononly then begin
      filelist = file_search(filetypes(itype)+'*'+seas+'.txt')
   endif else begin
      filelist = file_search(filetypes(itype)+'*_*[^1234567890].txt')
   endelse
endelse
nfiles = n_elements(filelist)

radarfile = file_search('/bigdisk1/Gitm/Radars/'+filetypes(itype)+'*/*.txt')
rfile = radarfile(0)
nrlines = file_lines(rfile)

rdata = fltarr(nrlines,5)
rrtime = fltarr(nrlines)
rseason = strarr(nrlines)
rkp = fltarr(nrlines)

rtt = fltarr(nrlines)
close,5
openr,5,rfile
t = ''
line = 0
while not eof(5) do begin

    readf,5, t
    temp = strsplit(t,/extract)
    
    if n_elements(temp) eq 7 then begin
        temp2 = temp
        temp = fltarr(8)
        temp(0:3) = temp2(0:3)
        temp(4) = strmid(tostr(temp2(4)),0,5)
        temp(5) = strmid(tostr(temp2(4)),6)
        temp(6:7) = temp2(5:6)
    endif
    ry = fix(temp(0))
    if ry lt 2000 then ry = ry + 2000
    doy = fix(temp(1))
    if doy gt 365 then doy = doy - 365
    rseason(line) = season(doy)
    ut = float(temp(2))
    rdata(line,0) = float(temp(7))
    rdata(line,1) = float(temp(3))
    rdata(line,2) = float(temp(4))
    rdata(line,3) = float(temp(5))
    rdata(line,4) = float(temp(6))

    dt = [ry,doy,0,0,0]
    rdate = date_conv(dt,'F')
    rm = strmid(rdate,5,2)
    rd = strmid(rdate,8,2)
    rh = ut
    rmi = (ut-fix(ut))*60.
    rs = (rmi - fix(rmi))*60.
    ritime = [ry,rm,rd,fix(rh),fix(rmi),fix(rs)]
    c_a_to_r,ritime,rt
    rrtime(line) = rt

    kpt = get_kpvalue(ritime)
    case strtrim(kpt,2) of
       '0-': kpbin = 1
       '0' : kpbin = 1
       '0+': kpbin = 1
       '1-': kpbin = 1
       '1' : kpbin = 2
       '1+': kpbin = 2
       '2-': kpbin = 2
       '2' : kpbin = 3
       '2+': kpbin = 3
       '3-': kpbin = 3
       else:  kpbin = 4
    endcase 

    rkp(line) = kpbin

    rtt(line) = ritime(3)+ ritime(4)/60.+ ritime(5)/3600.

    line = line + 1

endwhile


rtt = rtt*3600.

close,5

nseasons = 4
iseasstart = 0
iseasend = 3
gseason = strarr(nfiles)
if binbykp then begin
   nindices = 4 
   lev = intarr(nfiles)
endif else begin
   nindices = 1
   lev = intarr(nfiles)
endelse

if binoneseasononly then begin
   nseasons = 1
    case seas of
      'Spring': iseasonstart = 0
      'Summer': iseasonstart = 1
      'Fall': iseasonstart = 2
      'Winter': iseasonstart = 3
   endcase
   iseasonend = iseasonstart
endif

temp = ' '
ntimesmax = 1000
gtime = intarr(nindices,nseasons,3,ntimesmax)
gdata = fltarr(nindices,nseasons,4,ntimesmax)

for ifile = 0, nfiles - 1 do begin
   fn = filelist(ifile)

   if binbykp then begin
      len = strpos(fn,'.')-1
      lev(ifile) = strmid(fn,len,1)
   endif else begin
      lev(ifile) = 1
   endelse  
   
   if binbykp then begin
      len = strpos(fn,'_')+1
      l2 = strpos(fn,'_',/reverse_search,/reverse_offset)
   endif else begin
      len = strpos(fn,'_')+1
      l2 = strpos(fn,'.',/reverse_search,/reverse_offset)
   endelse

   gseason(ifile) = strmid(fn,len,l2-len)

   if binoneseasononly then begin
      iseason = 0
   endif else begin
      case gseason(ifile) of
         'Spring': iseason = 0
         'Summer': iseason = 1
         'Fall': iseason = 2
         'Winter': iseason = 3
      endcase
   endelse
close,5
   openr, 5, fn
   readf, 5, temp
   
   itime = 0

   while not eof(5) do begin
      readf, 5, temp
      arr = strsplit(temp,/extract)
      gtime(lev(ifile)-1,iseason,*,itime) = arr(0:2)
      gdata(lev(ifile)-1,iseason,*,itime) = arr(3:*)
      itime = itime + 1
   endwhile
   ntimes = itime
close,5

endfor
gtime = gtime(*,*,*,0:ntimes-1)
gdata = gdata(*,*,*,0:ntimes-1)



title = filetypes(itype)+'_epoch.ps'
setdevice,title,'p',5,.90
if binbykp then begin
 ppp = 16
space = 0.03
ny = ppp/4.
endif else begin
   ppp = 4
   space = 0.01
   ny = ppp
endelse

pos_space, ppp, space, sizes,ny=ny


;pos0(0) = pos0(0) + .1

grtime = dblarr(ntimes)
rrdata = fltarr(ntimes,4)
for itime = 0, ntimes -1 do begin
   grtime(itime) = gtime(0,0,0,itime) *3600. + gtime(0,0,1,itime)*60. + gtime(0,0,2,itime)
   
  
endfor

gdata(*,*,0,*) = gdata(*,*,0,*) / 1.0e11
gdata(*,*,1,*) = gdata(*,*,1,*) / 1.0e11

stime = 0
etime = 24*3601.
time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn
xtickv = [0.0,21600.0,43200.0,64800.0,86400.0]
xtickn = 4

xtn=['0','06','12','18','24']
loadct,0

ifile = -1

for ilev = 0, nindices - 1 do begin
   for iseason = 0, nseasons -1  do begin
      
      ifile = ifile + 1
      get_position, ppp, space, sizes, ifile, pos, /rect
      
      if not binoneseasononly then begin
         case iseason of
            0: seas= 'Spring'
            1: seas = 'Summer' 
            2: seas = 'Fall'
            3: seas = 'Winter'
         endcase
      endif 

      for itime= 0, ntimes -1 do begin
         
         if binbykp then begin
            rlocs = where(rtt gt grtime(itime)-450 and rtt le grtime(itime)+450 and $
                          rkp eq ilev + 1 and rseason eq seas)
         endif else begin
            rlocs = where(rtt gt grtime(itime) - 450 and rtt le grtime(itime)+450 and $
                          rseason eq seas)
         endelse
         
         if rlocs(0) eq -1 then rlocs = rlocsold
         for i = 0, 1 do begin
            if n_elements(rlocs) gt 1 then begin
               rrdata(itime,i) = mean(rdata(rlocs,i+1))
               rrdata(itime,i+2) = stdev(rdata(rlocs,i+1))
            endif else begin
               rrdata(itime,i) = rdata(rlocs,i+1)
               rrdata(itime,i+2) = 0.0
            endelse
         endfor
         
         rlocsold = rlocs
      endfor
      rrdata(*,0) = rrdata(*,0)/1.0e11
      rrdata(*,2) = rrdata(*,2)/1.0e11
      if hmf2 then begin
         ivg = 2
         ivr = 1
         titl = 'H!Dm!NF!D2!N (m)'
         ytn =tostr( [100,200,300,400,500])
         ytickn = 4
         if binbykp then yrange = [100,500] else yrange = [100,500]
         ytickv = [100,200,300,400,500]
         ytn =tostr( [100,200,300,400,500])
      endif else begin
         ivg = 0
         ivr = 0
         titl = 'N!Dm!NF!D2!N (x10!U11!N)'
         ytickn = 4
         if binbykp then yrange = [0,8] else yrange = [0,10]
         ytickv = [0,2,4,6,8]
         ytn =tostr( [0,2,4,6,8,10])
      endelse
      if binbykp then begin
         if ifile lt 12 then begin
            xtickname = strarr(10) + ' '
            xtitle = ' '
         endif else begin
            xtickname = xtn
            xtitle= seas
         endelse
         
         
         if ((ifile mod 4) eq 0) then begin
            ytickname =ytn
;         !y.tickname = tostr([0,2,4,6,8])
            ytitle = 'Kp level '+tostr(ilev + 1)+'!C '+titl
         endif else begin
;         !y.tickname = ' '
            ytickname = strarr(10) + ' '
            ytitle = ' '
         endelse
      endif else begin
         
         if binoneseasononly then begin
            
            xtickname = strarr(10)+' '
            xtitle = ' '
            ytickname = ytn
            ytitle= titl
         endif else begin
            xtitle = seas
            if ifile lt 2 then begin
               xtickname = strarr(10) + ' '
            endif else begin
               xtickname = xtn
            endelse
            
            if ((ifile mod 2) eq 0) then begin
               ytickname =ytn
;         !y.tickname = tostr([0,2,4,6,8])
               ytitle = titl
            endif else begin
;         !y.tickname = ' '
               ytickname = strarr(10) + ' '
               ytitle = ' '
            endelse
         endelse
      endelse
      
      
      plot, grtime,gdata(ilev,iseason,ivg,*),pos=pos,xtickv=xtickv,xticks=xtickn,thick=3,/noerase,$
            xtickname = xtickname,ytickv=ytickv,yrange=yrange,$
            xtitle=xtitle,ytitle=ytitle,ytickname=ytickname
      errplot,grtime,gdata(ilev,iseason,ivg,*)-gdata(ilev,iseason,ivg+1,*), $
              gdata(ilev,iseason,ivg,*)+gdata(ilev,iseason,ivg+1,*),color=120
      
      loadct,39
      oplot, grtime,rrdata(*,ivr),color = 254,thick=3
      if ifile eq 3 or binoneseasononly then begin
         legend, ['GITM',strupcase(filetypes(itype))],colors =[0,254],linestyle=0,box=0,$
                 pos=[pos(2) - .2,pos(3)-.005],/norm
      endif
      loadct,0
      errplot,grtime,rrdata(*,ivr)-rrdata(*,ivr+2),rrdata(*,ivr)+rrdata(*,ivr+2),color = 120
      
      
      
      if binoneseasononly then begin
         xtitle = seas
         xtickname = xtn
         
         get_position, ppp, space, sizes, 1, pos, /rect
         

         plot, grtime,gdata(ilev,iseason,2,*),pos=pos,xtickv=xtickv,xticks=xtickn,thick=3,/noerase,$
               xtickname = xtickname,yrange=[100,500],$
               xtitle=xtitle,ytitle='HmF2'
         errplot,grtime,gdata(ilev,iseason,2,*)-gdata(ilev,iseason,2+1,*), $
                 gdata(ilev,iseason,2,*)+gdata(ilev,iseason,2+1,*),color=120
         
         loadct,39
         oplot, grtime,rrdata(*,1),color = 254,thick=3
         loadct,0
         errplot,grtime,rrdata(*,1)-rrdata(*,1+2),rrdata(*,1)+rrdata(*,1+2),color = 120



      endif
   endfor
endfor

closedevice
end
   
   
