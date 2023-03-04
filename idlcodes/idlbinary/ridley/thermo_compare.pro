
filelist = findfile("-t *.save")
if (strlen(filelist(0)) eq 0) then filelist = findfile("-t *.dat")

filelist = ask('perturbation filename to plot',filelist(0))

filelist_base = ask('baseline filename to plot',filelist(0))

nfiles = 1
read_thermosphere_file, filelist, nvars, nalts, nlats, nlons, $
                        vars, data, rb, cb, bl_cnt, itime1

read_thermosphere_file, filelist_base, nvars_base, $
  nalts_base, nlats_base, nlons_base, vars_base, data_base, $
  rb_base, cb_base, bl_cnt_base, itime2

filename = filelist(0)

alt = reform(data(2,*,*,*)) / 1000.0
lat = reform(data(1,*,*,*)) / !dtor
lon = reform(data(0,*,*,*)) / !dtor

for i=0,nvars-1 do print, tostr(i)+'. '+vars(i)
sel = fix(ask('which var to plot','9'))

plotlog = ask('whether you want log or not (y/n)','n')
if (strpos(plotlog,'y') eq 0) then plotlog = 1 else plotlog = 0

psfile = filename+'.ps'
psfile = ask('ps file name',psfile)

for i=0,nalts-1 do print, tostr(i)+'. '+string(alt(2,2,i))
selset = fix(ask('which altitude to plot','0'))

smini = ask('minimum (0.0 for automatic)','0.0')
smaxi = ask('maximum (0.0 for automatic)','0.0')

plotvector = ask('whether you want vectors or not (y/n)','y')
if strpos(plotvector,'y') eq 0 then plotvector=1 else plotvector = 0

if (plotvector) then begin
  print,'-1  : automatic selection'
  factors = [1.0, 5.0, 10.0, 20.0, 25.0, $
             50.0, 75.0, 100.0, 150.0, 200.0]
  nfacs = n_elements(factors)
  for i=0,nfacs-1 do print, tostr(i)+'. '+string(factors(i)*10.0)
  vector_factor = fix(ask('velocity factor','-1'))
endif else vector_factor = 0

; cursor position variables, which don't matter at this point
cursor_x = 0.0
cursor_y = 0.0
strx = '0.0'
stry = '0.0'

;cnt1 is a lat/lon plot
cnt1 = 1

;cnt2 is a lat/alt plot
cnt2 = 0

;cnt3 is a lon/alt plot
cnt3 = 0

; yes is whether ghostcells are plotted or not:
yes = 0
no  = 1

; yeslog is whether variable should be logged or not:
if (plotlog) then begin 
  yeslog = 1
  nolog  = 0
endif else begin
  yeslog = 0
  nolog = 1
endelse

; yeswrite_cnt is whether we have to output to a ps file or not.
yeswrite_cnt = 1

; polar is variable to say whether we have polar plots or not
polar = 1

; npolar is whether we are doing the northern or southern hemisphere
npolar = 0

; MinLat is for polar plots:
MinLat = 40.0

; showgridyes says whether to plot the grid or not.
showgridyes = 0

;plotvectoryes says whether to plot vectors or not
plotvectoryes = plotvector

; number of points to skip when plotting vectors:
step = 2

; vi_cnt is whether to plot vectors of Vi
vi_cnt = 0

; vn_cnt is whether to plot vectors of Vn
vn_cnt = 1

cursor_cnt = 0

xrange = [0.0,0.0]

yrange = [0.0,0.0]

test = "V!Dn!N(east)"
for i=0,nvars-1 do begin
    var=strcompress(vars[i],/remove_all)
    tes = strcompress(test,/remove_all)
    result= STRCMP( var, tes,8 )
    if (result eq 1) then vneast_index = i
endfor

data_sub = data
data_sub(sel,*,*,*) = 100.0*(data_sub(sel,*,*,*) - data_base(sel,*,*,*))/data_base(sel,*,*,*)

data_sub(vneast_index,*,*,*) = $
  data_sub(vneast_index,*,*,*) - data_base(vneast_index,*,*,*)
data_sub(vneast_index+1,*,*,*) = $
  data_sub(vneast_index+1,*,*,*) - data_base(vneast_index+1,*,*,*)




thermo_plot,cursor_x,cursor_y,strx,stry,step,nvars,sel,nfiles,	  	  $
		     cnt1,cnt2,cnt3,yes,no,yeslog,  	  $
		     1-yeslog,nalts,nlats,nlons,yeswrite_cnt,$
		     polar,npolar,MinLat,showgridyes,	  $
		     plotvectoryes,vi_cnt,vn_cnt,vector_factor,	  $
		     cursor_cnt,data_sub,alt,lat,lon,	  $
		     xrange,yrange,selset,smini,smaxi,	  $
		     filename,vars, psfile, 0, 'mid', itime1


end
