; $Id: ctm_read_gmao.pro,v 1.3 2007/08/06 18:53:35 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_READ_GMAO
;
; PURPOSE:
;        Reads GMAO I-6,(instantaneous 6h), A-6 (average 6h),
;        or A-3 (average 3-h) met field files, and constructs
;        a DATAINFO structure for each met field.
;
; CATEGORY:
;        GAMAP Internals
; 
; CALLING SEQUENCE:
;        Result = CTM_READ_GMAO( Ilun, FileInfo, DataInfo [, Keywords ] )
;
; INPUTS:
;        ILUN --> The name of the input file (or a file mask).
;             FILENAME is passed to OPEN_FILE.  If FILENAME is a null 
;             string or a file mask, then OPEN_FILE will open a
;             pickfile dialog box.
;
;        FILEINFO --> a (single) fileinfo structure containing information
;             about the (open) file (see CREATE3DFSTRU). FILEINFO also
;             contains information about the model which generated
;             the output (see CTM_TYPE)
;
;        DATAINFO --> a named variable that will contain an array of
;             structures describing the file content (see
;             CREATE3DHSTRU)
;
; KEYWORD PARAMETERS:
;        PRINT  -> if activated, print all headers found in the file
;
; OUTPUTS:
;        The function returns 1 if successful, and 0 otherwise. 
;
;        FILEINFO --> toptitle and modelinfo tags will be set
;
;        DATAINFO --> contains an array of named structures 
;             (see CREATE3DHSTRU) with all relevant information
;             from the punch file header and what is needed to find
;             and load the data.
;
; SUBROUTINES:
;        Internal Subroutines:
;        ================================================
;        CRG_GET_MODELINFO
;
;        External Subroutines Required:
;        ================================================
;        CHKSTRU  (function)     CTM_GRID      (function)
;        CTM_TYPE (function)     CREATE3DHSTRU (function)
;        
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) You must also add additional met field names to your
;        "tracerinfo.dat" file as is neccesary.  CTM_READ_GMAO looks
;        up met fields stored under the GAMAP categories "GMAO-2D"
;        and "GMAO-3D$".
;
;        (2) GEOS-4 met field files have an 8-char ident string 
;        of the format "G4 45 19", where:
;
;           (a) "G4" means that it is a GEOS-4 met field file/
;           (b) "45" is the resolution code (in this case 4x5).
;           (c) "19" is the number of met fields stored w/in the file.
;
;        CTM_READ_GMAO will now set the modeltype and resolution from
;        the information in this ident string.  For older met field 
;        types (e.g. GEOS-3) which do not have this ident string,
;        CTM_READ_GMAO will determine the modeltype and resolution 
;        from the filename and date.
;
; EXAMPLES:
;        FileInfo = CREATE3DFSTRU()   ; not required !
;        FName    = '/r/amalthea/N/scratch/bmy/960101.a3.4x5'
;        OPEN_FILE, FName, Ilun, /F77_Unformatted   
;        if ( Ilun gt 0 ) $
;            then Result = CTM_READ_GMAO( Ilun, FileInfo, DataInfo )
;        print,result
;
; MODIFICATION HISTORY:
;        bmy, 16 May 2000: GAMAP VERSION 1.45
;                          - adapted from original program "read_gmao"
;        bmy, 12 Jun 2000: - declare XYMD and XHMS as integers for
;                            GEOS-2 and GEOS-3 data
;        bmy, 28 Jul 2000: GAMAP VERSION 1.46
;                          - added GEOS-3 names to list of recognized fields
;                          - deleted a couple of field names we don't use 
;        bmy, 25 Sep 2000: - added new field: SLP (sea level pressure)
;        bmy, 08 Dec 2000: GAMAP VERSION 1.47
;                          - added new fields: TKE, RH, KH
;        bmy, 07 Mar 2001: - added new fields: CLDTMP, TPW
;        bmy, 25 Apr 2001: - added new fields: TAULOW, TAUMID, TAUHI
;        bmy, 26 Jul 2001: GAMAP VERSION 1.48
;                          - added new field: T2M
;        bmy, 15 Aug 2001: - added new field: OPTDEPTH
;        bmy, 06 Nov 2001: GAMAP VERSION 1.49
;                          - added new field: DELP
;                          - changed units from "mb" to "hPa"
;        bmy, 29 Jan 2002: GAMAP VERSION 1.50
;                          - added new field: GWET
;                          - removed obsolete code from 11/6/01
;        bmy, 01 May 2002: - added GWETTOP as synonym for GWET
;                          - now assign correct units for fvDAS/GEOS-4
;                            CLDMAS and DTRAIN fields: kg/m2/s
;                          - now assign correct units for fvDAS/GEOS-4
;                            PBL field: m (instead of hPa)
;        bmy, 17 Jul 2002: GAMAP VERSION 1.51
;                          - added PBLH, Z0M, Z0H fields for fvDAS/GEOS-4
;        bmy, 16 Dec 2002: GAMAP VERSION 1.52:
;                          - added new fvDAS fields: CMFDTR, CMFETR,
;                            ZMDU, ZMED, ZMEU, ZMMD, ZMMU, HKETA, HKBETA
;        bmy, 21 May 2003: GAMAP VERSION 1.53:
;                          - added T, U, V as synonyms of TMPU, UWND, VWND
;                          - added Q as a synonym of SPHU
;                          - removed CMFDTR, CMFETR fields
;                          - HKBETA is now #18; HKETA is now #19
;                          - updated comments
;                          - added EVAP field as tracer #28 
;                          - TGROUND and T2M are now tracers #29, #30
;                          - LAI is now tracer #31
;                          - PARDF, PARDR are now tracers #32, 33
;        bmy, 30 Jul 2003: - added TSKIN as a synonym for TGROUND
;        bmy, 12 Dec 2003: GAMAP VERSION 2.01
;                          - renamed to CTM_READ_GMAO to reflect the
;                            change of name from "DAO" to "GMAO".
;                          - GMAO binary files now have FILETYPE=104
;                          - Rewrote so that we don't have to hardwire
;                            met field names...it now gets the met
;                            field names from "tracerinfo.dat"
;                          - Now gets modeltype and resolution info
;                            from GEOS-4 ident string 
;                          - Added internal function CRG_GET_MODELINFO
;                            to generate the MODELINFO structure based
;                            on the filename and date. 
;                          - Improved error output if we can't find
;                            the tracer name
;  bmy & phs, 03 Aug 2007: GAMAP VERSION 2.10
;                          - Ident string value "56" now will specify
;                            a grid with 0.5 x 0.666 degree resolution
;                          - Ident string value "10" now will specify
;                            a grid with 1.0 x 1.0 degree resolution
;                          - Now don't reset ILUN for GEOS-5 files
;                          - Now call EXTRACT_FILENAME in CRG_GET_MODELINFO
;                            to get just the filename instead of the full
;                            path name.
;                          - Adjusted for GEOS-5 fields with LMX+1 levels
;                          - Bug fix: set null strings if GMAO-2D and/or
;                            GMAO-3D$ categories aren't found
;                          - Bug fix: change "gt" to "ge" in IF statements
;                            where NAME2D, NAME3D, etc. are defined.
;                          - Now use IS_EDGED
;                          - Added routine CRG_GET_HORZDIM to return NI,
;                            NJ, NL, FIRST for global or nested grids.
;  
;-
; Copyright (C) 2000-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_read_gmao"
;-----------------------------------------------------------------------


function CRG_Get_ModelInfo, Ilun, FileName, Name2D, Name3D

   ;====================================================================
   ; Function CRG_GET_MODELINFO returns a MODELINFO structure based
   ; on the filename and date.  This routine is only called when 
   ; CTM_READ_GMAO cannot find an ident string at the top of the met
   ; field file. (bmy, 12/12/03)
   ;
   ; CRG_GET_MODELINFO will only be called to determine if the met
   ; field file contains GEOS-1, GEOS-STRAT, or GEOS-3 data.  GEOS-4
   ; data contains an ident string with this information.
   ;====================================================================

   ; Test for resolution
   if ( StrPos( FileName, '4x5'  ) ge 0 ) then Res = [ 5.0,  4.0 ]
   if ( StrPos( FileName, '2x25' ) ge 0 ) then Res = [ 2.5,  2.0 ]
   if ( StrPos( FileName, '1x1'  ) ge 0 ) then Res = [ 1.0,  1.0 ]

   ; Get 1st 6 digits in FILENAME
   Date6 = Long( StrMid( Extract_FileName( FileName ), 0, 6 ) )

   ; Test for modeltype by date
   if ( Date6 lt 850101L ) then begin

      ;------------------
      ; GEOS-3 model
      ;------------------
      return, CTM_Type( 'GEOS3', Res=Res )

   endif else if ( Date6 ge 951201L AND Date6 lt 980101L ) then begin

      ;------------------
      ; GEOS-STRAT model
      ;------------------
      return, CTM_Type( 'GEOS_STRAT', Res=Res )
     
   endif else if ( Date6 ge 850101L AND Date6 lt 951201L ) then begin
      
      ;------------------
      ; GEOS-1 model
      ;------------------
      return, CTM_Type( 'GEOS1', Res=Res )

   endif

   ; Return failure
   return, -1
  
end

;------------------------------------------------------------------------------

pro CRG_Get_HorzDim, ModelInfo, GridInfo, I0, J0, NI, NJ, $ 
                     China=China, NAmer=NAmer, Europe=Europe
   
   ;==================================================================== 
   ; Internal routine CRG_GET_HORZDIM returns the proper values of 
   ; I0, J0 (the starting indices of lon & lat) and NI, NJ (the lon &
   ; lat extent of the data block).  These are needed to size the data 
   ; array properly when reading from the GMAO binary met field files. 
   ; (bmy, phs, 8/3/07)
   ;==================================================================== 

   ; Error check MODELINFO
   if ( not ChkStru( ModelInfo, [ 'NAME', 'RESOLUTION' ] ) ) $
      then Message, 'Not a valid MODELINFO structure!'

   ; Error check GRIDINFO
   if ( not ChkStru( GridInfo, [ 'IMX', 'JMX', 'LMX' ] ) ) $
      then Message, 'Not a valid GRIDINFO structure!'

   ; Keywords
   China  = Keyword_Set( China  )
   NAmer  = Keyword_Set( NAmer  )
   Europe = Keyword_Set( Europe )

   ; Get (lat,lon) at corners (lower left, upper right) of region
   ; Redefine these lon/lat limits if necessary.  Maybe at some
   ; later point we can move these to an input file where they
   ; can be more user-customizable. (bmy, phs, 8/3/07)
   if ( China ) then begin

      ;-------------------------
      ; China nested grid
      ;-------------------------
      LL    = [ -11,  70 ]
      UR    = [  55, 150 ]

   endif else if ( NAmer ) then begin

      ;-------------------------
      ; N. America nested grid
      ;-------------------------

      ; GEOS-5 nested grid goes up to 70N
      if ( ModelInfo.Name eq 'GEOS3' ) then begin
         LL    = [ 10, -140 ] 
         UR    = [ 60,  -40 ]
      endif else begin
         LL    = [ 10, -140 ] 
         UR    = [ 70,  -40 ]
      endelse

   endif else if ( Europe ) then begin

      ;-------------------------
      ; Europe nested grid
      ;-------------------------
      LL    =  [ 1, 1 ]  ; define these later
      UR    =  [ 1, 1 ]

   endif else begin

      ;-------------------------
      ; Global region
      ;-------------------------
      I0    = 1L
      J0    = 1L
      NI    = GridInfo.IMX
      NJ    = GridInfo.JMX
      return

   endelse
   
   ; Get (I,J) index of LL and UR corners of nested region
   ; NOTE: (I,J) are in FORTRAN notation (starting from 1)
   CTM_Index, ModelInfo, I0, J0, Center=LL, /Non_Interactive
   CTM_Index, ModelInfo, I1, J1, Center=UR, /Non_Interactive

   ; Compute values for nested grids & return
   NI = I1 - I0 + 1
   NJ = J1 - J0 + 1

end

;------------------------------------------------------------------------------

function CTM_Read_GMAO, Ilun, FileInfo, DataInfo, Print=PPrint, _EXTRA=e

   ;==================================================================== 
   ; Initialization
   ;==================================================================== 

   ; External functions
   FORWARD_FUNCTION ChkStru,  CTM_Type, $
                    CTM_Grid, Create3DHStru, CRG_Get_ModelInfo

   ; Note: assume that Met field files have less than 512 entries,
   ; this is a pretty safe assumption (bmy, 4/7/00)
   Struc  = Create3DHStru( 512 )
   PPrint = Keyword_Set( PPrint )

   ; retrieve punch file name
   if ( ChkStru( FileInfo, 'filename' ) )     $
      then ThisFileName = FileInfo.FileName   $
      else ThisFileName = '<UNKNOWN FILE>'
   
   ; Make sure that the file type is correct
   if ( ChkStru( FileInfo, 'filetype' ) ) $
      then FileType = FileInfo.FileType   $
      else FileType = 999                 ; unknown -- will default to 2

   ;### Debug output
   if ( PPrint ) $
      then print,'Reading header from ',thisfilename,', filetype ',filetype

   if ( FileType ne 104 ) then begin
      Message,'WARNING!! Filetype is not a GMAO met field file!', /Continue
      return, -1L
   endif

   ;==================================================================== 
   ; Read "diaginfo.dat" and "tracerinfo.dat" to get the list of
   ; the tracer names under categories "GMAO-2D" and "GMAO-3D$"
   ;==================================================================== 

   ; Get NAME, TRACER, UNIT arrays for all 2-D fields
   CTM_TracerInfo, /All, Name=TracerName, $
      Index=Index, Unit=Unit, Is_Edged=Is_Edged
   CTM_DiagInfo, 'GMAO-2D', D2
   Ind   = Where( Index ge D2.Offset AND Index lt D2.Offset+D2.Spacing )
   Cat2D = StrTrim( D2.Category, 2 )

   if ( Ind[0] ge 0 ) then begin
      Name2D   = TracerName[Ind]
      Tracer2D = Index[Ind]
      Unit2D   = Unit[Ind]
   endif else begin
      Name2D   = ''
      Tracer2D = ''
      Unit2D   = ''
   endelse

   ; Get NAME, TRACER, UNIT arrays for all 3-D fields
   CTM_DiagInfo, 'GMAO-3D$', D3
   Ind   = Where( Index ge D3.Offset AND Index lt D3.Offset+D3.Spacing )
   Cat3D = StrTrim( D3.Category, 2 )

   if ( Ind[0] ge 0 ) then begin
      Name3D    = TracerName[Ind]
      Tracer3D  = Index[Ind]
      Unit3D    = Unit[Ind]
      IsEdged3D = Is_Edged[Ind] 
   endif else begin
      Name3D    = ''
      Tracer3D  = ''
      Unit3D    = ''
      IsEdged3D = -1L
   endelse

   ;==================================================================== 
   ; Compute model & grid type and store in global FILEINFO structure
   ;==================================================================== 
   
   ; Go to start of file
   Point_LUN, Ilun, 0L

   ; Test for GEOS-4 ident string first
   Name = BytArr( 8 )          
   ReadU, Ilun, Name

   ; Parse the ident string
   if ( StrMid( Name, 0, 2 ) eq 'G4' ) then begin

      ;-------------------------
      ; GEOS-4 grids
      ;-------------------------

      ; Get resolution from IDENT string
      case ( StrMid( Name, 3, 2 ) ) of 
         '11' : Res = [ 1.25, 1.0 ]
         '22' : Res = [ 2.5,  2.0 ]
         '45' : Res = [ 5.0,  4.0 ]
         else : Message, 'Could not find resolution in GEOS-4 ident string!'
      endcase

      ; Define modelinfo structure
      ModelInfo = CTM_Type( 'GEOS4', Resolution=Res )

   endif else if ( StrMid( Name, 0, 2 ) eq 'G5' ) then begin

      ;-------------------------
      ; GEOS-5 grids
      ;-------------------------

      ; Get resolution from IDENT string
      case ( StrMid( Name, 3, 2 ) ) of 
         '10' : Res = [ 1.0,     1.0   ]
         '11' : Res = [ 1.25,    1.0   ]
         '22' : Res = [ 2.5,     2.0   ]
         '45' : Res = [ 5.0,     4.0   ]
         '56' : Res = [ 2d0/3d0, 0.5d0 ]
         else : Message, 'Could not find resolution in GEOS-5 ident string!'
      endcase

      ; Define modelinfo structure
      ModelInfo = CTM_Type( 'GEOS5', Resolution=Res )

   endif else if ( StrMid( Name, 0, 2 ) eq 'GP' ) then begin

      ;-------------------------
      ; GCAP 4x5 grid
      ;-------------------------

      ; Define modelinfo structure
      ModelInfo = CTM_Type( 'GCAP', Resolution=4 )
     
   endif else begin

      ;-------------------------
      ; All other grids
      ;-------------------------

      ; Call CRG_GET_MODELINFO to get the MODELINFO
      ; structure based on file name and dates
      ModelInfo = CRG_Get_ModelInfo( Ilun, FileInfo.FileName, Name2D, Name3D )

   endelse

   ; If MODELINFO is not valid, ask user for the model type
   if ( not ChkStru( ModelInfo, 'NAME' ) ) $
      then ModelInfo = Select_Model( Default='GEOS3 4x5 (48L)' )

   ; Save MODELINFO into the global FILEINFO structure
   FileInfo.ModelInfo = ModelInfo

   ; Save GRIDINFO into the global FILEINFO structure 
   GridInfo           = CTM_Grid( ModelInfo )
   if ( ptr_valid( FileInfo.GridInfo ) ) then ptr_free, fileinfo.gridinfo
   FileInfo.GridInfo = Ptr_New( GridInfo )

   ;==================================================================== 
   ; Define necessary parameters
   ;==================================================================== 

   ; Data block counter 
   N = 0L                    

   ; Get the I0, J0, NI, NJ values, which are needed to 
   ; define the size of the data block (bmy, phs, 8/3/07)
   CRG_Get_HorzDim, ModelInfo, GridInfo, I0, J0, NI, NJ, _EXTRA=e

   ; For GEOS-2 or GEOS-3, XYMD (YYYYMMDD) and XHMS (HHMMSS) are longwords
   ; Otherwise, they need to be declared floating-point (bmy, 6/12/00)
   S = StrUpCase( StrTrim( ModelInfo.NAME, 2 ) ) 

   if ( S eq 'GEOS1' or S eq 'GEOS_STRAT' ) then begin
      XYMD = 0.0                 
      XHMS = 0.0 
   endif else begin
      XYMD = 0L                 
      XHMS = 0L 
   endelse

   ;==================================================================== 
   ; Read through all of the fields in the file
   ;==================================================================== 

   ; Reset to start of file if this is not a 
   ; GEOS-4, GEOS-5, or GCAP met field
   if ( ModelInfo.Name ne 'GEOS4'  AND $ 
        ModelInfo.Name ne 'GEOS5'  AND $
        ModelInfo.Name ne 'GCAP' ) then Point_LUN, Ilun, 0L
   
   ; Loop until EOF
   while ( not EOF( Ilun ) ) do begin

      ; Read met field name
      ReadU, Ilun, Name
      StrName = StrUpCase( StrTrim( Name, 2 ) )

      if ( PPrint ) then print,'read in label : ',strname

      ;=================================================================
      ; Read 2-D or 3-D data blocks -- get info from the listings
      ; stored in "diaginfo.dat" and "tracerinfo.dat"
      ;=================================================================

      ; Index of 2-D data 
      Ind2D = Where( Name2D eq StrName )
      Ind3D = Where( Name3D eq StrName )

      if ( Ind2D[0] ge 0 ) then begin

         ;-----------------
         ; 2-D data block
         ;-----------------
         Category = Cat2D
         Tracer   = ( Tracer2D[Ind2D] )[0]
         Unit     = (   Unit2D[Ind2D] )[0]
         NL       = 1L
         Data     = FltArr( NI, NJ )
         
         ; Get file position and read array
         Point_Lun, -Ilun, Newpos
         ReadU, Ilun, XYMD, XHMS, Data

      endif else if ( Ind3D[0] ge 0 ) then begin

         ;-----------------
         ; 3-D data block
         ;-----------------
         Category = Cat3D
         Tracer   = ( Tracer3D[Ind3D] )[0]
         Unit     = (   Unit3D[Ind3D] )[0]

         ; Some GEOS-5 fields have GridInfo.LMX+1 levels
         if ( IsEdged3D[Ind3D] )                 $
            then NL = Long( GridInfo.LMX ) + 1L  $
            else NL = Long( GridInfo.LMX )

         ; Make data array
         Data = FltArr( NI, NJ, NL )

         ; Get file position and read array
         Point_Lun, -Ilun, Newpos
         ReadU, Ilun, XYMD, XHMS, Data

      endif else begin
         
         ;-----------------
         ; Error check
         ;-----------------
         S = 'Could not find ' + StrName + ' in tracerinfo.dat!'
         Message, S

      endelse
       
      ;=================================================================
      ; Special processing for some unit strings
      ;=================================================================
      if ( ModelInfo.Name eq 'GEOS4' ) then begin

         ; Special GEOS-4 units
         case ( StrName ) of
            'PBL'    : Unit = 'm'
            'CLDMAS' : Unit = 'kg/m2/s'
            'DTRAIN' : Unit = 'kg/m2/s'
            else     : ; Nothing
         endcase

      endif else begin

         ; Special GEOS-3 units
         case ( StrName ) of
            'PBL'    : Unit = 'hPa'
            'CLDMAS' : Unit = 'kg/m2/600s'
            'DTRAIN' : Unit = 'kg/m2/600s'
            else     : ; Nothing
         endcase

      endelse

      ;=================================================================
      ; Store into DATAINFO array of structures
      ;=================================================================

      ; Compute TAU from XYMD, XHMS
      Tau = NYMD2Tau( Long( XYMD ), Long( XHMS ), /GEOS )

      ; Store DATAINFO fields in the STRUC array of structures
      Struc[N].Ilun       = Ilun
      Struc[N].FilePos    = NewPos 
      Struc[N].Category   = Category
      Struc[N].Tracer     = Tracer
      Struc[N].TracerName = StrName
      Struc[N].Tau0       = Tau
      Struc[N].Tau1       = Tau
      Struc[N].Unit       = Unit
      Struc[N].Format     = 'GMAO BINARY'
      Struc[N].Dim        = [ NI, NJ, NL, 1L ]
      ;--------------------------------------------------
      ; Prior to 8/3/07:
      ;Struc[N].First      = [ 1L, 1L, 1L ]
      ;--------------------------------------------------
      Struc[N].First      = [ I0, J0, 1L ]
      Struc[N].Data       = Ptr_New( Data )

      ; Increment count
      N = N + 1L

      ; Undefine the data array
      UnDefine, Data

   endwhile
   
   ;==================================================================== 
   ; Copy fields from STRUC to DATAINFO and return
   ;==================================================================== 
   DataInfo = Struc[0:N-1]
   
   return, 1L
end
 
