
;--------------------------------------------------------------
; Get Inputs from the user
;--------------------------------------------------------------

if (n_elements(amie_file) eq 0) then begin

  initial_guess = findfile('-t b*')
  initial_guess = initial_guess(0)
  if strlen(initial_guess) eq 0 then initial_guess='b970101'

endif else initial_guess = amie_file

amie_file = ask('AMIE binary file name',initial_guess)
psfile = ask('ps file',amie_file+'_j4.ps')

mr = 40.0

read_amie_binary, amie_file, AMIEData, lats, mlts, AMIETime, fields, 	$
                  imf, ae, dst, hp, cpcp

nmlts = n_elements(mlts)
nlats = n_elements(lats)

; Figure out which hemisphere we are in

Hem = 1
if lats(0) lt 0 then Hem = -1

; For most current AMIE runs, Auroral Energy Flux is 6, while
; Hall Conductance (Aurora) is 4.

;ef_ = 14
;me_ = 13
ef_ = 6
hc_ = 4 

dmlt = mlts(1) - mlts(0)
dlat = lats(0) - lats(1)

; Determine x and y coordinates of AMIE plots

lat2d = fltarr(nmlts,nlats)
lon2d = fltarr(nmlts,nlats)

for i=0,nlats-1 do lon2d(*,i) = mlts*!pi/12.0 - !pi/2.0
for i=0,nmlts-1 do lat2d(i,*) = lats

x = (90.0-lat2d)*cos(lon2d)
y = (90.0-lat2d)*sin(lon2d)

LatLoc = where(90.0 - lats le mr)
x = x(*,LatLoc)
y = y(*,LatLoc)

c_r_to_a, itime, AMIETime(0)
J4Date = tostr(itime(0))+ $
         chopr('0'+tostr(itime(1)),2) + $
         chopr('0'+tostr(itime(2)),2)
;;chopr('0'+tostr(itime(0)),2) + $
yymm   = chopr('0'+tostr(itime(0)),2) + $
         chopr('0'+tostr(itime(1)),2)

filelist = findfile('/swrdata/AMIE/'+yymm+'/Data/dmsp/J4/19'+J4Date+'/*.ssj4')
print, J4Date
nfiles = n_elements(filelist)

setdevice, psfile, 'p', 4, 0.95

; Metrics is an array which is going to compare some values for all of
; the passes.  The 4 is for 4 metrics. The 2 is for 2 cuts through the
; aurora.
nMetrics = 8
Metrics = fltarr(nMetrics,2,nFiles)
MetricsTimes = dblarr(nFiles)

DummyData = fltarr(6)

pnBase = 8

for iFile=0,nfiles-1 do begin

  j4file = filelist(iFile)
  print, 'J4File:'  + J4file
  ; Get the SAT ID as the first three chars of the file (Fix later)
  ; Assumes a / before the file name ie like /blah/F13XXXX 
  DMSPSat = 'F13'
  fnpos = STRPOS(j4file,'/',/reverse_search)
  DMSPSat = STRMID(j4file, fnpos+1, 3) 
  read_j4_data, j4file, J4Data, J4Time, GeoPos, MagPos, nPts

  if nPts eq 0 then nPts = 1

  ; for J4 data, Auroral Energy Flux is 1, while
  ; Mean energy is 2.

  CompIter  = intarr(nPts)
  InterLong = fltarr(nPts)
  InterLat  = fltarr(nPts)

  AMIEEFlux = fltarr(nPts)
  AMIEHC  = fltarr(nPts)

  J4EFlux = fltarr(nPts)
  J4AAveE  = fltarr(nPts)

  nAve = 10

  for i=1,nPts-1 do $
    if (J4Data(1,i) gt J4Data(1,i-1)*5.0 and J4Data(1,i) gt 8.0) then $
      J4Data(1,i) = J4Data(1,i-1)

  for i=0,nPts-1 do begin

    ; Find Closest Time in AMIE Data

    d = abs(AMIETime - J4Time(i))
    loc = where(d eq min(d))
    CompIter(i) = loc(0)

    ; Find Interpolation points in AMIE grid

    InterLong(i) = MagPos(2,i) / dmlt
    InterLat(i)  = (90-MagPos(0,i)) / dlat

    AMIEEFlux(i) = interpolate(AMIEData(CompIter(i),ef_,*,*), $
			InterLong(i), InterLat(i))
    AMIEHC(i)  = interpolate(AMIEData(CompIter(i),hc_,*,*), $
			InterLong(i), InterLat(i))

    ; Lets calculate running averages to compare to
    if (i gt nAve/2) and (i lt nPts-nAve/2-1) then begin
      for j=i-nAve/2,i+nAve/2-1 do begin
        J4EFlux(i) = J4EFlux(i) + J4Data(1,j)/nAve
        J4AAveE(i)  = J4AAveE(i) + J4Data(2,j)/nAve
      endfor
    endif

  endfor

  loc = where(MagPos(0,*)*Hem gt 90-mr, nTruePts)

  if (nTruePts gt 0) then begin
    loczero = where(J4Data(1,loc) eq 0.0)
    nBadPts = n_elements(loczero)
    if (float(nBadPts)/float(nTruePts) gt 0.5) then begin
      nTruePts = 0
    endif
  endif

  if (nTruePts gt 0) then begin

    stime = min(J4Time(loc))
    etime = max(J4Time(loc))

    time_axis, stime, etime, s_time_range, e_time_range,        	$
	xtickname, xtitle, xtickvalue, xminor, xtickn

    if pnBase eq 8 then pnBase = 0 else pnBase = 8
    if pnBase eq 0 then begin
      plotdumb
      ppp = 16
      space = 0.03
      pos_space, ppp, space, sizes, ny = 4
      fac = 1.0
    endif else fac = -1.0

    pn = pnBase + 0
    get_position, ppp, space, sizes, pn, pos
    pos([1,3]) = pos([1,3]) + fac*space

    iter = mean(CompIter(loc))

    mini = 0.0
    maxi = max(AMIEData(iter,ef_,*,*))
    range = maxi
    dc      = 10.0^fix(alog10(range/20.0))
    factor  = 0.0
    while (range gt dc*20.0*factor) do factor=factor+0.1
    dc = factor*dc
    levels = findgen(21)*dc

    readct, ncolors, getenv("IDL_EXTRAS")+"blue_white_red.ct"
    ;readct, ncolors, getenv("IDL_EXTRAS")+"white_red.ct"
    clevels = (ncolors-1)*findgen(21)/20.0 + 1

    contour, reform(AMIEData(iter,ef_,*,LatLoc)),x,y,/follow, 		$
	xstyle = 5, ystyle = 5,						$
	xrange = [-mr,mr],yrange=[-mr,mr], levels = levels, 		$
	pos = pos, /noerase, /cell_fill, c_color = clevels

  ;  xyouts, pos(0)-0.01,pos(3)-0.01, amie_time_1(n),charsize=0.9, /norm

    J4x = (90.0 - MagPos(0,loc)) * cos(MagPos(2,loc)*!pi/12.0 - !pi/2.0)
    J4y = (90.0 - MagPos(0,loc)) * sin(MagPos(2,loc)*!pi/12.0 - !pi/2.0)

    plotmlt, mr, /no06, /no00
    oplot, J4x, J4y
    xyouts, J4x(0)*1.18, J4y(0)*1.18, 'S'
    xyouts, min(x), max(y)*.9, DMSPSat

    pn = pnBase + 1
    get_position, ppp, space, sizes, pn, pos1

    pn = pnBase + 3
    get_position, ppp, space, sizes, pn, pos2

    pos(0) = pos1(0)
    pos(1) = pos1(1)
    pos(2) = pos2(2)
    pos(3) = pos1(3)
    pos([1,3]) = pos([1,3]) + fac*space

    plot, J4Time(loc)-stime,J4Data(1,loc), pos = pos,	 		$
	xstyle = 1, /noerase,		$
	xtickname = strarr(10)+' ', xtickv=xtickvalue, 			$
	xticks = xtickn, xminor = xminor, xtitle = ' ',			$
	xrange = [s_time_range, e_time_range], $
	ytickname = strarr(20)+' ', yrange=[0.0,min([10.0,max(J4Data(1,loc))])]
    axis, yax=1, charsize=0.9, yrange=[0.0,min([10.0,max(J4Data(1,loc))])]

    xyouts, pos(0)-0.005, (pos(1)+pos(3))/2.0, 'Elec. E. (ergs/cm2/s)', $
  	/norm, alignment = 0.5, orient = 90, charsize = 0.75

    oplot, J4Time(loc)-stime, AMIEEFlux(loc), linestyle = 2
    oplot, J4Time(loc)-stime, J4EFlux(loc), linestyle = 1

    ; Let's try to figure out the metric which we want to use...

    ; First we want to determine whether we had a skimmer pass or a real
    ; pass.  To do this, we figure out whether there are two maxima
    ; in the Electron Fluxes:

    MaxLeft  = max(J4EFlux(loc(0:nTruePts/2-1)))
    LocLeft  = where(J4EFlux(loc(0:nTruePts/2-1)) eq MaxLeft)
    ; We want the right most point of this
    LocLeft  = loc(LocLeft(n_elements(LocLeft)-1))

    MaxRight  = max(J4EFlux(loc(nTruePts/2:nTruePts-1)))
    LocRight  = where(J4EFlux(loc(nTruePts/2:nTruePts-1)) eq MaxRight)
    ; We want the left most point of this
    LocRight  = loc(LocRight(0)+nTruePts/2)

    ; Left first

    TrueMax = max(J4Data(1,LocLeft-nAve/2:LocLeft+nAve/2-1))
    LocTrueMax = where(J4Data(1,LocLeft-nAve/2:LocLeft+nAve/2-1) eq TrueMax)
    LocLeft = LocTrueMax(0) + LocLeft-nAve/2

    ; Right next

    TrueMax = max(J4Data(1,LocRight-nAve/2:LocRight+nAve/2-1))
    LocTrueMax = where(J4Data(1,LocRight-nAve/2:LocRight+nAve/2-1) eq TrueMax)
    LocRight = LocTrueMax(0) + LocRight-nAve/2

    nPeaks = 2

    ; Test to see how close they are to each other:
    if (LocRight - LocLeft lt nAve) then nPeaks = 1

    ; if we have a single peak, then move everything to LocLeft

    if (nPeaks eq 1) and (MaxRight gt MaxLeft) then begin
      MaxLeft = MaxRight
      LocLeft = LocRight
    endif

    ; Now we have to find the AMIE peaks:

    ; Left first

    AMIEMax = max(AMIEEFlux(LocLeft-nAve:LocLeft+nAve-1))
    LocAMIEMax = where(AMIEEFlux(LocLeft-nAve:LocLeft+nAve-1) eq AMIEMax)
    AMIELocLeft = LocAMIEMax(0) + LocLeft-nAve

    ; Right next

    if (nPeaks gt 1) then begin

      AMIEMax = max(AMIEEFlux(LocRight-nAve:LocRight+nAve-1))
      LocAMIEMax = where(AMIEEFlux(LocRight-nAve:LocRight+nAve-1) eq AMIEMax)
      AMIELocRight = LocAMIEMax(0) + LocRight-nAve

    endif

    ; Now lets do some interesting things...

    metrics(0,0,iFile) = (J4Data(1,LocLeft) - AMIEEFlux(AMIELocLeft))/J4Data(1,LocLeft)
    metrics(1,0,iFile) = MagPos(0,LocLeft) - MagPos(0,AMIELocLeft)

    lag = indgen(nAve+1) - nAve/2

    if (npeaks eq 1) then begin
      c = c_correlate(J4Data(1,loc),AMIEEFlux(loc), lag)
      cloc = where(c eq max(c))
      cloc = cloc(0)
      metrics(2,0,iFile) = c(cloc)
      metrics(4,0,iFile) = MagPos(0,LocLeft) - MagPos(0,LocLeft + lag(cloc))
      c = c_correlate(J4Data(1,loc),J4EFlux(loc),0)
      metrics(3,0,iFile) = c(0)
    endif else begin
      ; Left
      locl = LocLeft + indgen(nAve*4+1) - nAve*2
      c = c_correlate(J4Data(1,locl),AMIEEFlux(locl), lag)
      cloc = where(c eq max(c))
      cloc = cloc(0)
      metrics(2,0,iFile) = c(cloc)
      metrics(4,0,iFile) = MagPos(0,LocLeft) - MagPos(0,LocLeft + lag(cloc))
      c = c_correlate(J4Data(1,locl),J4EFlux(locl),0)
      metrics(3,0,iFile) = c(0)

      ; Right
      locr = LocRight + indgen(nAve*4+1) - nAve*2
      c = c_correlate(J4Data(1,locr),AMIEEFlux(locr), lag)
      cloc = where(c eq max(c))
      cloc = cloc(0)
      metrics(2,1,iFile) = c(cloc)
      metrics(4,1,iFile) = MagPos(0,LocRight) - MagPos(0,LocRight + lag(cloc))
      c = c_correlate(J4Data(1,locr),J4EFlux(locr),0)
      metrics(3,1,iFile) = c(0)
    endelse

;    metrics(0,0,iFile) = J4Data(1,LocLeft) - AMIEEFlux(AMIELocLeft)

    if (nPeaks gt 1) then begin
      metrics(0,1,iFile) = (J4Data(1,LocRight) - AMIEEFlux(AMIELocRight))/J4Data(1,LocRight)
      metrics(1,1,iFile) = MagPos(0,LocRight) - MagPos(0,AMIELocRight)
    endif else metrics(*,1,iFile) = -9999.0

    ; We want to find the number of mag data points in the vacinity of
    ; the DMSP data.

    pn = pnBase + 0
    get_position, ppp, space, sizes, pn, pos
    pos([1,3]) = pos([1,3]) + fac*space

    plot, x,y,/nodata, xstyle = 5, ystyle = 5,	$
	xrange = [-mr,mr],yrange=[-mr,mr], pos = pos, /noerase

    CentralTime = mean(J4Time(loc))

    ; we only want to do this if we are comparing to Ahn formulation

    if (hc_ ne 13) then begin

      DataFile = amie_file + '_data'

      openr,11, DataFile

      line = ''
      itime = intarr(6)

      done = 0

      while not done do begin

        readf, 11, line

        if eof(11) then begin
          print, 'EOF in datafile ',datafile
          done = 1
          type = -1
        endif

        if (strpos(line,'#TIME') gt -1) then begin
          readf, 11, itime
          c_a_to_r, itime, rtime_amie
          if (rtime_amie ge CentralTime) then begin
            done = 1
            type = 0
          endif
        endif

      endwhile

      metrics(5,*,iFile) = 0

      while (type eq 0) do begin

        readf,11,line

        if eof(11) then type = -1

        if (strpos(line,'#TIME') gt -1) then type = -1
        if (strpos(line,'#AHN') gt -1) then begin
          type = 1
          readf, 11, npts
          for i = 0, npts-1 do begin 
            readf, 11, lat, mlt, data

  	    if (90.0-lat le mr) then begin
              oplot, [(90.0-lat)*cos(mlt*!pi/12.0-!pi/2)],$
		  [(90.0-lat)*sin(mlt*!pi/12.0-!pi/2)], psym=4
 	    endif

            if (abs(mlt-MagPos(2,LocLeft)) lt 1.0) then $
              metrics(5,0,iFile) = metrics(5,0,iFile) + 1
            if (abs(mlt-MagPos(2,LocRight)) lt 1.0) then $
              metrics(5,1,iFile) = metrics(5,1,iFile) + 1

            ; special cases:

            if (mlt lt 1.0 and MagPos(2,LocLeft) gt 23.0) then $
              metrics(5,0,iFile) = metrics(5,0,iFile) + 1
            if (mlt lt 1.0 and MagPos(2,LocRight) gt 23.0) then $
              metrics(5,1,iFile) = metrics(5,1,iFile) + 1

            if (mlt gt 23.0 and MagPos(2,LocLeft) lt 1.0) then $
              metrics(5,0,iFile) = metrics(5,0,iFile) + 1
            if (mlt gt 23.0 and MagPos(2,LocRight) lt 1.0) then $
              metrics(5,1,iFile) = metrics(5,1,iFile) + 1

          endfor
        endif
      endwhile

    endif

    metrics(6,0,iFile) = ae(CompIter(LocLeft),0)
    metrics(6,1,iFile) = ae(CompIter(LocRight),0)

    MetricsTimes(iFile) = AMIETime(CompIter(LocLeft))
    MetricsTimes(iFile) = AMIETime(CompIter(LocRight))

    metrics(7,0,iFile) = MagPos(2,LocLeft)
    metrics(7,1,iFile) = MagPos(2,LocRight)

    close, 11

    oplot, [J4Time(LocLeft)-stime,J4Time(LocLeft)-stime], [0,1000]
    oplot, [J4Time(LocRight)-stime,J4Time(LocRight)-stime], [0,1000]

    pn = pnBase + 4
    get_position, ppp, space, sizes, pn, pos
    pos([1,3]) = pos([1,3]) + space - 0.01
    pos([1,3]) = pos([1,3]) + fac*space

    iter = mean(CompIter(loc))

    mini = 0.0
    maxi = max(AMIEData(iter,hc_,*,*))
    range = maxi
    dc      = 10.0^fix(alog10(range/20.0))
    factor  = 0.0
    while (range gt dc*20.0*factor) do factor=factor+0.1
    dc = factor*dc
    levels = findgen(21)*dc

    ;readct, ncolors, getenv("IDL_EXTRAS")+"blue_white_red.ct"
    ;readct, ncolors, getenv("IDL_EXTRAS")+"white_red.ct"
    ;clevels = (ncolors-1)*findgen(21)/20.0 + 1

    contour, reform(AMIEData(iter,hc_,*,LatLoc)),x,y,/follow, 		$
	xstyle = 5, ystyle = 5,						$
	xrange = [-mr,mr],yrange=[-mr,mr], levels = levels, 		$
	pos = pos, /noerase, /cell_fill, c_color = clevels

  ;  xyouts, pos(0)-0.01,pos(3)-0.01, amie_time_1(n),charsize=0.9, /norm

    plotmlt, mr, /no06, /no12
    oplot, J4x, J4y
    xyouts, (J4x(0)+J4x(0)*.18), (J4y(0)+J4y(0) *.18),'S' 
    pn = pnBase + 5
    get_position, ppp, space, sizes, pn, pos1

    pn = pnBase + 7
    get_position, ppp, space, sizes, pn, pos2

    pos(0) = pos1(0)
    pos(1) = pos1(1)
    pos(2) = pos2(2)
    pos(3) = pos1(3)

    pos([1,3]) = pos([1,3]) + space - 0.01
    pos([1,3]) = pos([1,3]) + fac*space

    plot, J4Time(loc)-stime,J4Data(2,loc), pos = pos,	 		$
	xstyle = 1, /noerase,/nodata,		$
	xtickname = xtickname, xtickv=xtickvalue, 			$
	xticks = xtickn, xminor = xminor, xtitle = xtitle,		$
	xrange = [s_time_range, e_time_range], 				$
	ytickname = strarr(20)+' '
    axis, yax=1, charsize=0.9

    xyouts, pos(0)-0.005, (pos(1)+pos(3))/2.0, 'Hall Conductance', $
  	/norm, alignment = 0.5, orient = 90, charsize = 0.75

   ; I modified this from Aarons code we originally wanted AveE here.
   ; here I use the Robinson formula (JGR, 87) to get DMSP HC.   
   DMSPHC = (18*J4AAveE(loc)^1.85/(16 + J4AAveE(loc) ^2))*SQRT(J4EFlux(loc))  
    oplot, J4Time(loc)-stime, AMIEHC(loc), linestyle = 2
    oplot, J4Time(loc)-stime, DMSPHC, linestyle = 1

  endif else begin

    print, "There are no data points in this hemisphere."

  endelse

endfor

closedevice

openw, 2, amie_file+'_metrics'

printf,2,nFiles
printf,2,nMetrics
printf,2,'% Diff in E-Flux'
printf,2,'Latitude Diff'
printf,2,'CC - w/AMIE'
printf,2,'CC - w/Ave'
printf,2,'CC Lat Diff'
printf,2,'nMag'
printf,2,'AE'
printf,2,'MLT'
printf,2,metrics
printf,2,MetricsTimes

close,2

end