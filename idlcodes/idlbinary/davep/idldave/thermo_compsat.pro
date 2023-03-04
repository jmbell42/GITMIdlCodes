pro labelvalue, btr, etr, mini, maxi, value, title

  if (strpos(title,'alog') gt -1 and strpos(title,'O/N') lt 0) then begin
      v = 10.0^value
      m = mean(v)
      s = abs(100.0 * stddev(v)/m)
      m = alog10(m)
  endif else begin
      v = value
      m = mean(v)
      s = abs(100.0 * stddev(v)/m)
  endelse

  oplot, [btr,etr], [m,m], linestyle = 2
  
  if (abs(m) lt 10000 and abs(m) gt 0.01) then begin
      ms = strcompress(string(m,format="(f8.2)"),/remove)
  endif else begin
      ms = strcompress(string(m,format="(e10.2)"),/remove)
  endelse

  sp = strpos(title,'(10')
  if (sp gt 0) then ta = strmid(title,sp,12) else ta=''
  xyouts, etr+(etr-btr)/25.0, (mini+maxi)/2, ms+ta, $
    orient=270, align=0.5,charsize = 1.2

  xyouts, etr+(etr-btr)/200.0, (mini+maxi)/2, tostr(fix(s))+"%", $
    orient=270,align=0.5,charsize = 1.2

end


GetNewData = 1
fpi = 0

if n_elements(pdir) eq 0 then pdir = ' '
pdir = ask('directory 1 ',pdir)
if n_elements(odir) eq 0 then odir = ' '
odir = ask('directory 2 ',odir)

filelist_new_p = file_search(pdir+'/*bin')
filelist_new_o = file_search(odir+'/*bin')

nfiles_new_p = n_elements(filelist_new_p)
nfiles_new_o = n_elements(filelist_new_o)


if nfiles_new_p ne nfiles_new_o then begin
   print, 'Directories are not the same size... Stopping'
   stop
endif

if nfiles_new_p gt 1 then begin
   ift = 0
   type = ' '
   filetype = strarr(nfiles_new_p)
   for ifile = 0, nfiles_new_p - 1 do begin
      l1 = strpos(filelist_new_p(ifile),'/',/reverse_search)+1
      type = strmid(filelist_new_p(ifile),l1,5)
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
      filelist_new_p = file_search(pdir+'/*'+whichtype+'*.bin')
      filelist_new_o = file_search(odir+'/*'+whichtype+'*.bin')
      nfiles_new_p = n_elements(filelist_new_p)
      nfiles_new_o = n_elements(filelist_new_o)
;print, filelist_new
   endif
if n_elements(nfiles) gt 0 then begin
    if (nfiles_new_p eq nfiles) then default = 'n' else default='y'
    GetNewData = mklower(strmid(ask('whether to reread data',default),0,1))
    if (GetNewData eq 'n') then GetNewData = 0 else GetNewData = 1
endif

if (GetNewData) then begin
    
    thermo_readsat, filelist_new_p, data_p, time, nTimes_p, Vars, nAlts, nSats, Files,version
    thermo_readsat, filelist_new_o, data_o, time, nTimes_o, Vars, nAlts, nSats, Files,version
    if ntimes_p ne ntimes_o then  begin
       print, "The number of times is not consistent between the two directories"
       print, "This is bad..."
       stop
    endif
    
    nFiles = n_elements(filelist_new_p)
endif

 pl = strmid(tostrf(version),3,1)
 if pl eq '4' then mars = 1 else mars = 0

 if mars then begin
    file = '~/idl/marsflat.jpg'
    read_jpeg, file, image
 nx = n_elements(image(0,*,0))
   ny = n_elements(image(0,0,*))
    new_image = fltarr(nx,ny)
                                ;We usually plot with 0 lon in the
                                ;middle, but the jpeg as 0 lon on the right...
    for i=nx/2, nx-1 do begin
       new_image(i-nx/2,0:ny-1)  = image(2,i,*)
       new_image(i,0:ny-1)  = image(2,i-nx/2,*)
    endfor
 endif
  nPts = nTimes_p

    Alts = reform(data_p(0,0:nPts-1,2,0:nalts-1))/1000.0
    Lons = reform(data_p(0,0:nPts-1,0,0)) * 180.0 / !pi
    Lats = reform(data_p(0,0:nPts-1,1,0)) * 180.0 / !pi

    d = Lats - Lats(0)
    if (max(abs(d)) lt 1.0) then stationary = 1 else stationary = 0

    c_r_to_a, itime, time(0)
    itime(3:5) = 0
    c_a_to_r, itime, basetime
    hour = (time/3600.0 mod 24.0) + fix((time-basetime)/(24.0*3600.0))*24.0
    localtime = (Lons/15.0 + hour) mod 24.0
    
 time2d = dblarr(nPts,nalts)
 for i=0,nPts-1 do time2d(i,*) = time(i)- time(0)
 
 display, vars
 if (n_elements(iVar) eq 0) then iVar = 3
 nVars = n_elements(Vars)

 iVar = fix(ask('variable to plot',tostr(iVar)))
 
  value = $
    reform((data_p(0,0:nPts-1,iVar,0:nalts-1) - data_o(0,0:nPts-1,iVar,0:nalts-1)) / $
          (data_o(0,0:nPts-1,iVar,0:nalts-1)))*100.0

  value_p = reform(data_p(0,0:nPts-1,iVar,0:nalts-1))
  value_o = reform(data_o(0,0:nPts-1,iVar,0:nalts-1))
  
  title = vars(ivar)


setdevice, 'test.ps', 'p', 5, 0.95

    makect, 'all'


    ppp = 8
    space = 0.01
    pos_space, ppp, space, sizes, ny = ppp
    
    stime = time(0)
    etime = max(time)
    time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn, mars
    xtitle = '2003'
;    xtitle = strmid(xtitle,0,12)

; if (strpos(nocontour,'n') lt 0) then begin


 ;  mini = min([value_p,value_o])
 ;  maxi = max([value_p,value_o])
 ;      range = (maxi-mini)
 ;      if (range eq 0.0) then range = 1.0
 ;      if (mini lt 0.0 or mini-0.1*range gt 0) then mini = mini - 0.1*range $
 ;      else mini = 0.0
 ;      maxi = maxi + 0.1*range
 ;      
 ;      mini = float(ask('minimum values for contour plot',tostrf(mini)))
 ;      maxi = float(ask('maximum values for contour plot',tostrf(maxi)))
 ;
 ;      levels = findgen(31) * (maxi-mini) / 30 + mini
 ;
 ;      get_position, ppp, space, sizes, 0, pos, /rect
 ;      pos(2) = pos(2) - 0.1
 ;      contour, value_o(*,2:nalts-3), time2d(*,2:nalts-3), Alts(*,2:nalts-3), $
 ;        /follow, /fill, $
 ;        nlevels = 30, pos = pos, levels = levels, $
 ;        yrange = [0,max(alts)], ystyle = 1, ytitle = 'Altitude (km)', $
 ;        xtickname = xtickname, xtitle = xtitle, xtickv = xtickv, $
 ;        xminor = xminor, xticks = xtickn, xstyle = 1, charsize = 1.2,/noerase
 ;      
 ;      ctpos = pos
 ;      ctpos(0) = pos(2)+0.025
 ;      ctpos(2) = ctpos(0)+0.03
 ;      maxmin = [mini,maxi]
 ;      plotct, 255, ctpos, maxmin, title, /right
 ;      
 ;      get_position, ppp, space, sizes, 1, pos, /rect
 ;      pos(2) = pos(2) - 0.1
 ;      contour, value_p(*,2:nalts-3), time2d(*,2:nalts-3), Alts(*,2:nalts-3), $
 ;        /follow, /fill, $
 ;        nlevels = 30, pos = pos, levels = levels, $
 ;        yrange = [0,max(alts)], ystyle = 1, ytitle = 'Altitude (km)', $
 ;        xtickname = xtickname, xtitle = xtitle, xtickv = xtickv, $
 ;        xminor = xminor, xticks = xtickn, xstyle = 1, charsize = 1.2,/noerase
 ;
 ;      ctpos = pos
 ;      ctpos(0) = pos(2)+0.025
 ;      ctpos(2) = ctpos(0)+0.03
 ;      maxmin = [mini,maxi]
 ;      plotct, 255, ctpos, maxmin, title, /right

        mini = min(value)
        maxi = max(value)
        range = (maxi-mini)
        if (range eq 0.0) then range = 1.0
        if (mini lt 0.0 or mini-0.1*range gt 0) then mini = mini - 0.1*range $
        else mini = 0.0
        maxi = maxi + 0.1*range

        mini = float(ask('minimum values for difference plot',tostrf(mini)))
        maxi = float(ask('maximum values for difference plot',tostrf(maxi)))

        levels = findgen(31) * (maxi-mini) / 30 + mini
 get_position, ppp, space, sizes, 4, pos1, /rect
        get_position, ppp, space, sizes, 7, pos2, /rect
        pos = [pos1(0)+0.05,pos2(1), pos1(2)-0.07,pos1(3)]
        for i = 0, xtickn do begin
           xtickname(i) = strmid(xtickname(i),0,3)
        endfor
        
        v = reform(value(*,2:nalts-3))
        l = where(v gt maxi,c)
        if (c gt 0) then v(l) = maxi
        l = where(v lt mini,c)
        if (c gt 0) then v(l) = mini
        contour, v, time2d(*,2:nalts-3), Alts(*,2:nalts-3), $
          /follow, /fill, $
          nlevels = 30, pos = pos, levels = levels, $
          yrange = [0,max(alts)], ystyle = 1, ytitle = 'Altitude (km)', $
          xtickname = xtickname, xtitle = xtitle, xtickv = xtickv, $
          xminor = xminor, xticks = xtickn, xstyle = 1, charsize = 1.3,/noerase,$
                 title='C. Percent Difference"

        title = vars(ivar) + ' Difference'
        ctpos = pos
        ctpos(0) = pos(2)+0.025
        ctpos(2) = ctpos(0)+0.03
        maxmin = [mini,maxi]
        plotct, 255, ctpos, maxmin, title, /right

; Put the max and min on the plot

        mini_tmp = min(value)
        maxi_tmp = max(value)

        r = (maxi_tmp - mini_tmp)/50.0

        if (mini_tmp gt mini) then begin
            plots, [0.0,1.0], [mini_tmp, mini_tmp], thick = 5
            plots, [1.0,0.6], [mini_tmp, mini_tmp+r], thick = 2
            plots, [1.0,0.6], [mini_tmp, mini_tmp-r], thick = 2
        endif
        if (maxi_tmp lt maxi) then begin
            plots, [0.0,1.0], [maxi_tmp, maxi_tmp], thick = 5
            plots, [1.0,0.6], [maxi_tmp, maxi_tmp+r], thick = 2
            plots, [1.0,0.6], [maxi_tmp, maxi_tmp-r], thick = 2
        endif

        if (abs(mini_tmp) lt 10000.0 and abs(mini_tmp) gt 0.01) then begin
            smin = strcompress(string(mini_tmp, format = '(f10.2)'), /remove)
        endif else begin
            smin = strcompress(string(mini_tmp, format = '(e12.3)'), /remove)
        endelse
        if (mini_tmp gt mini) then $
          xyouts, -0.1,mini_tmp, smin, align = 0.5, charsize = 0.8, orient = 90

        if (abs(maxi_tmp) lt 10000.0 and abs(maxi_tmp) gt 0.01) then begin
            smax = strcompress(string(maxi_tmp, format = '(f10.2)'), /remove)
        endif else begin
            smax = strcompress(string(maxi_tmp, format = '(e12.3)'), /remove)
        endelse
        if (maxi_tmp lt maxi) then $
          xyouts, -0.1,maxi_tmp, smax, align = 0.5, charsize = 0.8, orient = 90



    get_position, ppp, space, sizes, 3, pos1, /rect
    pos = [pos1(0)+0.05,pos1(1), pos1(2)-0.07,pos1(3)]

   
 
    closedevice



 end