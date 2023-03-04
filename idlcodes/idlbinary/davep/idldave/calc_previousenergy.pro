PRO calc_previousenergy, fe,be,file,eitime,fitime,nhours,fism
;yyyy-mm-dd
;hh-mm




;eitime = fix([cyear,cmonth,cday,chour,cmin,'0'])

c_a_to_r,eitime,etime
stime = etime - nhours*3600.
c_r_to_a,sitime,stime

c_a_to_r,fitime,fetime
fstime = fetime - nhours*3600.
c_r_to_a,fsitime,fstime

bstime = fetime - 3*3600.
c_r_to_a,bsitime,bstime

if stime gt bstime then sitime = bsitime

if fism then begin
    cyear = tostr(eitime(0))
;cmonth = strmid(date,5,2)
;cday = strmid(date,8,2)
;chour = strmid(time,0,2)
;cmin = strmid(time,3,2)
    bdoy = jday(sitime(0),sitime(1),sitime(2))
    edoy = jday(eitime(0),eitime(1),eitime(2))
    
    ndays = edoy - bdoy + 1
    
    fismfile = strarr(ndays)

    if ndays eq 2 then begin  
       sdate = tostr(sitime(0))+chopr('0'+tostr(sitime(1)),2) + chopr('0'+tostr(sitime(2)),2)
       fismfile(0) =  $
          file_search('~/UpperAtmosphere/FISM/BinnedFiles/'+cyear+'/fismflux'+sdate+'.dat')
       
       sdate = tostr(eitime(0))+chopr('0'+tostr(eitime(1)),2) + chopr('0'+tostr(eitime(2)),2)
       fismfile(1) =  $
          file_search('~/UpperAtmosphere/FISM/BinnedFiles/'+cyear+'/fismflux'+sdate+'.dat')
       
    endif else begin
       
       sdate = tostr(sitime(0))+chopr('0'+tostr(sitime(1)),2) + chopr('0'+tostr(sitime(2)),2)
       fismfile(0) = file_search('~/UpperAtmosphere/FISM/BinnedFiles/'+cyear+'/fismflux'+sdate+'.dat')
       
    endelse
endif


nlinesmax = 10000
nwaves = 59
waveL = fltarr(nwaves)
waveH = fltarr(nwaves)

close,93
lowfile = '~/UpperAtmosphere/SEE/wavelow'
openr,93,lowfile
readf, 93, waveL
close,93

highfile = '~/UpperAtmosphere/SEE/wavehigh'
openr,93,highfile
readf, 93, waveH
close,93

fflux = fltarr(nwaves,nlinesmax)
itime = intarr(6,nlinesmax)
rtime = dblarr(nlinesmax)

close,93
temp = fltarr(nwaves+6)
iline = 0

if fism then begin
    for iday = 0, ndays - 1 do begin
        openr, 93,fismfile(iday)
        start = 0 
        t = ' '
        while not start do begin
            readf,93,t
            if strpos(t,'#START') ge 0 then start = 1
        endwhile
        
        while not eof(93) do begin
            
            readf, 93,temp
            itime(*,iline) = fix(temp(0:5))
            fflux(*,iline) = temp(6:*)
            c_a_to_r,itime(*,iline),rt
            rtime(iline) = rt
            
            iline = iline + 1
        endwhile
        close,93
    endfor
endif else begin
    openr, 93,file
    start = 0 
    t = ' '
    while not start do begin
        readf,93,t
        if strpos(t,'#START') ge 0 then start = 1
    endwhile
    
    while not eof(93) do begin
        
        readf, 93,temp
        itime(*,iline) = fix(temp(0:5))
        fflux(*,iline) = temp(6:*)
        c_a_to_r,itime(*,iline),rt
        rtime(iline) = rt
        
        iline = iline + 1
    endwhile
    close,93
endelse
;endfor

fflux = fflux(*,0:iline-1)
rtime = rtime(0:iline-1)
itime = itime(*,0:iline-1)

blocs1 = where(rtime ge bstime and rtime lt fetime)
blocs2 = where(rtime ge bstime+1*3600. and rtime lt fetime)
blocs3 = where(rtime ge bstime+2*3600. and rtime lt fetime)
blocs4 = where(rtime ge bstime+2.5*3600. and rtime lt fetime)
blocs5 = where(rtime ge bstime-3600. and rtime lt fetime)
;nlocs1 = n_elements(blocs)
bflux = fltarr(nwaves)

for iwave = 0 , nwaves - 1 do begin
    minv2 = min([mean(fflux(iwave,blocs1)),mean(fflux(iwave,blocs2)),mean(fflux(iwave,blocs3)),mean(fflux(iwave,blocs4)),mean(fflux(iwave,blocs5))],im)
    minv = min(fflux(iwave,blocs1))

    bflux(iwave) = minv2
endfor

locs = where(rtime ge stime and rtime le etime)
nlocs = n_elements(locs)
energy = fltarr(nlocs)
benergy = fltarr(nlocs)
for itime = 0, nlocs-1 do begin
    energy(itime) = total(fflux(*,locs(itime)))* $
      (rtime(locs(itime)+1)-rtime(locs(itime)))

    benergy(itime) = total(bflux)*$
      (rtime(locs(itime)+1)-rtime(locs(itime)))
    
endfor


;nblocs = n_elements(blocs)
;benergy = fltarr(nlocs)
;for itime = 0, nblocs - 1 do begin
;    benergy(itime) = total(fflux(*,blocs(itime)))*$
;      (rtime(blocs(itime)+1)-rtime(blocs(itime)))
;endfor

fe = total(energy)
be = total(benergy)
end
