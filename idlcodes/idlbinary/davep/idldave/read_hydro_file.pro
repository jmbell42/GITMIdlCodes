PRO read_hydro_file, fn, data, nvars, nlons, nlats, nalts, lats, lons, alts, vars

IsDone = 0
close,1
openr, 1, fn

print, 'Reading file ',fn
while IsDone eq 0 do begin
    line = ' '
    
    readf, 1, line
    
    temp = strtrim(line,2)
    
    case temp of
        "NUMERICAL VALUES" : begin
            readf, 1, line
            temp = strsplit(line,/extract)
            nVars = temp(0)
            
            Vars = strarr(nVars)
            
            readf, 1, line
            temp = strsplit(line,/extract)
            nLats = temp(0)
            
            readf, 1, line
            temp = strsplit(line,/extract)
            nLons = temp(0)
            
            readf, 1, line
            temp = strsplit(line,/extract)
            nAlts = temp(0)
            
        end
        
        "VARIABLE LIST" : begin
            for iVar = 0, nVars - 1 do begin
                readf, 1, line
                temp = strsplit(line,/extract)
                Vars(iVar) = temp(1)
            endfor
            readf,1,line
            
            IsDone = 1
        end
        
        else: 
    endcase
    
    
endwhile

data = fltarr(nVars,nLons,nLats,nAlts)

for iAlt = 0, nAlts - 1 do begin
    for iLon = 0, nLons - 1 do begin
        for iLat = 0, nLats - 1 do begin
            
            readf, 1, line
            temp = strsplit(line,/extract)
            
            for iVar = 0, nVars - 1 do begin
                data(iVar,iLon,iLat,iAlt) = temp(iVar)
            endfor
            
        endfor
        
    endfor
    
endfor
alts = reform(data(2,0,0,*))
lats = reform(data(1,0,*,0))
lons = reform(data(0,*,0,0))

close,1


end
