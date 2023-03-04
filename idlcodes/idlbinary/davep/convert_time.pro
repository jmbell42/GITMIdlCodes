function convert_time,currenttime,longitude

if longitude lt 0 then longitude = longitude + 360
longitude = longitude * !dtor
Mars_RP = 88775.0 ;seconds
Mars_hoursperday = Mars_RP/3600.0
MarsVernalTime = [1998,7,14,16,0,0]
Mars_DPY = 670.0
Mars_SPY = Mars_DPY*Mars_RP

;Earth_RP = 24.0*3600.0
;Earth_hoursperday =Earth_RP/3600.0
;EarthVernalTime = [1999,3,21,0,0,0]
;Earth_DPY = 325.25
;Earth_SPY = Earth_DPY * Earth_RP

c_a_to_r, MarsVernalTime,mVernalTime

dtime = currenttime - mvernaltime
iday = fix(dtime/Mars_RP)
utime = (dtime/Mars_RP - iday) * Mars_RP

localtime = (UTime/3600.0 + $
       Longitude * Mars_HoursPerDay / (2*!Pi)) mod Mars_HoursPerDay

return, localtime
end


