function get_kpvalue, itime

cyear = tostr(itime(0))
cmonth = chopl('0'+tostr(itime(1)),2)
cday = chopl('0'+tostr(itime(2)),2)
kpfile = '~/UpperAtmosphere/Indices/KP/'+cyear+'.dat'
cdate = strmid(cyear,2,2)+cmonth+cday
kp = strarr(8)
ktime = [0,3,6,9,12,15,18,21,24]

done = 0
close,1
openr,1,kpfile

t = ''
while not done do begin
    readf,1,t
    temp = strmid(t,0,6)
    if temp eq cdate then done = 1
endwhile
close,1

for itimes = 0, 7 do begin
    kp_t = strmid(t,itimes*2 + 12,2)
    if fix(kp_t) lt 10 then kp_t='07'
    if strmid(kp_t,1,1) eq 0 then kp(itimes) = strmid(kp_t,0,1)
    if strmid(kp_t,1,1) eq 3 then kp(itimes) = strmid(kp_t,0,1)+'+'
    if strmid(kp_t,1,1) eq 7 then kp(itimes) = tostr(fix(strmid(kp_t,0,1))+1)+'-'

endfor

ikp = where(itime(3) ge ktime(0:7) and itime(3) lt ktime(1:8))

return, kp(ikp)


end        
