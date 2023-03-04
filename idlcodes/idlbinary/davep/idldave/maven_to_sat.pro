mavenfile = '~/UpperAtmosphere/MAVEN/DD1_SolarLatLong_Dec26toDec31_LT500km.txt'

nlinesmax= 10000
openr,5,mavenfile

started = 0
temp = ' '
while not started do begin
   readf,5,temp
   if strpos(temp,'Time') ge 0 then begin
      readf,5,temp
      started = 1
   endif
endwhile

itime = 0
itimearr = intarr(6,nlinesmax)
rtime = dblarr(nlinesmax)
lat = fltarr(nlinesmax)
lon = fltarr(nlinesmax)
alt = fltarr(nlinesmax)
rho = fltarr(nlinesmax)

while not eof(5) do begin
   readf,5,temp
   if strmid(temp,0,1) eq '' then begin
      readf,5,temp
      readf,5,temp
      readf,5,temp
   endif
   t = strsplit(temp,/extract)
   day = t(0)

   mon = month_to_number(t(1))
   year =t(2)
   hour = strmid(t(3),0,2)
   min = strmid(t(3),3,2)
   sec = strmid(t(3),6,2)
   
   itimearr(*,itime) = [fix(year),fix(mon),fix(day),fix(hour),fix(min),fix(sec)]
   lat(itime) = t(4)
   lon(itime) = t(5)
   rho(itime) = t(6)
   alt(itime) = t(7)
   
   itime = itime + 1
endwhile

close,5

ntimes = itime
itimearr = itimearr(*,0:ntimes-1)
lat = lat(0:ntimes-1)
lon = lon(0:ntimes-1)
rho = rho(0:ntimes-1)
alt = alt(0:ntimes-1)


itimearr[0,*] = 2001
itimearr[1,*] = 04
;locs = where(itimearr(2,*) eq 26)
;itimearr[2,locs] = 2
;locs = where(itimearr(2,*) eq 27)
;itimearr[2,locs] = 16
;locs = where(itimearr(2,*) eq 28)
;itimearr[2,locs] = 17
;locs = where(itimearr(2,*) eq 29)
;itimearr[2,locs] = 18
;locs = where(itimearr(2,*) eq 30)
;itimearr[2,locs] = 19
;locs = where(itimearr(2,*) eq 31)
;itimearr[2,locs] = 20


openw,5,'maven.dat'
printf, 5, '#START'
for iline = 0, ntimes - 1 do begin
    line = [tostr(itimearr(*,iline)),'0',tostrf(lon(iline)),tostrf(lat(iline)),tostrf(alt(iline))]

    printf, 5, line, format = '(7I,3F9.2)'
 endfor

close,5

end
