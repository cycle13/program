; $Id: formstrlen.pro,v 1.1.1.1 2007/07/17 20:41:48 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        FORMSTRLEN (function)
;
; PURPOSE:
;        Return the (approximated) length of a string that 
;        contains Hershey formatting characters. If the string 
;        does not contain any formatting characters, the result
;        equals that of STRLEN, otherwise it will be shorter.
;        Hershey characters ('!'+1 char) are ignored, characters in
;        super or subscript mode are counted as of width 0.6
;
; CATEGORY:
;        Strings, Plotting
;
; CALLING SEQUENCE:
;        LEN = FORMSTRLEN( S )
;
; INPUTS:
;        S -> A string that may contain Hershey formatting characters.
;             As with STRLEN, S may be a string array.
;
; KEYWORD PARAMETERS:
;        none
;
; OUTPUTS:
;        A float(!) value that gives the "true" length of the string
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLES:
;        PRINT, FORMSTRLEN('C2H6')
;           4
;
;        PRINT, FORMSTRLEN('C!L2!NH!L6!N')
;           3.2
;
; MODIFICATION HISTORY:
;        mgs, 27 Oct 1998: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments 
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine formstrlen"
;-----------------------------------------------------------------------


function formstrlen,s
 
 
 ;  on_error,2
 
    ; Error checking
    if (n_elements(s) eq 0) then return,0
 
    if (size(s,/type) ne 7) then $
        message,'Argument is not of type string!'
 
 
    ; determine number of characters in string
    len = strlen(s)
 
    ; set byte constants
    bx = (byte('!'))[0]
    be = (byte('E'))[0]
    bu = (byte('U'))[0]
    bi = (byte('I'))[0]
    bl = (byte('L'))[0]
    bn = (byte('N'))[0]
 
    ; ================================================================ 
    ; loop through strings and determine "true" length
    ; normal characters = 1, super- subscript = 0.6,
    ; special (Hershey) characters = 0
    ; ================================================================ 

    result = -1.
    for ns = 0,n_elements(s)-1 do begin

       ; convert string to byte array
       bs = byte( strupcase(s[ns]) ) 
 
 
       ishersh = 0  ; Hershey mode
       issub = 0    ; super or subscript
 
       truelen = 0. ; result
      
       for i=0,len[ns]-1 do begin
          ; test if hershey character following
          if ( bs[i] eq bx ) then ishersh=1
    
          ; test for super or subscript following
          if ( ( bs[i] eq bu OR bs[i] eq be OR $
                 bs[i] eq bl OR bs[i] eq bi ) AND ishersh ) then $
             issub = 1  
 
          ; test for return to normal size
          if ( bs[i] eq bn AND ishersh ) then $
             issub = 0   
    
          ; if not in Hershey mode, add length of character
          if (not ishersh) then $
             if (issub) then truelen = truelen+0.6 else truelen = truelen+1. 
    
          ; reset Hershey mode
          if ( bs[i] ne bx ) then ishersh=0
       endfor
  
       result = [ result, truelen ] 
    endfor

    ; delete first (bogus) value
    result = result[1:*]

    ; make a scalar if scalar string was passed
    if (n_elements(result) eq 1) then result = result[0]

    return,result
    
end
 
