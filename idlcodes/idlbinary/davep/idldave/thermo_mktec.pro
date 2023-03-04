
filelist = findfile('../1028/3DALL*.bin')
filelist_base = findfile('../1028background/3DALL*.bin') 
for i=0,n_elements(filelist)-1 do begin
  print, tostr(i),". ",filelist(i)
endfor
i = fix(ask('file to convert, -1 for all','0'))


nFiles = n_elements(filelist)
nfiles_base = n_elements(filelist_base)
if nfiles ne nfiles_base then begin
    print, 'perturbation and base directories do not have same amount of files'
    stop
endif
if (i ne -1) then filelist = filelist(i)
if (i ne -1) then filelist_base = filelist_base(i)
nFiles = n_elements(filelist)
nfiles_base = n_elements(filelist_base)

for iFile = 0, nFiles-1 do begin

    file = filelist(iFile)
    file_base = filelist_base(ifile)

    p = strpos(file,".bin")
    l = 20
    file = strmid(file,p-20,p)

    print, 'reading ',file

    read_thermosphere_file, filelist(iFile), nvars, nalts, nlats, nlons, $
      vars, data, nBLKlat, nBLKlon, nBLK, $
      iTime, Version
    
    read_thermosphere_file, filelist_base(iFile), nvars_base, nalts_base,$
      nlats_base, nlons_base,vars_base, $ 
      data_base, nBLKlat_base, nBLKlon_base, nBLK_base, $
      iTime_base, Version

    lon = reform(data(0,*,*,*)) + !pi
    lat = reform(data(1,*,*,*))
    alt = reform(data(2,*,*,*))
    re  = 6372000.0
    r   = (alt + re)/re

    ue = reform(data(16,*,*,*))
    un = reform(data(17,*,*,*))
    ur = reform(data(18,*,*,*))

    ux = -ue * sin(lon) - un * cos(lon) * sin(lat) + ur * cos(lat) * cos(lon)
    uy =  ue * cos(lon) - un * sin(lon) * sin(lat) + ur * cos(lat) * sin(lon)
    uz =  un * cos(lat) + ur * sin(lat)

    data(16,*,*,*) = ux
    data(17,*,*,*) = uy
    data(18,*,*,*) = uz

    x = r * cos(lon) * cos(lat)
    y = r * sin(lon) * cos(lat)
    z = r * sin(lat)
    
    openw,1,file+".dat"
    openw,2,file+"_sup.dat"

    printf,1,"TITLE=""GITM Results from IDL save file"""
    printf,1,"VARIABLES="
    printf,1,"          ""X [R]"","
    printf,1,"          ""Y [R]"","
    printf,1,"          ""Z [R]"""
    for i=0,nvars-2 do printf,1,"          """+vars(i)+""","
    printf,1,"          """+vars(nvars-1)+""""
    printf,1,"ZONE T="""+file+""""
    printf,1,"I="+tostr(nalts-4)+",J="+tostr(nlats-4)+",K="+tostr(nlons-3)
    printf,1,"ZONETYPE=Ordered"
    printf,1,"DATAPACKING=POINT"

    s = strarr(nvars+3)+"SINGLE"

    printf,1,"DT=(",s,")"

    printf,2,"TITLE=""GITM Results from IDL save file"""
    printf,2,"VARIABLES="
    printf,2,"          ""X [R]"","
    printf,2,"          ""Y [R]"","
    printf,2,"          ""Z [R]"""
    for i=0,nvars-2 do printf,2,"          """+vars(i)+""","
    printf,2,"          """+vars(nvars-1)+""""
    printf,2,"ZONE T="""+file+""""
    printf,2,"I="+tostr(1)+",J="+tostr(1)+",K="+tostr(1)
    printf,2,"ZONETYPE=Ordered"
    printf,2,"DATAPACKING=POINT"

    s = strarr(nvars+3)+"SINGLE"

    printf,2,"DT=(",s,")"

    format = "("+tostr(nvars+3)+"e14.6)"


    temp = reform((data(3,2:nlons-3,2:nlats-3,36) $
                   - data_base(3,2:nlons-3,2:nlats-3,36)) /$ 
                  data_base(3,2:nlons-3,2:nlats-3,36)) *100.

    for iLon = 1, nlons-3 do for iLat = 2,nLats-3 do for iAlt = 2,nAlts-3 do begin

        
        tmp = reform(data(*,iLon,iLat,iAlt))
        tmp(3) = $
          (data(3,iLon,iLat,iAlt)-data_base(3,iLon,iLat,iAlt)) / $
                 data_base(3,iLon,iLat,iAlt)*100.0

        printf,1, $
          x(iLon,iLat,iAlt), $
          y(iLon,iLat,iAlt), $
          z(iLon,iLat,iAlt), $
          tmp, format=format
        
    endfor

    ; Write out supplemental material here

    x = 0.0
    y = 0.0
    z = 0.0

    tmp = tmp*0.0
    tmp(0) = (float(itime(3))+float(itime(4))/60.0+float(itime(5))/3600.0)*15.0

    printf,2, $
      x, $
      y, $
      z, $
      tmp, format=format
        
    close,1,2

endfor

end