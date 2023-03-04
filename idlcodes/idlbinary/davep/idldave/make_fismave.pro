if n_elements(month) eq 0 then month = 1
month = fix(ask('which month to do: ',tostr(month)))

if n_elements(year) eq 0 then year = 2000
year = fix(ask('which year to do: ',tostr(year)))

fismdir = '~/FISM/BinnedFiles/'+tostr(year)+'/'

ndays = d_in_m(year,month)
outfile = '~/FISM/BinnedFiles/Hourly/fismflux_hourly'+tostr(year)+ $
  chopr('0'+tostr(month),2)+'.dat'
close,/all
openw,2,outfile
printf,2,'#START'
for iday = 0, ndays - 1 do begin
    
    file = fismdir+'fismflux'+tostr(year)+chopr('0'+tostr(month),2)+ $
      chopr('0'+tostr(iday+1),2)+'.dat'
    fn = file_search(file)
    if strpos(fn,'dat') ge 0 then begin
        openr,1,fn
        
        temp = ' '
        readf,1,temp
        
        while strpos(temp,'#START') lt 0 do begin
            readf,1,temp
        endwhile
        
        nmins = 0
        itime = intarr(6)
        flux = fltarr(59)
        hourold = 0
        f = fltarr(60,59)

        while not(eof(1)) do begin
            
            readf, 1, itime,flux
            
            day = itime(2)
            hour = itime(3)

            if flux(0) ge 1 or flux(0) ne flux(0) then begin
                flux = fluxlast
            endif
            if hour eq hourold then begin
                f(nmins,*) = flux
                nmins = nmins + 1
            endif else begin
                
                printf,2,itime(0),itime(1),iday+1,hourold,30,0,total(f,1)/float(nmins)
                fluxlast = total(f,1)/float(nmins)
                f(*,*) = 0
                f(0,*) = flux
                nmins = 1
                hourold = hour
                dayold = day
            endelse
            
        endwhile
        printf,2,itime(0),itime(1),iday+1,hourold,30,0,total(f,1)/float(nmins)
        close,1
    endif
endfor
close,2
end   
