





;;;;; INPUT DAY OF YEAR ;;;;;;;;;;;;;;;;;;;;;;



day = 301



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        filename = DIALOG_PICKFILE(/READ,FILTER  = '*.sav') ; prompts file selection
        RESTORE, filename

       
        maxd= max(bs.doy)
        mind= min(bs.doy)
        year=bs.yy(0)
        
        yr=strcompress(year,/remove_all)

        index= where( bs.doy eq day AND bs.nmf2 ge 0 AND bs.hmf2 ge 200 , count)

        day=strcompress(day,/remove_all)

        orb_nmf2= bs.nmf2(index)
        orb_hmf2=bs.hmf2(index)
        morb=(bs.orbit(index))
        orb_lat=bs.glat(index)
        orb_time=bs.time(index)/3600000.
        origt=bs.time(index)
        orb_lon=bs.glon(index)
        orb_tec=bs.tec(index)        
        
        

        itime=fltarr(6,count)
        

        CALDAT,JULDAY(1,day,year),mon,da
 
        itime= [year,mon,da,0,0,0]
        c_a_to_r, itime, basetime
        

        result=morb[UNIQ(morb)]

        nresult= n_elements(result)

        ncolur= 256/nresult

        ncolura=indgen(ncolur)*ncolur +10


        mino=min(morb)

         morb=(bs.orbit(index))
         nsort = sort(orb_time)
         orb_time = orb_time(nsort)
         orb_nmf2 = orb_nmf2(nsort)
         orb_hmf2 = orb_hmf2(nsort)
         morb = morb(nsort)
         orb_lon = orb_lon(nsort)
         orb_lat = orb_lat(nsort)
         orb_tec = orb_tec(nsort) 
         origt = origt(nsort)

;        makect,'mid' 
         loadct, 39


        setdevice,'guvi_orbits_032704.ps', 'p',5

        !p.charsize = .8

        ppp =4
        space=.01
        pos_space,ppp,space,sizes, ny=ppp


;;;;;;; PLOT 1  ;;;;;;;;;;;;;;;;;;;;;;;;;;

        get_position,ppp,space,sizes,0,pos1,/rect
        pos=pos1
        pos(0)=pos(0)+.07

        Map_set,/Miller,/advance, title='Orbit for Day '+day+' of '+yr,pos=pos,/noerase,mlinestyle=0
        Map_continents
        Map_grid


        oplot,bs.glon(index),bs.glat(index), color=-1


        for i=0, nresult-1 DO BEGIN

            corbs= where( morb eq result(i))
           
            oplot, orb_lon(corbs), orb_lat(corbs), color=ncolura(i),psym=2, symsize=.1

        endfor

        !p.position=0


;;;;;;; PLOT 4  ;;;;;;;;;;;;;;;;;;;;;;

        get_position,ppp,space,sizes,3,pos4,/rect
        pos=pos4
        pos(0)=pos(0)+.07

        corbs=0


        plot,[min(orb_time),max(orb_time)],[200.0,max(orb_hmf2)],/nodata, $
              xtitle=' Universal Time (hrs)',ytitle='HFM2 (km)',pos=pos,/noerase, ystyle=1, xstyle=1


              for i=0, nresult-1 DO BEGIN

                  corbs= where( morb eq result(i))
 
                  oplot, orb_time(corbs), (orb_hmf2(corbs)), color=ncolura(i), min_value=200, $
                         psym=2, symsize=.1

              endfor


;;;;;;  PLOT 2  ;;;;;;;;;;;;;;;;;;;;;;

        get_position,ppp,space,sizes,1,pos2,/rect
        pos=pos2
        pos(0)=pos(0)+.07


        plot,[min(orb_time),max(orb_time)],[min(alog10(orb_tec/.0001/(10.^16))),$
                max(alog(orb_tec/.0001/(10.^16)))],/nodata, xstyle=1,ystyle=1,$
                xtickname=strarr(10)+' ',ytitle='TEC',pos=pos,/noerase


        corbs=0

        for i=0, nresult-1 DO BEGIN

            corbs= where( morb eq result(i))

            oplot, orb_time(corbs),alog10((orb_tec(corbs))/.0001/(10.^16)), color=ncolura(i), psym=2, symsize=.1


        endfor

;;;;;;  PLOT 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        !p.position=0


        get_position,ppp,space,sizes,2,pos3,/rect
        pos=pos3
        pos(0)=pos(0)+.07


        plot,[min(orb_time),max(orb_time)],[0,max(orb_nmf2)],/nodata,xstyle=1,ystyle=1,$
                xtickname=strarr(10)+' ',ytitle='NFM2 (/cm3)', pos=pos,/noerase


        corbs=0

        for i=0, nresult-1 DO BEGIN

            corbs= where( morb eq result(i))

            oplot, orb_time(corbs), (orb_nmf2(corbs)), color=ncolura(i),psym=2, symsize=.1

        endfor



        closedevice


;;;;;;; Write data to file for GITM SATELLITE FILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;

       ;;  limit=n_elements(orb_time)

;;         namef ='guvi_data_10_26_03.dat'
       
;;         openw, 10,namef

;;         namef= strcompress(namef)
;;         printf,10, filename
;;         printf,10,'#START'
;;         ;printf,10, format='(3x,A,11x,A, 9x, A, 10x,A, 10x,A,10x,A,6x,A,8x,A, 10x,A,8x,A)','YYYY','MM','DA', $
;;          ;          'HR','MI','SE' , 'MS','LON', 'LAT', 'ALT'

;;         da=0 

;;         for j=0, limit-1 DO BEGIN

       
;;                 realtime = basetime + origt(j)/1000.
;;                 c_r_to_a, itime, realtime
               


;; ;                printf,10, format='(2(4I),3(2I),9(4F20.4))',morb(j),year,mon, da, hr, min, sec, 0.00,( orb_lon(j)), $
;; ;                           orb_lat(j), 300.0 
;;                 printf,10, format='((I4), 6(I5),3(F10.4))',itime, 0.00,( orb_lon(j)), $
;;                            orb_lat(j), 300.0
         
         
;;         endfor

;;         close,10




     end 
