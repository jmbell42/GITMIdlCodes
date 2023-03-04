nalts = 50
files = file_search('*.txt')
nfiles = n_elements(files)
nspecies = nfiles

print, 'Files to read: '
print,files

close,/all
temp = ' '
alt = fltarr(nalts)
nreacsmax = 20
production = strarr(nspecies,nreacsmax,nalts)
loss = strarr(nspecies,nreacsmax,nalts)
prates = fltarr(nspecies,nreacsmax,nalts)
lrates = fltarr(nspecies,nreacsmax,nalts)
ireacp = 0
ireacl = 0

for ifile = 0, nfiles - 1 do begin
   
    ialt = 0

    openr, 5, files(ifile)
    began = 0
    while not began do begin
        readf,5,temp
        if strpos(temp,'#BEGIN') ge 0 then began = 1
    endwhile

    while not eof(5) do begin
        readf,5,temp
        if strpos(temp,'#Altitude') ge 0 then begin
            arr = strsplit(temp,/extract)
            alt(ialt) = float(arr(1))/1000.
            ialt = ialt + 1
            ireacp = 0
            ireacl = 0
        endif else begin
            arr = strsplit(temp,/extract)
            narrs = n_elements(arr)
            case arr(0) of
                'S' : begin
                    production(ifile,ireacp,ialt-1) = strjoin(arr(2:narrs-2),' ')
                    prates(ifile,ireacp,ialt-1) = arr(narrs-1)
                    ireacp = ireacp + 1
                end 
                'L' : begin
                    loss(ifile,ireacl,ialt-1) = strjoin(arr(2:narrs-2),' ')
                    lrates(ifile,ireacl,ialt-1) = arr(narrs-1)
                    ireacl = ireacl + 1
                end 
            endcase
        endelse
    endwhile
    close,5

    len = strpos(files(ifile),'.txt')
    pname = strmid(files(ifile),0,len)+'prod.ps'

setdevice, pname,'p',5,.95
loadct,39
ppp=4
space = 0.01
pos_space, ppp, space, sizes

get_position, ppp, space, sizes, 0, pos, /rect
pos(0) = pos(0) + .05
pos(3) = pos(3) - .1
ytitle = 'Altitude (m)'
xtitle = strmid(files(ifile),0,len)+' Production and Loss'

xrange = mm([prates(ifile,*,*),lrates(ifile,*,*)])
xrange(0) = max([1.e5,xrange(0)])
syms = fltarr(ireacp)
lines = indgen(ireacp)
if ireacp gt 6 then begin
    syms(6:ireacp-1) = -sym(6)
    lines(6:ireacp-1) = indgen(ireacp-6)
endif
plot,prates(ifile,0,*),/nodata,pos = pos,ytitle=ytitle,yrange=[100,300],/xlog,$
  xtickname=strarr(10)+' ',xrange=xrange,/noerase
for ireac = 0, ireacp - 1 do begin
    oplot, prates(ifile,ireac,*),alt,linestyle = lines(ireac),psym=syms(ireac),symsize=.5
endfor


legend,production(ifile,0:ireacp-1,0),linestyle=lines,box=0,$
  pos=[pos(2) + .05,pos(3) - .1],/norm,psym=syms,symsize=fltarr(ireacp)+.5



get_position, ppp, space, sizes, 2, pos, /rect
pos(0) = pos(0) + .05
pos(1) = pos(1) + .1


syms = fltarr(ireacl)
lines = indgen(ireacl)
if ireacl gt 6 then begin
    syms(6:ireacl-1) = -sym(6)
    lines(6:ireacl-1) = indgen(ireacl-6)
endif
plot,lrates(ifile,0,*),/nodata,pos = pos,ytitle=ytitle,xtitle=xtitle,yrange=[100,300],/xlog,$
  xrange=xrange,/noerase
for ireac = 0, ireacl - 1 do begin
    oplot, lrates(ifile,ireac,*),alt,linestyle =  lines(ireac),psym=syms(ireac),symsize=.5
endfor


legend,loss(ifile,0:ireacl-1,0),linestyle=lines,box=0,pos=[pos(2) + .05,pos(3) - .1],$
  /norm,psym=syms,symsize=fltarr(ireacl)+.5
closedevice
endfor
     

        

end

