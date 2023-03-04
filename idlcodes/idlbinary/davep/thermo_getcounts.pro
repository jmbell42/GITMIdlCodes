PRO thermo_getcounts,filelist,pvar,palt,dataall,nmf2,hmf2,on2,sza

nfiles = n_elements(filelist)
itimearray = intarr(6,nfiles)
rtime = fltarr(nfiles)
spos = strpos(filelist(0),'t',/reverse_search,/reverse_offset)+1
for ifile = 0, nfiles - 1 do begin

    cyear = strmid(filelist(ifile),spos,2)
    cmon  = strmid(filelist(ifile),spos+2,2)
    cday  = strmid(filelist(ifile),spos+4,2)
    chour = strmid(filelist(ifile),spos+7,2)
    cmin  = strmid(filelist(ifile),spos+9,2)
    csec  = strmid(filelist(ifile),spos+11,2)

    if fix(cyear) gt 50 then cyear = tostr(1900+fix(cyear)) else cyear = tostr(2000 + fix(cyear)) 
    itimearray(*,ifile) = fix([cyear,cmon,cday,chour,cmin,csec])
    c_a_to_r,itimearray(*,ifile),rt
    rtime(ifile) = rt
endfor


for ifile = 0, nfiles - 1 do begin
        
    filename = filelist(ifile)

     print, 'Reading file ',filename
     
     read_thermosphere_file, filename, nvars, nalts, nlats, nlons, $
       vars, data, rb, cb, bl_cnt



     if ifile eq 0 then begin
         ;3 for avg,min,max
         ;4 for glb,day,night,hlat
         dataall = fltarr(nfiles,nlons,nlats)
         nmf2 = fltarr(nfiles,nlons,nlats)
         hmf2 = fltarr(nfiles,nlons,nlats)
         on2 = fltarr(nfiles,nlons,nlats)

     endif

     dataall(ifile,*,*) = data(pvar,*,*,palt)
     
     alt = reform(data(2,0,0,*)) / 1000.0
     lat = reform(data(1,*,*,0)) / !dtor
     lon = reform(data(0,*,*,0)) / !dtor
          
     itemp = where(vars eq 'Temperature') 
     ie = where(vars eq '[e-]') 
     irho = where(vars eq 'Rho') 
     iO = where(vars eq '[O(!U3!NP)]') 
     iN2 = where(vars eq '[N!D2!N]') 
     
     eDen = reform(data(ie,2:nlons-3,2:nlats-3,2:nalts-3))
     ODen = reform(data(iO,2:nlons-3,2:nlats-3,2:nalts-3))
     N2Den = reform(data(iN2,2:nlons-3,2:nlats-3,2:nalts-3))
     
     sza = fltarr(nlons-4,nlats-4)

      for ilat = 0, nlats - 5 do begin
         for ilon = 0, nlons - 5 do begin
             tlat = lat(ilon+2,ilat+2,0)
             tlon = lon(ilon+2,ilat+2,0)
             if tlon gt 180.0 then tlon = tlon - 360
             cyear = tostr(itimearray(0,ifile))
             cmon = tostr(itimearray(1,ifile))
             cday = tostr(itimearray(2,ifile))
             chour = tostr(itimearray(3,ifile))
             cmin = tostr(itimearray(4,ifile))
             csec = tostr(itimearray(5,ifile))
             day = cyear+'-'+cmon+'-'+cday
             ut = fix(chour) + fix(cmin)/60. + fix(csec)/3600.
             zsun,day,ut,tlat,tlon,zenith,azimuth,solfac
             sza(ilon,ilat) = zenith
             
             loc = where(alt(2:nalts-3) gt 200.0)
             ialt200 = loc(0)
             NmF2(ifile,ilon+2,ilat+2) = max(eden(ilon,ilat,ialt200:*),ihmf2)
             HmF2(ifile,ilon+2,ilat+2) = alt(ihmf2+ialt200+2)
         endfor
     endfor
     
      o      = fltarr(nLons-4, nLats-4)
     n2     = fltarr(nLons-4, nLats-4)
     AltInt = fltarr(nLons-4, nLats-4)
     
     MaxValN2 = 1.0e21


     for iLon = 2, nLons-3 do begin
         for iLat = 2, nLats-3 do begin
             
             iAlt = nAlts-1
             Done = 0
             if (max(data(in2,iLon,iLat,*)) eq 0.0) then Done = 1
             while (Done eq 0) do begin
                 dAlt = (Alt(iAlt)-Alt(iAlt-1))*1000.0
                 n2Mid = (data(in2,iLon,iLat,iAlt) + $
                          data(in2,iLon,iLat,iAlt-1)) /2.0
                 oMid  = (data(io,iLon,iLat,iAlt) + $
                          data(io,iLon,iLat,iAlt-1)) /2.0
                 
                 if (n2(iLon-2,iLat-2) + n2Mid*dAlt lt MaxValN2) then begin
                     n2(iLon-2,iLat-2) = n2(iLon-2,iLat-2) + n2Mid*dAlt
                     o(iLon-2,iLat-2)  =  o(iLon-2,iLat-2) +  oMid*dAlt
                     iAlt = iAlt - 1
                 endif else begin
                     dAlt = (MaxValN2 - n2(iLon-2,iLat-2)) / n2Mid
                     n2(iLon-2,iLat-2) = n2(iLon-2,iLat-2) + n2Mid*dAlt
                     o(iLon-2,iLat-2)  =  o(iLon-2,iLat-2) +  oMid*dAlt
                     AltInt(iLon-2,iLat-2) = Alt(iAlt) - dAlt
                     Done = 1
                 endelse
             endwhile
             
             
         endfor
     endfor
     

     loc = where(n2 gt 0.0,count)
     r = fltarr(nlons-4,nlats-4)
     if (count gt 0) then begin
         r(loc) = o(loc)/n2(loc)
         on2(ifile,2:nlons-3,2:nlats-3) = r
     endif

 endfor


end
