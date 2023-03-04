startdate = ask('start date (yyyy-mm-dd)',startdate)
enddate = ask('end date',enddate)
cyear = strmid(startdate,0,4)
sarr = strsplit(startdate,/extract)
earr = strsplit(enddate,/extract)

nmax = 10000
f107 = fltarr(nmax)    
itimearr = intarr(6,nmax)
rtime = fltarr(nmax)
nlines = 0

f107file = '/Users/dpawlows/GITM2/run/DataIn/F107.txt'
openr,5,f107file

startline = 1
endline = 1
temp = ''

line = 0
while startline do begin
    readf, 5, temp
    tarr = strsplit(temp,/extract)
    if tarr(0) eq startdate then startline = 0
    line = line + 1
endwhile
line = line - 1
close,5
openr,5,f107file
for i = 0, line - 1 do begin
   readf , 5, temp
endfor

iline = 0
while endline do begin
    readf, 5, temp
    tarr = strsplit(temp,/extract)
    f107(iline) = tarr(2)
    date = strsplit(tarr(0),'-',/extract)
    itimearr(0,iline) = date(0)
    itimearr(1,iline) = date(1)
    itimearr(2,iline) = date(2)
    nlines = nlines + 1
    iline = iline + 1
    if tarr(0) eq enddate then endline = 0
 endwhile
f107 = f107(0:iline-1)    
itimearr = itimearr(*,0:iline-1)
rtime = rtime(0:iline-1)
close,5 
for i = 0, nlines - 1 do begin
    t = itimearr(*,i)
    c_a_to_r,t,s
    rtime(i) = s
endfor

stime = rtime(0)
etime = rtime(nlines-1)

time_axis, stime, etime,btr,etr, xtickname, xtitle, xtickv, xminor, xtickn



ppp = 3
space = 0.01
pos_space, ppp, space, sizes, ny = ppp

get_position, ppp, space, sizes, 0, pos, /rect
pos(0) = pos(0) + 0.1

xtickname = tostr(findgen(365/27.+1) * 27)
xtickv = findgen(365/27.+1)*27 * 24*3600.
xminor = 0
xtickn = n_elements(xtickv)+1
xtitle = 'Day of Year '+cyear
yrange = [50,200]
plotname = 'plot.ps'
setdevice, plotname, 'p',5,.95
plot, rtime(0:nlines-1)-stime,f107(0:nlines-1),xtickname = xtickname,xtitle = xtitle,xtickv = xtickv, xticks = xtickn, xstyle = 1, pos = pos, ytitle = $
  'Flux (W m!E-2!N Hz!E-1!N)',charsize = 1.3, thick = 3,xminor = xminor,yrange=yrange
closedevice


end
