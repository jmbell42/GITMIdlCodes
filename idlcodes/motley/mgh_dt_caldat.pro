;+
; NAME:
;   MGH_DT_CALDAT
;
; PURPOSE:
;   Like CALDAT but implemented as a function returning a
;   structure. It also has a different argument order and an optional
;   time-zone argument.
;
; CALLING SEQUENCE:
;   result = MGH_DT_CALDAT(dtjul, ZONE=zone)
;
; POSITIONAL PARAMETERS:
;   dtjul (input, numeric scalar or array)
;     Date & time in Julian days.
;
; KEYWORD PARAMETERS:
;   ZONE (input, numeric scalar or array)
;     Time zone in hours. Default is 0.
;
; RETURN VALUE:
;   The function returns a structure scalar or array, with the same
;   shape as the input, with tags YEAR, MONTH, DAY, HOUR,
;   MINUTE, SECOND and ZONE.
;
;###########################################################################
;
; This software is provided subject to the following conditions:
;
; 1.  NIWA makes no representations or warranties regarding the
;     accuracy of the software, the use to which the software may
;     be put or the results to be obtained from the use of the
;     software.  Accordingly NIWA accepts no liability for any loss
;     or damage (whether direct of indirect) incurred by any person
;     through the use of or reliance on the software.
;
; 2.  NIWA is to be acknowledged as the original author of the
;     software where the software is used or presented in any form.
;
;###########################################################################
;
; MODIFICATION HISTORY:
;   Mark Hadfield, 2000-08:
;     Written.
;   Mark Hadfield, 2001-05:
;     Added ZONE keyword.
;   Mark Hadfield, 2002-12:
;     Documentation improvements.
;   Mark Hadfield, 2005-01:
;     Result now has the same shape as the input.
;-

function MGH_DT_CALDAT, dtjul, ZONE=zone

   compile_opt DEFINT32
   compile_opt STRICTARR
   compile_opt STRICTARRSUBS
   compile_opt LOGICAL_PREDICATE

   if n_elements(zone) eq 0 then zone = 0.D0

   caldat, dtjul + zone/24.D0, month, day, year, hour, minute, second

   if size(dtjul, /N_DIMENSIONS) eq 0 then begin
      return, {year:year, month:month, day:day, hour:hour, minute:minute, $
               second:second, zone:zone}
   endif else begin
      result = replicate({year:0S, month:0S, day:0S, hour:0S, $
                          minute:0S, second:0S, zone:0.D0}, size(dtjul, /DIMENSIONS))
      result.year = year
      result.month = month
      result.day = day
      result.hour = hour
      result.minute = minute
      result.second = second
      result.zone = zone
      return, result
   endelse

end

