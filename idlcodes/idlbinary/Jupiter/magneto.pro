km_to_m = 1.0e3km_to_m = 1.0Rj = 71398.0 * km_to_mOmega = 2.0*!pi/(9.842*3600.0)Omega = 1.74e-4dlat = 1.0dlon = 5.0nlat = 180.0/dlatnlon = 360.0/dlon + 1n = nlat*nlonm = 12data = fltarr(m,n)openr,1,'magnetosphere.output'readf,1,dataclose,1gauss_to_tesla = 1.0e-4r0   = fltarr(nlon,nlat)lat0 = fltarr(nlon,nlat)lon0 = fltarr(nlon,nlat)L    = fltarr(nlon,nlat)late = fltarr(nlon,nlat)lone = fltarr(nlon,nlat)br   = fltarr(nlon,nlat)bt   = fltarr(nlon,nlat)bp   = fltarr(nlon,nlat)br_0   = fltarr(nlon,nlat)bt_0   = fltarr(nlon,nlat)bp_0   = fltarr(nlon,nlat)for i=0,nlat-1 do for j=0,nlon-1 do begin  index = i*nlon + j  r0(j,i)   = data(0,index)  lat0(j,i) = data(1,index)  lon0(j,i) = data(2,index)  L(j,i)    = data(3,index)  late(j,i) = data(4,index)  lone(j,i) = data(5,index)  br(j,i)   = data(6,index) * gauss_to_tesla  bt(j,i)   = data(7,index) * gauss_to_tesla  bp(j,i)   = data(8,index) * gauss_to_tesla  br_0(j,i)   = data(9,index) * gauss_to_tesla  bt_0(j,i)   = data(10,index) * gauss_to_tesla  bp_0(j,i)   = data(11,index) * gauss_to_teslaendforx0_north = (90.0-lat0)*cos((lon0-90.0)*!pi/180.0)y0_north = (90.0-lat0)*sin((lon0-90.0)*!pi/180.0)x0_south = (90.0+lat0)*cos((lon0-90.0)*!pi/180.0)y0_south = (90.0+lat0)*sin((lon0-90.0)*!pi/180.0)x = L*cos(lone*!pi/180.0) * Rjy = L*sin(lone*!pi/180.0) * Rjb = sqrt(br^2 + bt^2 +bp^2)cm_to_m = 1.0 / (100.0)vp = Rj*Omega*L        ; L < 16.2a = 2.0e7 * cm_to_mb = 8.9e5 * cm_to_mloc = where(L ge 16.2,count)       ; 16.2 < L < 50 ????????if count gt 0 then vp(loc) = a + b*(L(loc) - 16.2)loc = where(L gt 50.0,count)if count gt 0 then vp(loc) = 5.0e7 * cm_to_m; now subtract off the corotation potential field:loc = where(L gt 0.0,count)if count gt 0 then vp(loc) = vp(loc) - 1.0*Rj*Omega*L(loc)Er = bt*vpEt = -1.0*br*vpRe = L*RjTheta = late*!pi/180.0Phi = fltarr(nlon,nlat)for i=nlat/2,nlat-1 do begin  for j=0,nlon-1 do begin     r1 = sqrt(x(j,i)^2 + y(j,i)^2.0)     r0 = sqrt(x(j,i-1)^2 + y(j,i-1)^2.0)     if (r1 lt 100.0*Rj) and (r0 lt 100.0*Rj) then begin      phi(j,i) = phi(j,i-1) - Er(j,i)*(r1 - r0) - Et(j,i)*((r1 + r0)/2.0)*(Theta(j,i) - Theta(j,i-1))     endif else phi(j,i) = phi(j,i-1)  endforendforfor i=nlat/2,0,-1 do begin  for j=0,nlon-1 do begin     r1 = sqrt(x(j,i)^2 + y(j,i)^2.0)     r0 = sqrt(x(j,i+1)^2 + y(j,i+1)^2.0)     if (r1 lt 100.0*Rj) and (r0 lt 100.0*Rj) then begin      phi(j,i) = phi(j,i+1) - Er(j,i)*(r1 - r0) - Et(j,i)*((r1 + r0)/2.0)*(Theta(j,i) - Theta(j,i+1))     endif else phi(j,i) = phi(j,i+1)  endforendfortop = 90bottom = 90loc = where(L lt 0.0)phi(loc) = min(phi)max_iter = 10;loc = where(l lt 0,count);if count gt 0 then phi(loc) = mean(phi)  ;moment(phi)    ;mean(phi);phi(*,0:bottom-1) = 0.0;phi(*,top+1:nlat-1) = 0.0phi_old = phifor k = 0,max_iter-1 do begin; north  for j = 1,nlon-2 do for i=top+1,nlat-2 do $    if l(j,i) lt 0.0 or i gt nlat-1 then                   $      phi(j,i) = (phi(j-1,i)+phi(j+1,i)+phi(j,i-1)+phi(j,i+1))/4.0  j = 0  for i=top+1,nlat-2 do $    if l(j,i) lt 0.0 or i gt nlat-1 then                   $    phi(j,i) = (phi(nlon-2,i)+phi(j+1,i)+phi(j,i-1)+phi(j,i+1))/4.0  j = nlon-1  for i=top+1,nlat-2 do $    if l(j,i) lt 0.0 or i gt nlat-1 then                   $    phi(j,i) = (phi(j-1,i)+phi(1,i)+phi(j,i-1)+phi(j,i+1))/4.0  phi(*,nlat-1) = mean(phi(*,nlat-2)); south  for j = 1,nlon-2 do for i=1,bottom-1 do $    if (l(j,i) lt 0.0 or l(j,i) gt 70.0) or i lt 1 then                   $    phi(j,i) = (phi(j-1,i)+phi(j+1,i)+phi(j,i-1)+phi(j,i+1))/4.0  j = 0  for i=1,bottom-1 do $    if l(j,i) lt 0.0 or l(j,i) gt 70.0 or i lt 1 then                   $    phi(j,i) = (phi(nlon-2,i)+phi(j+1,i)+phi(j,i-1)+phi(j,i+1))/4.0  j = nlon-1  for i=1,bottom-1 do $    if l(j,i) lt 0.0 or l(j,i) gt 70.0 or i lt 1 then                   $    phi(j,i) = (phi(j-1,i)+phi(1,i)+phi(j,i-1)+phi(j,i+1))/4.0  phi(*,0) = mean(phi(*,1))  print, mean(abs(phi-phi_old))  phi_old = phiendforen = phiee = phien(*,1:nlat-2) = -1.0*(phi(*,2:nlat-1)-phi(*,0:nlat-3))/(2.0*dlat*!pi/180.0)/Rjen(*,0) = -1.0*(phi(*,1)-phi(*,0))/(1.0*dlat*!pi/180.0)/Rjen(*,nlat-1) = -1.0*(phi(*,nlat-1)-phi(*,nlat-2))/(1.0*dlat*!pi/180.0)/Rjsintheta = cos(lat0*!pi/180.0)loc = where(sintheta lt 0.1)sintheta(loc) = 0.1ee(1:nlon-2,*) = -1.0*(phi(2:nlon-1,*)-phi(0:nlon-3,*))/(2.0*dlon*!pi/180.0)/(Rj*sintheta(1:nlon-2,*))ee(0,*) = -1.0*(phi(1,*)-phi(0,*))/(1.0*dlon*!pi/180.0)/(Rj*sintheta(0,*))ee(nlon-1,*) = ee(0,*)e_total2 = (ee^2 + en^2)b_squared = (br_0^2.0 + bt_0^2.0 + bp_0^2.0)vn =      br_0*ee/b_squared       ve = -1.0*br_0*en/b_squared     openw,11,'JTGCM.input'printf,11,'   Lat.  Long.           Br           Bt           Bp    Potential           Vn           Ve'for i=0,nlat-1 do for j=0,nlon-1 do begin  printf,11,lat0(j,i), lon0(j,i), br_0(j,i), bt_0(j,i), bp_0(j,i), 	$            phi(j,i), vn(j,i), ve(j,i), format='(2F7.2,6E13.5)'endforclose,11aurora_lon = [5.7,35.0,70.0,112.0,129,132,136,142,147,152,158,163,169, $             172,177,183,189,195,200,205,207,211,216,219,223,228,231,  $             235,240,243,247,276.5,301.4,336.0]aurora_lat = [87.7,87.5,85.9,78.1,71.5,68.8,67.0,64.1,60.7,58.0,56.5,  $              55.8,55.5,55.8,56.6,57.9,59.0,60.0,61.9,63.1,63.7,64.7,  $              66.4,67.2,68.9,70.8,71.9,73.0,75.0,76.0,77.0,82.9,85.9,87.5]print, n_elements(aurora_lon)print, n_elements(aurora_lat)a_x = (90.0 - aurora_lat)*cos(aurora_lon*!pi/180.0 - !pi/2)a_y = (90.0 - aurora_lat)*sin(aurora_lon*!pi/180.0 - !pi/2)fake_lon = findgen(nlon)*5fake_lat = 88.0 - 32.0*exp(-1.0*(fake_lon-170.0)^2.0/4000.0)a_x = (90.0 - fake_lat)*cos(fake_lon*!pi/180.0 - !pi/2)a_y = (90.0 - fake_lat)*sin(fake_lon*!pi/180.0 - !pi/2)ped = fltarr(nlon,nlat)width = 2.0p_min = 1.0p_max = 23.0quarter = p_max/4.0for i=0,nlon-1 do begin  ped(i,*) = p_min + (p_max-p_min)*exp(-1.0*(fake_lat(i)-lat0(i,*))^2.0/width^2.0)  if (lon0(i,nlat-5) gt 170.0) then begin    loc = where(lat0(i,*) gt fake_lat(i) and ped(i,*) lt quarter,count)    if count gt 0 then ped(i,loc) = quarter  endifendforr_north = sqrt(x0_north^2 + y0_north^2)r_south = sqrt(x0_south^2 + y0_south^2)mr = 40.0setdevice,'potential.ps', 'p', 4ppp = 2space = 0.05pos_space, ppp, space, sizesget_position, ppp,space,sizes,0,posloc = where(r_north(0,*) le mr and r_north(0,*) gt dlat)contour, phi(*,loc),x0_north(*,loc),y0_north(*,loc),/follow, 		$         nlevels=10, xstyle=5, ystyle = 5, pos = pos,			$         xrange = [-mr,mr], yrange = [-mr,mr]plotmlt, mr, /longlnew = lloc = where(lnew lt 0)lnew(loc) = 76.0loc = where(r_north(0,*) le mr and r_north(0,*) gt dlat)contour,lnew(*,loc),x0_north(*,loc),y0_north(*,loc),   $         nlevels=1, xstyle=5, ystyle = 5, pos = pos,   $         xrange = [-mr,mr], yrange = [-mr,mr],levels=[75],/noerase,	$	thick = 5get_position, ppp,space,sizes,1,posloc = where(r_south(0,*) le mr and r_south(0,*) gt dlat)contour, phi(*,loc),x0_south(*,loc),y0_south(*,loc),/follow, 		$         nlevels=10, xstyle=5, ystyle = 5, pos = pos,			$         xrange = [-mr,mr], yrange = [-mr,mr], /noeraseplotmlt, mr, /longlnew = lloc = where(lnew lt 0)lnew(loc) = 76.0loc = where(r_south(0,*) le mr and r_south(0,*) gt dlat)contour,lnew(*,loc),x0_south(*,loc),y0_south(*,loc),   $         nlevels=1, xstyle=5, ystyle = 5, pos = pos,   $         xrange = [-mr,mr], yrange = [-mr,mr],levels=[75],/noerase,	$	thick = 5closedevicesetdevice,'electric.ps', 'p', 4ppp = 2space = 0.05pos_space, ppp, space, sizesget_position, ppp, space, sizes, 0, posloc = where(r_north(0,*) le mr and r_north(0,*) gt dlat);contour, sqrt(e_total2(*,loc)),x0_north(*,loc),y0_north(*,loc),/follow, $;         nlevels=10, xstyle=5, ystyle = 5, pos = pos,			$;         xrange = [-mr,mr], yrange = [-mr,mr]contour, ee(*,loc),x0_north(*,loc),y0_north(*,loc),/follow, $         nlevels=10, xstyle=5, ystyle = 5, pos = pos,			$         xrange = [-mr,mr], yrange = [-mr,mr]plotmlt, mr, /longget_position, ppp, space, sizes, 1, poscontour, en(*,loc),x0_north(*,loc),y0_north(*,loc),/follow, $         nlevels=10, xstyle=5, ystyle = 5, pos = pos,			$         xrange = [-mr,mr], yrange = [-mr,mr], /noeraseprint, mm(en(*,loc))plotmlt, mr, /longclosedevicesetdevice, 'velocity.ps', 'p', 4get_position, ppp, space, sizes, 0, posfactor = max(abs([vn,ve]))/30.0step = 2plot, [-mr,mr],[-mr,mr], /nodata, ystyle = 5, xstyle = 5, pos = pos  for i =0,nlat-1,step do begin      la = lat0(0,i)      if (90-la lt mr) then begin          for j =0,nlon-1,step do begin              lo = lon0(j,i)              ux = ve(j,i)/factor              uy = vn(j,i)/factor                  x = (90.0 - la) * cos(lo*!pi/180.0 - !pi/2.0)                  y = (90.0 - la) * sin(lo*!pi/180.0 - !pi/2.0)                  ulo = ux                  ula = uy                  ux = - ula * cos(lo*!pi/180.0 - !pi/2.0)  $                       - ulo * sin(lo*!pi/180.0 - !pi/2.0)                  uy = - ula * sin(lo*!pi/180.0 - !pi/2.0) $                       + ulo * cos(lo*!pi/180.0 - !pi/2.0)              ;ux is the eastward welocity (neutral or ion)              ;uy is the northward velocity (neutral or ion)              if (sqrt(ux^2+uy^2) gt 0.5) then begin                oplot,[x],[y],psym = 4, color = 0                oplot,[x,x+ux],[y,y+uy], color = 0              endif          endfor      endif  endforplotmlt, mr, /longget_position, ppp, space, sizes, 1, pos;makect, 'mid';loc = where(r_south(0,*) le mr and r_south(0,*) gt dlat);contour, phi(*,loc),x0_south(*,loc),y0_south(*,loc),/follow, 		$;         nlevels=30, xstyle=5, ystyle = 5, pos = pos,			$;         xrange = [-mr,mr], yrange = [-mr,mr], /noerase, /cell_fillplot, [-mr,mr],[-mr,mr], /nodata, ystyle = 5, xstyle = 5, pos = pos,/noerase  for i =0,nlat-1,step do begin      la = 90.0+lat0(0,i);print, la,mr      if (la lt mr) then begin          for j =0,nlon-1,step do begin              lo = lon0(j,i)              ux = ve(j,i)/factor              uy = -vn(j,i)/factor ; this is negative because - Vn                                    ;points toward the pole...              x = (la) * cos(lo*!pi/180.0 - !pi/2.0)              y = (la) * sin(lo*!pi/180.0 - !pi/2.0)              ulo = ux              ula = uy              ux = - ula * cos(lo*!pi/180.0 - !pi/2.0)  $                - ulo * sin(lo*!pi/180.0 - !pi/2.0)              uy = - ula * sin(lo*!pi/180.0 - !pi/2.0) $                + ulo * cos(lo*!pi/180.0 - !pi/2.0)              ;ux is the eastward welocity (neutral or ion)              ;uy is the northward velocity (neutral or ion)              if (sqrt(ux^2+uy^2) gt 0.5) then begin                  oplot,[x],[y],psym = 4, color = 0                  oplot,[x,x+ux],[y,y+uy], color = 0              endif          endfor      endif  endforplotmlt, mr, /longclosedevicesetdevice,'pedersen.ps'readct,ncolors,'white_blue.ct'loc = where(r_north(0,*) le mr and r_north(0,*) gt dlat)maxi = max(ped(*,loc))mini = min(ped(*,loc))range = maxi-miniclevels = float(ncolors-1)*findgen(30)/29.0 + 1levels = (range)*findgen(30)/29.0 + minicontour, ped(*,loc),x0_north(*,loc),y0_north(*,loc),/follow, 	$         levels=levels, c_colors=clevels, xstyle=5, ystyle = 5, pos = pos,$         xrange = [-mr,mr], yrange = [-mr,mr], /cell_fillcontour, ped(*,loc),x0_north(*,loc),y0_north(*,loc),/follow, 	$         levels=[4.0, 8.0, 12.0, 16.0], xstyle=5, ystyle = 5, pos = pos,$         xrange = [-mr,mr], yrange = [-mr,mr], /noeraseplotmlt, mr, /longplotct, ncolors, [pos(2)+0.05,pos(1),pos(2)+0.1,pos(3)], [mini,maxi], /right, $	'Pedersen Conductance (mhos)'closedevicesetdevice,'joule.ps'readct,ncolors,'white_red.ct'joule = e_total2*pedmaxi = 20.0mini = 0.0range = maxi-miniclevels = float(ncolors-1)*findgen(30)/29.0 + 1levels = (range)*findgen(30)/29.0 + minilevels2 = (range)*findgen(5)/4.0 + minicontour, joule(*,loc),x0_north(*,loc),y0_north(*,loc),/follow, 	$         levels=levels, c_colors=clevels, xstyle=5, ystyle = 5, pos = pos,$         xrange = [-mr,mr], yrange = [-mr,mr], /cell_fillcontour, joule(*,loc),x0_north(*,loc),y0_north(*,loc),/follow, $         levels=levels2, xstyle=5, ystyle = 5, pos = pos,		$         xrange = [-mr,mr], yrange = [-mr,mr], /noeraseplotmlt, mr, /longplotct, ncolors, [pos(2)+0.05,pos(1),pos(2)+0.1,pos(3)], [mini,maxi], /right, $	'Joule Heating (W/m!E2!N)'closedevice;prompt_for_next;loc = where(r_south(0,*) le mr and r_south(0,*) gt dlat);contour, phi(*,loc),x0_south(*,loc),y0_south(*,loc),/follow, 		$;         nlevels=10, xstyle=5, ystyle = 5, pos = pos,			$;         xrange = [-mr,mr], yrange = [-mr,mr];plotmlt, mr, /long;loc = where(r_south(0,*) le mr and r_south(0,*) gt dlat);contour, lnew(*,loc),x0_south(*,loc),y0_south(*,loc), 		$;         nlevels=1, xstyle=5, ystyle = 5, pos = pos,			$;         xrange = [-mr,mr], yrange = [-mr,mr],levels=[75], /noerase,	$;	thick = 5;prompt_for_next;contour, e_total2(*,loc),x0_south(*,loc),y0_south(*,loc),/follow, 	$;         nlevels=10, xstyle=5, ystyle = 5, pos = pos,			$;         xrange = [-mr,mr], yrange = [-mr,mr]end