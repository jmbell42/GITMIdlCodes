if n_elements(dir) eq 0 then dir = ' '
dir = ask('perturbation directory: ',dir)

if n_elements(dir_base) eq 0 then dir_base = ' '
dir_base = ask('base directory: ',dir_base)

files = file_search(dir+'/3DALL*')
files_base = file_search(dir_base+'/3DALL*')

nfiles = n_elements(files)
nfilesbase = n_elements(files_base)

if nfiles ne nfilesbase then begin
    print, 'Perturbation and base directory are not the same size...'
    print, 'Stopping...'
    stop
endif


display,files
if n_elements(ifilep) eq 0 then ifilep = -1
ifilep = fix(ask('perturbation filename to plot (-1 for all)',tostr(ifilep)))
if ifilep ne -1 then begin
   files = files(ifilep)
   files_base = files_base(ifilep)
   nfiles = 1 
   nfilesbase = 1
endif

for ifile = 0, nfiles - 1 do begin

    filelist = files(ifile)
    filelist_base = files_base(ifile)

    print, 'Working on '+ filelist
read_thermosphere_file, filelist, nvars, nalts, nlats, nlons, $
                        vars, data, rb, cb, bl_cnt,time,version

pl = strmid(tostrf(version),2,1)
if pl eq '4' then mars = 1 else mars = 0
read_thermosphere_file, filelist_base, nvars_base, $
  nalts_base, nlats_base, nlons_base, vars_base, data_base, $
  rb_base, cb_base, bl_cnt_base



filename = filelist(0)

alt = reform(data(2,*,*,*)) / 1000.0
lat = reform(data(1,*,*,*)) / !dtor
lon = reform(data(0,*,*,*)) / !dtor

 if (strpos(filename,"save") gt 0) then begin
                
         fn = findfile(filename)
         if (strlen(fn(0)) eq 0) then begin
             print, "Bad filename : ", filename
             stop
         endif else filename = fn(0)
         
         l1 = strpos(filename,'.save')
         fn2 = strmid(filename,0,l1)
         len = strlen(fn2)
         l2 = l1-1
         while (strpos(strmid(fn2,l2,len),'.') eq -1) do l2 = l2 - 1
         l = l2 - 13
         year = fix(strmid(filename,l, 2))
         mont = fix(strmid(filename,l+2, 2))
         day  = fix(strmid(filename,l+4, 2))
         hour = float(strmid(filename, l+7, 2))
         minu = float(strmid(filename,l+9, 2))
         seco = float(strmid(filename,l+11, 2))
     endif else begin
        l1 = strpos(filename,'.bin')
        l2 = 13
        l = l1 - l2
         year = fix(strmid(filename,l, 2))
         mont = fix(strmid(filename,l+2, 2))
         day  = fix(strmid(filename,l+4, 2))
         hour = float(strmid(filename,l+7, 2))
         minu = float(strmid(filename,l+9, 2))
         seco = float(strmid(filename,l+11, 2))
     endelse
     
     if year lt 50 then iyear = year + 2000 else iyear = year + 1900
     stryear = strtrim(string(iyear),2)
     strmth = strtrim(string(mont),2)
     strday = strtrim(string(day),2)
     uttime = hour+minu/60.+seco/60./60.
    
     strdate = stryear+'-'+strmth+'-'+strday
     strdate = strdate(0)
     
shift = 0
if shift then begin
    print, 'WARNING ------ SHIFTING LATITUDES!!!!!!!!!'
    tempdata = data
    for ilon = 2, nlons - 6 do begin
        tempdata(3:*,ilon,*,*) = data_base(3:*,ilon+3,*,*)
    endfor
        tempdata(3:*,nlons-5,*,*) = data_base(3:*,2,*,*)
        tempdata(3:*,nlons-4,*,*) = data_base(3:*,3,*,*)
        tempdata(3:*,nlons-3,*,*) = data_base(3:*,4,*,*)

        data_base(3:*,*,*,*) = tempdata(3:*,*,*,*)
    endif

    if ifile eq 0 then begin
        for i=0,nvars-1 do print, tostr(i)+'. '+vars(i)
        
        if n_elements(sel) eq 0 then sel = 3
        sel = fix(ask('which var to plot',tostr(sel)))
        
; cursor position variables, which don't matter at this point
        cursor_x = 0.0
        cursor_y = 0.0
        strx = '0.0'
        stry = '0.0'
        
        print, '1. Constant Altitude Plot'
        print, '2. Constant Longitude Plot'
        print, '3. Constant Latitude Plot'
        if n_elements(slice) eq 0 then slice = 1
        slice = fix(ask('type of plot to make',tostr(slice)))
        
        cnt1 = 0
        cnt2 = 0
        cnt3 = 0
        
        
        
;cnt1 is a lat/lon plot
        if (slice eq 1) then cnt1 = 1
        
;cnt1 is a lat/alt plot
        if (slice eq 2) then cnt3 = 1
        
;cnt1 is a lon/alt plot
        if (slice eq 3) then cnt2 = 1
        
        if n_elements(plotlogs) eq 0 then plotlogs = 'n'
        plotlogs = ask('whether you want log or not (y/n)',plotlogs)
        if (strpos(plotlogs,'y') eq 0) then plotlog = 1 else plotlog = 0
        
      
        
        if cnt1 then begin
            for i=0,nalts-1 do print, tostr(i)+'. '+string(alt(2,2,i))
        endif
        
        if cnt2 then begin
            for i=0,nlats-1 do print, tostr(i)+'. '+string(lat(2,i,2))
        endif
        
        if cnt3 then begin
            for i=0,nlons-1 do print, tostr(i)+'. '+string(lon(i,2,2))
        endif
        
        if n_elements(selset) eq 0 then selset = 0
        selset = fix(ask('which location to plot',tostr(selset)))
        
        if n_elements(sminis) eq 0 then sminis = 0.0
        if n_elements(smaxis) eq 0 then smaxis = 0.0
        sminis = float(ask('minimum (0.0 for automatic)',tostrf(sminis)))
        smaxis = float(ask('maximum (0.0 for automatic)',tostrf(smaxis)))
        
       
        if n_elements(pv) eq 0 then pv = 'n'
        pv = ask('whether you want vectors or not (y/n)',pv)
        if strpos(pv,'y') eq 0 then plotvector=1 else plotvector = 0
        
        if (plotvector) then begin
            print,'-1  : automatic selection'
            factors = [1.0, 5.0, 10.0, 20.0, 25.0, $
                       50.0, 75.0, 100.0, 150.0, 200.0]
            nfacs = n_elements(factors)
            for i=0,nfacs-1 do print, tostr(i)+'. '+string(factors(i)*10.0)
            if n_elements(vector_factor) eq 0 then vector_factor = -1
            vector_factor = fix(ask('velocity factor',tostr(vector_factor)))
        endif else vector_factor = 0
        
        
        
; yes is whether ghostcells are plotted or not:
        yes = 0
        no  = 1
        
; yeslog is whether variable should be logged or not:
        if (plotlog) then begin 
            yeslog = 1
            nolog  = 0
        endif else begin
            yeslog = 0
            nolog = 1
        endelse
        
; yeswrite_cnt is whether we have to output to a ps file or not.
        yeswrite_cnt = 1
        
; polar is variable to say whether we have polar plots or not
        polar = 0
        ortho = 0
        if cnt1 eq 1 then begin
            
            if n_elements(poro) eq 0 then poro = 0 
            poro = fix(ask("if polar or ortho (0,1,2): ",tostr(poro)))
            
            if poro eq 2 then begin
                polar = 0
                ortho = 1
                
                if n_elements(tlat) eq 0 then tlat = 0
                if n_elements(tlon) eq 0 then tlon = 0
                tlat = float(ask('ortho center latitude (0.0 for subsolar): ',$
                                 tostrf(tlat)))
                tlon = float(ask('ortho center longitude (0.0 for subsolar): ',$
                                 tostrf(tlon)))
                
            endif else begin
                if poro eq 1 then polar = 1
            endelse
        endif
        
        if ortho eq 1 then begin
            if tlat eq 0.0 and tlon eq 0.0 then begin
                
                zsun,strdate,uttime ,0,0,zenith,azimuth,solfac,$
                  lonsun=lonsun,latsun=latsun
                
                plat = latsun
                plon = lonsun
                
                if plon lt 0.0 then plon = 360.0 - abs(plon)   
;    if plon lt 180.0 then plon = plon + 180.0 else plon = plon - 180.0
                
                print, 'Coordinates: ',plon ,' Long. ',plat,' Lat.'
            endif else begin
                
                plat = tlat
                plon = tlon
                
            endelse
        endif
        
        
; npolar is whether we are doing the northern or southern hemisphere
        npolar = 1
        
; MinLat is for polar plots:
        MinLat = 40.0
        
; showgridyes says whether to plot the grid or not.
        showgridyes = 0
        
;plotvectoryes says whether to plot vectors or not
        plotvectoryes = plotvector
        
; plot vector difference or not
        plotvecdiff = 0
        
; number of points to skip when plotting vectors:
        step = 2
        
; vi_cnt is whether to plot vectors of Vi
        vi_cnt = 0
        
; vn_cnt is whether to plot vectors of Vn
        vn_cnt = 1
        
        
        cursor_cnt = 0
        
        xrange = [0.0,0.0]
        
        yrange = [0.0,0.0]
    endif
    smini = sminis
    smaxi = smaxis
    psfile = 'plot'+chopr('00'+tostr(ifile),3)+'.ps'
;    psfile = ask('ps file name',psfile)
data_sub = data

iviu = where(vars eq 'V!Di!N(up)')
ivie = where(vars eq 'V!Di!N(east)')
ivin = where(vars eq 'V!Di!N(north)')
ivnu = where(vars eq 'V!Dn!N(up)')

 if sel eq iviu or sel eq ivie or sel eq ivin or sel eq ivnu then $
  data_sub(sel,*,*,*) = (data(sel,*,*,*) - data_base(sel,*,*,*)) $
else $
  data_sub(sel,*,*,*) = (data(sel,*,*,*) - data_base(sel,*,*,*))/ $
  data_base(sel,*,*,*)*100.
;  data_sub(sel,*,*,*) = (data(sel,*,*,*) - data_base(sel,*,*,*))/ $
;  Max(data_base(sel,*,*,*))*100.

if plotvectoryes then begin
    if plotvecdiff then begin
        if vi_cnt eq 1 then begin
            eastsel = where(vars eq 'V!Di!N(east)')
            northsel = where(vars eq 'V!Di!N(north)')
        endif 
        
        if vn_cnt eq 1 then begin
            eastsel = where(vars eq 'V!Dn!N(east)')
            northsel = where(vars eq 'V!Dn!N(north)')
        endif
        
        data_sub(eastsel,*,*,*) = (data(eastsel,*,*,*) - $
                                   data_base(eastsel,*,*,*))
        data_sub(northsel,*,*,*) = (data(northsel,*,*,*) - $
                                    data_base(northsel,*,*,*))
    endif
endif

if sel eq iviu or sel eq ivnu then $ 
  vars(sel) = vars(sel) + ' Difference' else $
  vars(sel) = vars(sel) + ' % Difference' 

thermo_plotbatch,cursor_x,cursor_y,strx,stry,step,nvars,sel,nfiles, $	  
  cnt1,cnt2,cnt3,yes,no,yeslog,  	  $
  1-yeslog,nalts,nlats,nlons,yeswrite_cnt,$
  polar,npolar,MinLat,showgridyes,	  $
  plotvectoryes,vi_cnt,vn_cnt,vector_factor,	  $
  cursor_cnt,data_sub,alt,lat,lon,	  $
  xrange,yrange,selset,smini,smaxi,	  $
  filename,vars, psfile, mars, 'mid',itime,ortho,plat,plon


endfor


end
