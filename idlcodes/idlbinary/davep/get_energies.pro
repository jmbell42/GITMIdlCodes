PRO  get_energies,energy,file,time,flaretime, hours,fism
;Calculates % increase in energy for specified hours before time
;compared to pre-flare energy


;yyyy-mm-dd
;hh-mm

nhours = n_elements(hours)
energy = fltarr(nhours)
benergy = fltarr(nhours)

for ihour = 0, nhours -1 do begin
    nh = hours(ihour)

    calc_previousenergy, e,be,file,time,flaretime,nh,fism
    energy(ihour) = e

    benergy(ihour) = be
endfor

et = energy
energy = (energy-benergy)/benergy*100.0
locs = where(energy lt 0,il)
if il gt 0 then energy(locs) = 0.0


end
