
if (n_elements(year) eq 0) then year = '2003'
year = ask('year',year)

if (n_elements(month) eq 0) then month = '10'
month = string(fix(ask('month',month)), format='(I02)')

if (n_elements(day) eq 0) then day = '29'
day = string(fix(ask('day',day)), format='(I02)')

sitime = fix([year,month,day,'0','0','0'])
c_a_to_r,sitime,stime
etime = stime + 3600.*24
bdoy = jday(sitime(0),sitime(1),sitime(2))
cyear = tostr(sitime(0))
cdoy = tostr(bdoy)

cmonth = tostr(sitime(1))
cdt = fromjday(fix(cyear),fix(cdoy))
cday = tostr(cdt(1))
files= file_search('~/UpperAtmosphere/SABER/'+cyear+'/timed*.cdf')
nfiles = n_elements(files)


nrecsmax = 300
naltsmax  = 500
iline = 0

altitude = fltarr(naltsmax,nfiles*nrecsmax)
latitude = fltarr(naltsmax,nfiles*nrecsmax)
longitude = fltarr(naltsmax,nfiles*nrecsmax)
date = fltarr(nfiles*nrecsmax)
time = altitude
nrecs = intarr(nfiles)
satfile = 'saber'+cyear+chopr('0'+cmonth,2)+chopr('0'+cday,2)+'.dat'
close,1
openw,1,satfile
printf,1,'#START'
  for ifile = 0, nfiles - 1 do begin
        file = files(ifile)

        id = cdf_open(file)
        result = cdf_inquire(id)
        
        cdf_control,id,var='event',/z,get_var_info=v
        nrecs(ifile) = v.maxrec
        nzVars = result.nzVars
        natts = result.natts
        svars = strarr(nzVars)
stop
        cdf_varget, id, 16, t,rec_count=nrecs(ifile),/z
        cdf_varget, id, 2, dte,rec_count=nrecs(ifile),/z
        cdf_varget, id, 33,lon,rec_count=nrecs(ifile),/z
        cdf_varget, id, 32, lat,rec_count=nrecs(ifile),/z
        cdf_varget, id, 31, alt,rec_count=nrecs(ifile),/z
        
        
        cdf_close,id

        for irec = 0 ,nrecs(ifile)-1 do begin
        cdate = tostr(dte(0,irec))
        hour = t(0,irec)/1000./3600.
        ih = fix(hour)
        im = fix((hour-ih)*60.)
        is  = fix(((hour-ih)*60-im)*60)
        iy = fix(strmid(cdate,0,4))
        doy = fix(strmid(cdate,4,3))
        dt = fromjday(iy,doy)
        imo = dt(0)
        id = dt(1)
        it = [iy,imo,id,ih,im,is]
        c_a_to_r,it,rt

        alt = 400.0
        if rt ge stime and rt le etime then $
          printf,1,iy,imo,id,ih,im,is,0,lon(0,irec),lat(0,irec),alt,format='(7I,3F12.2)'
    endfor
    endfor
close,1  
 
end 