;*****************************************************************************
 
pro plotct, ncolors, pos, maxmin, title, right=right, 		$
	color = color, reverse = reverse, bottom=bottom,        $
            everother = everyother, t3d=t3d
 
;******************************************************************************

    ; this is to make Gabor's stuff work....

    if (n_elements(ncolors) eq 4) then begin
      maxmin = pos
      pos = ncolors
      ncolors = 255
      right = 1
    endif

    xrange=!x.range & yrange=!y.range & !x.range=0 & !y.range=0

    if n_elements(right) eq 0 then right = 0 else right = right
    if n_elements(bottom) eq 0 then bottom = 0
    if n_elements(everyother) eq 0 then everyother = 0

    if n_elements(maxmin) lt 2 then maxmin2 = [0,maxmin] else maxmin2 = maxmin

    if n_elements(color) eq 0 then color_in = 0 else color_in = color

    if n_elements(reverse) eq 0 then reverse = 0 else reverse = 1

    if (bottom) then begin
        plot, maxmin2, [0,1], /noerase, pos = pos, 			$
          xstyle=5,ystyle=5, /nodata, $
          color = color_in
    endif else begin
        if not right then begin
            plot, maxmin2, /noerase, pos = pos, 			$
              xstyle=5,ystyle=1, /nodata, ytitle = title, $
              color = color_in,charsize=1.2
        endif else begin
              plot, maxmin2, /noerase, pos = pos, 			$
                    xstyle=5,ystyle=5, /nodata,charsize=1.2
              if (pos(3)-pos(1) lt 0.1) then yt = 1 else yt = 0
              axis, 1, ystyle=1, /nodata, ytitle = title, yax=1, 	$
                    charsize=1.2, color = color_in, yticks = yt
        endelse
    endelse

    x = [0.0,0.0,1.0,1.0,0.0]
    y = [0.0,1.0,1.0,0.0,0.0]

    maxi = max(maxmin)
    mini = min(maxmin)
    levels = findgen(29)/28.0*(maxi-mini) + mini
    clevels = (ncolors-1)*findgen(29)/28.0 + 1

    if (bottom) then begin
        plot, [0,ncolors], [0,9], /noerase, pos = pos, $
          xstyle=5,ystyle=5, /nodata
        array = findgen(ncolors-1,10)
        for i=0,9 do $
          array(*,i) = findgen(ncolors-1)/(ncolors-2)*(maxi-mini) + mini
    endif else begin
          plot, [0,9], [0,ncolors], /noerase, pos = pos, $
                xstyle=5,ystyle=5, /nodata
          array = findgen(10,ncolors-1)
          for i=0,9 do $
             array(i,*) = findgen(ncolors-1)/(ncolors-2)*(maxi-mini) + mini
    endelse

       contour, array, /noerase, /cell_fill, xstyle = 5, ystyle = 5, $
                levels = levels, c_colors = clevels, pos=pos

;    index = indgen(ncolors)
;    if reverse then index = (ncolors-1) - index
;    for i=0,ncolors-1 do                                      $
;      polyfill, x, float(index(i))+y, color = i

    if (bottom) then begin
       xtn = strarr(10)
       if (everyother) then xtn([1,3,5,7,9]) = ' '
        plots, [0.0,0.0], [0.0,9.0], color = color_in
        plots, [ncolors-1,ncolors-1], [0.0,9.0], color = color_in
        plot, maxmin2, [0,1], /noerase, pos = pos, 			$
          ystyle=5,xstyle=1, /nodata, 				$
          ytickname = strarr(10) + ' ', xticklen = 0.5, color = color_in, $
          xtickname = xtn, $
          xtitle = title
    endif else begin
        plots, [0.0,9.0], [0.0,0.0], color = color_in
        plots, [0.0,9.0], [ncolors-1,ncolors-1], color = color_in
        plot, maxmin2, /noerase, pos = pos, 			$
          xstyle=5,ystyle=1, /nodata, 				$
          ytickname = strarr(10) + ' ', yticklen = 0.25, color = color_in
    endelse

    !x.range=xrange & !y.range=yrange

  return
 
end
