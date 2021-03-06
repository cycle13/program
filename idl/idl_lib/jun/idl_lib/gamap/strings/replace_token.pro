; $Id: replace_token.pro,v 1.1.1.1 2007/07/17 20:41:48 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REPLACE_TOKEN (function)
;
; PURPOSE:
;        Replaces occurrences of tokens with text. Can also
;        be used to expand wildcards with a name list.
;
; CATEGORY:
;        Strings
;
; CALLING SEQUENCE:
;        RESULT = REPLACE_TOKEN( STR, TOKEN, TEXT, [, Keywords ] )
;
; INPUTS:
;        STR -> The string to be searched for tokens. This must be
;             a scalar string.
; 
;        TOKEN -> A string or string array containing the token text
;             *OR* a structure. If TOKEN is a structure, the tag
;             names will be used as Tokens and the tag values will
;             be converted to string and used as TEXT.  TOKEN is 
;             case-insensitive and will always be used as uppercase.
;
;        TEXT -> A string or string array containing the replacement 
;             text. TEXT may be some other type than string on input. 
;             In this case it will be returned as string and formatted 
;             according to the optional FORMAT keyword.  If TOKEN is 
;             provided as a structure, TEXT will return the (formatted)
;             tag values as strings.  TOKEN and TEXT must have the same 
;             number of elements with one exception: If TOKEN contains 
;             only one element while TEXT is an array, the result will 
;             be a string array where each string has TOKEN replaced 
;             with the corresponding TEXT value (wildcard replacement). 
;             [see example 7]
;
; KEYWORD PARAMETERS:
;        DELIMITER  -> The delimiter character for TOKEN.  Default is 
;             '%'.  The delimiter will be automatically appended to the
;             beginning and end of TOKEN if not already there.
;
;        COUNT -> Number of tokens that were replaced. If TOKEN has 
;             more than one element or tag, COUNT will be an integer 
;             array.
;
;        VERBOSE -> Will print a warning message if no tokens are found.
;
;        FORMAT -> A string or string array containing format 
;            specifications for each element of TEXT or each tag of 
;            the TOKEN structure. If FORMAT contains only one element, 
;            this will be used throughout. For wildcard replacement, 
;            the default format is I14 (number will be trimmed).
;
;        TFORMAT -> (type format) If TOKEN is provided as a structure, 
;            it may contain data of various types. You can use TFORMAT 
;            to specify a format code for each data type (see IDL SIZE
;            function) instead of each tag number as with the FORMAT 
;            keyword. TFORMAT should contain at least 6 elements to 
;            allow formatting of double precision data, or 8 elements 
;            if you want to output complex data.
;
; OUTPUTS:
;        RESULT -> String with replaced text.  If TOKEN is a single 
;            string and TEXT is an array, then the result is an array 
;            with N(text) elements.  In case of errors, an empty string
;             is returned.
;
; SUBROUTINES:
;        External Subroutines Used:
;        ========================================
;        CHKSTRU (function)   STRRIGHT (function)
; 
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) The original input string (STR) is not altered.
;
;        (2) REPLACE_TOKEN will search for and replace multiple
;            occurrences of the same token in the input string (STR).
;
;        (3) Use DELIM='' for wildcard replacement.
;
;        (4) If no tokens are found in the input string, then
;            REPLACE_TOKEN returns the original input string (STR)
;            as the value of the function.  
;
;        (5) The use of structures for TOKEN allows for different
;            data types.
;
; EXAMPLE:
;        (1)
;        STR     = 'Hello, My Name is %NAME% and %NAME%.'
;        NEWSTR  = REPLACE_TOKEN( Str, 'NAME', 'Robert' )
;        PRINT, NEWSTR
;           Hello, my name is Robert and Robert.
;
;             ; Replace multiple tokens in the input string
;
;        (2) 
;        STR   = 'His name is %NAME% and he lives in %STREET%, %CITY%'
;        TOKEN = { NAME   : 'Henry', $
;                  STREET : '29 Oxford St.', $
;                  CITY   : 'Cambridge, MA',   $
;                  ZIP    : '02138' }
;        PRINT, REPLACE_TOKEN( STR, TOKEN )
;           His name is Henry and he lives in 
;           29 Oxford St., Cambridge, MA
;           
;           ; Use a structure to replace several items at once
;           ; (Note: ZIP code is not used!)
;
;        (3) 
;        STR = 'His name is NAME and he lives in STREET, CITY'
;        PRINT, REPLACE_TOKEN( STR, TOKEN, DELIM='' )
;           His Henry is Henry and he lives in ...
;
;             ; Use of an empty delimiter (same TOKEN as above)
;             ; (Exercise: what went wrong ?)
;
;        (4) 
;        STR = 'The date is 2003/01/01.'
;        PRINT, REPLACE_TOKEN( STR, '2003', 2005', DELIM='' )
;           The date is 2005/01/01.
;
;             ; Another use of an empty delimiter
;             ; (very useful for switching dates/times!!!)
;
;        (5) 
;        STR    = 'She earns %Salary%.'
;        FORMAT = '("$",g0.10)'
;        PRINT, REPLACE_TOKEN( STR, 'Salary', 39000., FORMAT=FORMAT )
;           She earns $39000.
;
;             ; Use of FORMAT
;
;        (6) 
;        STR     = '%Name% earns %Salary%.'
;        VAL     = { NAME   : 'Sally', $
;                    SALARY : 39000. }
;        TFORMAT = [ '(A)','','','','("$",g0.10)','("$",g0.10)' ]
;             ; (format codes for string, float and double)
;
;        PRINT, REPLACE_TOKEN( STR, VAL, TFORMAT=TFORMAT )
;           Sally earns $39000.
;
;             ; Use of TFORMAT
;
;        (7) 
;        FILEMASK = '~/data/cruise$$.dat'
;        CRUISES  = indgen(10)+1   
;        PRINT, REPLACE_TOKEN( FILEMASK, '$$', $
;                              CRUISES, DELIM='', FORMAT='(I2.2)' )
;           ~/data/cruise01.dat 
;           ~/data/cruise02.dat ...
;           ~/data/cruise10.dat
;
;             ; Wildcard replacement
;
; MODIFICATION HISTORY:
;        bmy, 23 Sep 1998: VERSION 1.00
;        bmy, 24 Sep 1998: - added VERBOSE keyword and improved comments
;        mgs, 24 Sep 1998: - improved error handling
;                          - TOKEN and TEXT may now be arrays
;                          - *or* TOKEN may be a structure
;                          - TEXT is trimmed
;                          - added FORMAT and TFORMAT keywords
;        mgs, 23 Dec 1998: - added wildcard (isarray) functionality
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - updated comments
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
; or phs@io.as.harvard.edu with subject "IDL routine replace_token"
;-----------------------------------------------------------------------


function Replace_Token, Str, Token, Text, Count=Count,  $
            Delimiter=Delimiter, Format=Format,  $
            TFormat=TFormat, Verbose=Verbose


   FORWARD_FUNCTION  chkstru, strright


   NewStr = ''    ; in case of errors
   Count = 0
 
   ;==================
   ; Error Checking
   ;==================
   if ( N_Elements( Str ) eq 0 ) then begin
      Message, 'STR must be passed to REPLACE_TOKEN!', /Continue
      return, NewStr
   endif

   if ( N_Elements( Token ) eq 0 ) then begin
      Message, 'TOKEN must be passed to REPLACE_TOKEN!', /Continue
      return, NewStr
   endif

   isstru = chkstru(Token)  ; token and text given as structure ?
   isarray = 0              ; must make array (only one token, but 
                            ; several text items)


   ;=======================
   ; Initialize variables
   ;=======================

   ; Set default token delimiter
   if ( N_Elements( Delimiter ) eq 0 ) then Delimiter = '%'

   ; Extract token names and values from structure
   ; or test validity of TOKEN and TEXT arrays
   ; Format TEXT elements
   if (isstru) then begin

      tmptok = tag_names(Token)
      text = strarr(n_tags(Token))
      for i=0,n_tags(Token)-1 do begin
          ; convert tag value to string using either TFormat or Format
          ; if given
          tagtype = size(Token.(i),/TYPE)
          if (n_elements(TFormat) gt tagtype) then begin
             text[i] = strtrim( string( Token.(i),  $
                          format=TFormat[tagtype] ),2 )
          endif else if (n_elements(Format) gt i) then begin
             text[i] = strtrim( string( Token.(i),  $
                          format=Format[i] ),2 )
          endif else $
             text[i] = strtrim(Token.(i),2)
      endfor

   endif else begin  $  ; if TOKEN and TEXT are string arrays,
                        ; make sure they have the same number of elements
      tmptok = strupcase(Token) 

      if (n_elements(Text) eq 0) then begin
         message,'Must supply TEXT!',/Cont
         return,NewStr
      endif

      if (n_elements(tmptok) ne n_elements(Text)) then begin
         if (n_elements(tmptok) gt 1) then begin
            message,'TOKEN and TEXT must have same number of elements!',/Cont
            return, NewStr
         endif else  $
            isarray = 1
      endif

      ; If no Format is provided, use empty string. This will use default
      if (n_elements(Format) eq 0) then $
         if (isarray) then Format = '(I14)' $
         else Format = ''

      ; If only one format string is given, expand the format array
      ; by replicating 
      if (n_elements(Format) eq 1 AND n_elements(Text) gt 1 $
        AND not isarray) then $
          tmpform = replicate(format,n_elements(Text)) $
      else $
          tmpform = Format

      if (n_elements(Format) ne n_elements(Text) AND not isarray) then begin
         message,'TEXT and FORMAT must have same number of elements!',/Cont
         return,NewStr
      endif

      ; Convert elements of TEXT into formatted strings
      tmptext = Text     ; make a copy because TEXT will change
      Text = string(Text)
      for i=0,n_elements(Text)-1 do begin
          if (isarray AND n_elements(Format) eq 1) then begin
             text[i] = strtrim( string( tmptext[i],  $
                          format=Format ),2 )
          endif else if (n_elements(Format) gt i) then begin
             text[i] = strtrim( string( tmptext[i],  $
                          format=Format[i] ),2 )
          endif else $
             text[i] = strtrim(tmptext[i],2)
      endfor
   endelse

   ; Initialize counter
   Count  = intarr(n_elements(tmptok))

   ; Look for delimiter in tokens and add them if necessary
   for i=0,n_elements(tmptok)-1 do begin
      ; front
      if (strmid(tmptok[i],0,1) ne Delimiter) then $
          tmptok[i] = Delimiter + tmptok[i]
      ; end
      if (strright(tmptok[i]) ne Delimiter) then $
          tmptok[i] = tmptok[i] + Delimiter
   endfor


   ; Initialize result string with original string
   ; or create string array as result
   if (isarray) then begin
      NewStr = replicate(Str, n_elements(text) )
      j0 = 0
      j1 = n_elements(text)-1
   endif else begin
      NewStr = Str
      j0 = 0
      j1 = 0
   endelse

   
   ;====================================================
   ; Loop over tokens and replace them
   ; If isarray == true then i will only have one pass
   ; so we effectively loop over text instead of token
   ;====================================================

   

   for i=0,n_elements(tmptok)-1 do begin

     for j=j0,j1 do begin

      ;=================================================
      ; Locate the position of the ith token in the string
      ; If there are more tokens, execute the while loop.
      ;=================================================
      Ind = StrPos( strupcase(NewStr[j]), tmptok[i] )
  
      while ( Ind ge 0 ) do begin

         ;===================================================
         ; If we have found a token, then replace it with text
         ; and increment the counter variable
         ;===================================================

         slen = strlen(NewStr[j]) + strlen(Text[max([i,j])]) 
         NewStr[j] = StrMid( NewStr[j], 0, Ind  ) +  $
                  Text[max([i,j])] + $
                  StrMid( NewStr[j], Ind+StrLen( tmptok[i] ), slen )
         
         if (j eq 0) then Count[i]  =  Count[i] + 1

         ;===========================================
         ; Look for the next token occurrence
         ; If not found, then will exit from the loop.
         ;===========================================
         Ind = StrPos( strupcase(NewStr[j]), tmptok[i] )
      endwhile
     endfor

      ; Display warning message if no occurences of this token 
      ; were found
      if (Count[i] eq 0 AND keyword_set(Verbose)) then begin
         message,'WARNING: Token '+tmptok[i]+' not found in string',/Cont
         message,STR,/Cont,/NoName
      endif

   endfor


   ;=============================================
   ; Return after all tokens have been replaced
   ;=============================================

   ; clean up Text and Count if they contained only one element
   if (n_elements(Text) eq 1) then begin
      Text = Text[0]
      Count = Count[0]
   endif


   return, NewStr
end
