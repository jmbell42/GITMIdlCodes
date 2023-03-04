FUNCTION gettiming, string

len = strpos(string,'took')+4
arr = strmid(string,len,len+8)
timing = float(arr)
return, timing

end

nprocs = 32.
ntimings = 21
filelist = file_search("log*")
display, filelist
if n_elements(fn) eq 0 then fn = 0
fn = fix(ask('which file to read: ',tostr(fn)))

timingsavg = fltarr(ntimings)
timingsmax = fltarr(ntimings)
timings = strarr(ntimings)
timings(0) = 'GITM'
timings(1) = 'Initialize'
timings(2) = 'init_bo'
timings(3) = 'Message Pass'
timings(4) = 'Calc Rates'
timings(5) = 'Chapman Integrals'
timings(6) = 'Calc Efield'
timings(7) = 'Advance'
timings(8) = 'EUV Ionization'
timings(9) = 'Conduction'
timings(10) = 'Get AMIE Potential'
timings(11) = 'Set Grid'
timings(12) = 'Get Potential'
timings(13) = 'Aurora'
timings(14) = 'Ion Forcing'
timings(15) = 'Calc Chemistry'
timings(16) = 'Horizontal All'
timings(17) = 'Vertical All'
timings(18) = "UAM XFER Start"
timings(19) = "UAM XFER Finish"
timings(20) = "timestep horizontal"

temp = ' '
close, 5
openr, 5, filelist(fn)

while not eof(5) do begin
    readf, 5, temp
    
    if strpos(temp,'GITM') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(0) = timingsavg(0) + timing
        if timing gt timingsmax(0) then timingsmax(0) = timing
    endif
    if strpos(temp,'initialize') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(1) = timingsavg(1) + timing
        if timing gt timingsmax(1) then timingsmax(1) = timing
    endif
    if strpos(temp,'init_b0') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(2) = timingsavg(2) + timing
        if timing gt timingsmax(2) then timingsmax(2) = timing
    endif
    if strpos(temp,'Message Pass') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(3) = timingsavg(3) + timing
        if timing gt timingsmax(3) then timingsmax(3) = timing
    endif
    if strpos(temp,'calc_rates') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(4) = timingsavg(4) + timing
        if timing gt timingsmax(4) then timingsmax(4) = timing
    endif
    if strpos(temp,'chapman') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(5) = timingsavg(5) + timing
        if timing gt timingsmax(5) then timingsmax(5) = timing
    endif
    if strpos(temp,'calc_efield') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(6) = timingsavg(6) + timing
        if timing gt timingsmax(6) then timingsmax(6) = timing
    endif
    if strpos(temp,'advance') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(7) = timingsavg(7) + timing
        if timing gt timingsmax(7) then timingsmax(7) = timing
    endif
    if strpos(temp,'euv_ionization') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(8) = timingsavg(8) + timing
        if timing gt timingsmax(8) then timingsmax(8) = timing
    endif
    if strpos(temp,'conduction') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(9) = timingsavg(9) + timing
        if timing gt timingsmax(9) then timingsmax(9) = timing
    endif
    if strpos(temp,'AMIE') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(10) = timingsavg(10) + timing
        if timing gt timingsmax(10) then timingsmax(10) = timing
    endif
    if strpos(temp,'setgrid') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(11) = timingsavg(11) + timing
        if timing gt timingsmax(11) then timingsmax(11) = timing
    endif
    if strpos(temp,'getpotential') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(12) = timingsavg(12) + timing
        if timing gt timingsmax(12) then timingsmax(12) = timing
    endif
    if strpos(temp,'aurora') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(13) = timingsavg(13) + timing
        if timing gt timingsmax(13) then timingsmax(13) = timing
    endif
    if strpos(temp,'Ion Forcing') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(14) = timingsavg(14) + timing
        if timing gt timingsmax(14) then timingsmax(14) = timing
    endif
    if strpos(temp,'calc_chemistry') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(15) = timingsavg(15) + timing
        if timing gt timingsmax(15) then timingsmax(15) = timing
    endif
    if strpos(temp,'horizontal_all') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(16) = timingsavg(16) + timing
        if timing gt timingsmax(16) then timingsmax(16) = timing
    endif
    if strpos(temp,'vertical_all') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(17) = timingsavg(17) + timing
        if timing gt timingsmax(17) then timingsmax(17) = timing
    endif
 if strpos(temp,'UAM XFER Start') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(18) = timingsavg(18) + timing
        if timing gt timingsmax(18) then timingsmax(18) = timing
    endif
 if strpos(temp,'UAM XFER Finish') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(19) = timingsavg(19) + timing
        if timing gt timingsmax(19) then timingsmax(19) = timing
    endif
 if strpos(temp,'timestep horizontal') ge 0 then begin
        timing = gettiming(temp)
        timingsavg(20) = timingsavg(20) + timing
        if timing gt timingsmax(20) then timingsmax(20) = timing
    endif
endwhile
close,5

timingsavg = timingsavg/nprocs

for itiming = 0, ntimings - 1 do begin
    print, timings(itiming),":  Average = ",timingsavg(itiming), " Max = ", timingsmax(itiming),$
      format="(A15,A14,G10.4,A6,G10.4)"
endfor

end
