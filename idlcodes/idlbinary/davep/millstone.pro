PRO millstone
lats = fltarr(835)
lons = fltarr(835)

setdevice, '~/map.ps','l',5,.95
loadct, 39
map_set,/grid,/continent,limit=[10,-150,70,-40],/usa,latdel=2.5,londel=5

mhlon = 288.508
mhlat = 42.619

plots,mhlon,mhlat,psym=5,symsize=2,color=220

openr,1,'~/lats.dat'
readf,1,lats
close,1
openr,1,'~/lons.dat'
readf,1,lons
close,1

;lats = [63.33,63.89,64.16,64.16,63.91,63.37,62.62,61.64,60.49,59.11,57.65,56.03,54.38,52.64,50.89,49.08,47.19,45.40,43.52,41.80,39.97,42.38,22.49,25.94,27.81,29.68,31.48,33.29,34.79,40.08,42.38,45.09,50.30,51.80,54.79,56.58,59.06,64.08,63.35,63.89,64.16,61.16,63.91,63.39,62.61,61.67,60.44,59.11,57.64,56.05,54.43,52.68,50.84,49.02,47.19,45.39,43.52,41.75,39.91,42.38,25.94,27.80,29.62,31.49,33.27,34.79,39.9,42.38,45.09,50.30,51.77,54.81,56.58,59.06,64.08,63.33,63.89,64.16,64.16,63.90,63.48,62.63,61.63,60.45,59.11,57.69,56.04,54.43,52.69,50.84,49.05,47.24,45.34,43.52,41.75,39.91,42.38,25.93,27.81,29.60,31.48,33.24,34.79,39.90,42.38,45.10,50.30,51.79,54.79]



;lons = [-61.10,-65.20,-69.19,-73.57,-77.55,-81.65,-85.28,-88.58,-91.47,-94.05,-96.15,-97.85,-99.17,-100.16,-100.84,-101.27,-101.45,-101.40,-101.14,-100.74,-100.11,-71.48,-74.10,-73.72,-73.51,-73.30,-73.07,-72.85,-72.65,-71.89,-71.48,-71.06,-70.02,-69.67,-68.92,-68.41,-67.61,-65.58,-61.20,-65.21,-69.32,-73.55,-77.63,-81.53,-85.51,-91.56,-94.05,-94.11,-97.83,-99.12,-100.14,-100.85,-101.27,-101.44,-101.40,-101.14,-100.73,-100.11,-71.48,-73.72,-73.51,-73.30,-73.07,-72.85,-72.65,-71.89,-71.48,-71.06,-70.02,-59.69,-68.92,-68.41,-67.61,-65.58,-61.20,-65.21,-69.32,-73.55,-77.63,-81.53,-85.33,-88.51,-91.56,-94.05,-96.11,-97.83,-99.12,-100.14,-100.85,-101.27,-101.44,-101.40,-101.14,-100.73,-100.11,-71.48,-73.72,-73.51,-73.30,-73.07,-73.85,-72.65,-71.92,-71.48,-71.06,-70.02,-69.68,-68.91,-68.41,-69.67,-65.58,-61.10,-65.20,-69.37,-73.54,-77.69,-80.98,-85.23,-88.60,-91.54,-94.04,-96.06,-97.83,-99.12,-100.14,-100.8,-101.27,-101.44,-101.4,-101.15,-100.73,-100.11,-71.48,-73.72,-73.51,-73.30,-73.07,-72.85,-72.65,-73.82,-71.48,-71.19,-70.02,-69.68,-68.92]
plots,lons,lats,psym = 2,color=30
closedevice
end