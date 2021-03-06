; $Id: ctm_grid.pro,v 1.2 2004/01/29 19:33:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_GRID  (function)
;
; PURPOSE:
;        Set-up of the model grid for various models. While the
;        horizontal grid information can be computed from a few
;        basic parameters, the vertical structure is hardwired
;        for each model seperately. Currently, the following models
;        are supported: GEOS1, GEOS_STRAT, GEOS-3, GEOS-4/fvDAS,
;        GISS_II, GISS_II_PRIME, and FSU.
;       
; CATEGORY
;        CTM Tools
;
; CALLING SEQUENCE:
;        result = CTM_GRID( MTYPE [, Keywords ] )
;
; INPUTS:
;        MTYPE --> a MODELINFO structure as returned from function 
;             CTM_TYPE.  This structure  must contain the following tags: 
;             resolution (a 2 element vector with DI, DJ), halfpolar, 
;             center180, name, nlayers, ptop, psurf, hybrid.)
; 
; OUTPUT:
;        The function CTM_GRID returns either a structure or a scalar or
;        vector variable depending on the output keywords below.
;
; KEYWORD PARAMETERS:
;        PSURF -> specify surface pressure in mb. Overrides 
;            value passed in through modelinfo structure.
;
;        The following keywords define output options. If none of these
;        is set, a structure is returned that contains all parameters.
;	   IMX   (int   ) -> Maximum I (longitude) dimension  [alt: NLON]
;          JMX   (int   ) -> Maximum J (latitude ) dimension  [alt: NLAT]
;          DI    (flt   ) -> Delta-I interval between grid box edges
;          DJ    (flt   ) -> Delta-J interval between grid box edges
;          YEDGE (fltarr) -> Array of latitude  edges
;          YMID  (fltarr) -> Array of latitude  centers
;          XEDGE (fltarr) -> Array of longitude edges   
;          XMID  (fltarr) -> Array of longitude centers
;
;          LMX   (int)    -> Maximum altitude level (layers)  [alt: NLAYERS]
;          SIGMID (fltarr)-> Array of sigma center values
;          SIGEDGE (..)   -> Array of sigma edges
;          ETAMID  (..)   -> Array of ETA center values
;          ETAEDGE (..)   -> Array of ETA edge values
;          PMID    (..)   -> Array of approx. pressure values for sigma centers
;          PEDGE   (..)   -> dto. for sigma edges
;          ZMID    (..)   -> Array of approx. mean altitudes for sigma centers
;          ZEDGE   (..)   -> dto. for sigma edges
;
;        /NO_VERTICAL --> do not return vertical grid info in structure
;             In this case the MTYPE structure only needs to contain
;             resolution, halfpolar and center180. This keyword is ignored if 
;             a specific (vertical) output option is requested.
;
; 
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================
;        USSA_ALT (function)
;        GETSIGMA (function)
;        GETETA   (function)
;
; REQUIREMENTS:
;        Best if used with function CTM_TYPE.  Also requires functions
;        GETSIGMA and GETETA for definition of vertical layers.
;
; NOTES:
;        This routine is not very efficient in that it always computes 
;        all the available information. But since it will not be
;        called too often and does not handle large amounts of data, 
;        we won't worry about computational efficiency here.
;
; EXAMPLE:
;        mtype = CTM_TYPE('GEOS1')
;        mgrid = CTM_GRID(mtype)
;
;        This will define the following structure (help,mgrid,/stru)
;
;        ** Structure <10323808>, 17 tags, length=1624, refs=1:
;           IMX             INT             72
;           JMX             INT             46
;           DI              FLOAT           5.00000
;           DJ              FLOAT           4.00000
;           XEDGE           FLOAT     Array[73]     (-177.500, -172.500, ...)
;           YEDGE           FLOAT     Array[47]     (-90, -88, -84, ...)
;           XMID            FLOAT     Array[72]     (-180.0, -175.0, ...)
;           YMID            FLOAT     Array[46]     (-89, -86, -82, ...)
;           LMX             INT             20
;           SIGMID          FLOAT     Array[20]     (0.993936, 0.971301, ...)
;           SIGEDGE         FLOAT     Array[21]     (1.00000,  0.987871, ...)
;           ETAMID          FLOAT     Array[20]     (all zeroes)
;           ETAEDGE         FLOAT     Array[21]     (all zeroes)
;           PMID            FLOAT     Array[20]     (980.082, 957.990, ...)
;           PEDGE           FLOAT     Array[21]     (986.000, 974.162, ...)
;           ZEDGE           FLOAT     Array[21]
;           ZMID            FLOAT     Array[20]
;
;        Or, with the use of output keywords:
;             print,ctm_grid(MODEL_TYPE('GISS_II'),/PMID)
;
;        IDL will print
;             986.000      935.897      855.733      721.458      551.109 
;             390.781      255.503      150.287      70.1236      10.0000
;
;        A more awkward example (see yourself):
;             help, ctm_grid({resolution:[3.6,3.0],halfpolar:0,center180:0}, $
;                            /no_vert),/stru
;
; MODIFICATION HISTORY:
;        bmy, 19 Aug 1997: VERSION 1.00
;        bmy, 24 Sep 1997: VERSION 1.01
;        mgs, 26 Feb 1998: Version 2.00  - rewritten as a function
;        mgs, 27 Feb 1998:  - added vertical information
;        mgs, 02 Mar 1998:  - better defined interface with CTM_MODEL_TYPE
;        bmy, 07 Apr 1998:  - Renamed 
;        mgs, 24 Apr 1998:  - changed structure to named structure
;        mgs, 04 May 1998:  - changed back because of conflicting sizes
;        mgs, 07 May 1998:  - Renamed to CTM_GRID
;                           - x coordinates now start with -182.5 for 
;                             center180 grids
;        bmy, 19 Jun 1998:  - now uses USSA_ALT to compute altitudes
;                             from pressure coordinates
;                           - fixed some comments
;                           - added FORWARD_FUNCTION statement
;        mgs, 30 Jun 1999:  - added PSURF keyword
;        bmy, 27 Jul 1999:  GAMAP VERSION 1.42
;                           - now can compute pressure levels and
;                             edges for hybrid sigma-pressure grids
;                           - a few cosmetic changes
;        bmy, 03 Jan 2000:  - more cosmetic changes
;        bmy, 20 Apr 2000:  GAMAP VERSION 1.45
;                           - now returns correct YMID values for FSU grid
;        bmy, 15 Sep 2000:  GAMAP VERSION 1.46
;                           - fixed bug for computing YMID for grids
;                             w/o halfpolar boxes.  This also fixes the
;                             previous problem w/ the FSU grid.
;        bmy, 03 Jul 2001:  GAMAP VERSION 1.48
;                           - If MTYPE.NLAYERS = 0, then create a
;                             return structure w/o vertical level info
;        bmy, 06 Nov 2001:  GAMAP VERSION 1.49
;                           - added ETAMID, ETAEDGE keywords
;                           - added ETAMID, ETAEDGE tags to return structure
;                           - now calls GETETA to return ETA coordinates
;                             for hybrid models (such as GEOS-4/fvDAS)
;                           - updated comments
;        bmy, 18 Oct 2002:  GAMAP VERSION 1.52
;                           - deleted obsolete commented-out code
;        bmy, 04 Nov 2003:  GAMAP VERSION 2.01
;                           - Use STRPOS to test for GEOS4 or 
;                             GEOS4_30L model names
;                           - Now treat GISS_II_PRIME 23-layer model
;                             as a hybrid grid instead of using the
;                             obsolete "fake" formulation.
;
;-
; Copyright (C) 1997, 1998, 1999, 2000, 2001, 2002, 2003,
; Bob Yantosca and Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine ctm_grid"
;-----------------------------------------------------------------------

pro use_ctm_grid

   print,'   Usage :'
   print,'      mgrid = CTM_GRID(CTM_TYPE(name,options) [,keywords])'
   print
   print,'   Keywords :'
   print,'      PSURF = override surface pressure passed in modelinfo.'
   print,'      IMX, JMX = return maximum longitude and latitude dimension'
   print,'      DI, DJ = return longitude and latitude increment'
   print,'      YEDGE, YMID = return array of latitude edges/centers'
   print,'      XEDGE, XMID = return array of longitude edges/centers'
   print,'      LMX = return number of vertical layers'
   print,'      SIGEDGE, SIGMID = return sigma levels edges/centers'
   print,'      ETAEDGE, ETAMID = return eta levels edges/centers'
   print,'      PEDGE, PMID = return approx. pressure on sigma edges/centers'
   print,'      ZEDGE, ZMID = return approx. altitude at sigma edges/centers'
   print
   print,'      If none of the output options is specified, the complete'
   print,'      information is returned as a structure.'
   print
   print,'      /NO_VERTICAL --> prevents inclusion of vertical information'
   print,'      in the result structure.'
   
   return
end


function CTM_GRID, MTYPE, PSURF=PSURF,   $
                   IMX=IMX, JMX=JMX, NLON=NLON, NLAT=NLAT,  $
                   DI=DI, DJ=DJ, XEDGE=XEDGE, YEDGE=YEDGE, $
                   XMID=XMID, YMID=YMID, $
                   LMX=LMX, NLAYERS=NLAYERS, $
                   SIGMID=SIGMID, SIGEDGE=SIGEDGE, $
                   ETAMID=ETAMID, ETAEDGE=ETAEDGE, $
                   PMID=PMID, PEDGE=PEDGE, $
                   ZMID=ZMID, ZEDGE=ZEDGE,  $
                   NO_VERTICAL=NO_VERTICAL, HELP=HELP
 
   ; Pass external functions
   FORWARD_FUNCTION USSA_Alt, GetSigma, GetEta

   ;====================================================================
   ;  Error checking
   ;====================================================================
   on_error, 2

   if (keyword_set(HELP)) then begin
      use_ctm_grid
      return,-1
   endif

   if (n_params() lt 1) then begin
      print, 'Too few parameters...'
      use_ctm_grid
      return,-1
   endif

   ; check if MTYPE has the correct structure type 
   fields = ['resolution','halfpolar','center180']

   notvert = keyword_set(NO_VERTICAL) and $
      not(keyword_set(LMX)    or keyword_set(SIGEDGE) or $
          keyword_set(SIGMID) or keyword_set(PEDGE) or $
          keyword_set(PMID)   or keyword_set(ZEDGE) or $
          keyword_set(ZMID) )
   
   if (not notvert) then $
      fields = [ fields, 'name','nlayers','ptop','psurf' ]

   if (not chkstru(MTYPE,fields,/VERBOSE)) then begin
      use_ctm_grid
      return,-1
   endif

   ; extra check: see if resolution is 2 element vector
   if (n_elements(MTYPE.resolution) ne 2) then begin
      print,'CTM_GRID: ** MODEL resolution invalid !! **'
      return,-1
   endif

   ; If there are no vertical layers specified in MTYPE, then do 
   ; not include vertical layers in the return structure (bmy, 7/3/01)
   if ( MType.NLayers eq 0 ) then NotVert = 1

   ;====================================================================
   ; Extract resolution info from structure
   ;====================================================================

   mDI = MTYPE.resolution(0)    ; longitude interval
   mDJ = MTYPE.resolution(1)    ; latitude interval


   ;====================================================================
   ; Compute number of grid boxes from resolution - 
   ; take care of polar boxes
   ;
   ; NOTE: ATTENTION needed if model is added that does not have 
   ;       half size polar boxes!
   ;====================================================================

   mIMX  =  fix(360./mDI)
   mJMX  =  fix(180./mDJ) + MTYPE.halfpolar

   ;====================================================================
   ;  compute longitude and latitude vectors
   ;  NOTE: XEDGE will return *all* box boundaries 
   ;  (CHANGED!! mgs, 05/07/1998)
   ;====================================================================
   mXEDGE = findgen(mIMX+1)*mDI - 180. - (mDI/2. * MTYPE.center180)
   mXMID  = mXEDGE - mDI/2. 
   mXMID  = mXMID(1:*)
  
   mYEDGE = findgen(mJMX+1)*mDJ - 90. - (mDJ/2. * MTYPE.halfpolar)
   mYEDGE(0) = -90.
   mYEDGE(mJMX) = 90.

   mYMID  = findgen(mJMX)*mDJ - 90.

   ; Bug fix for grids w/o halfpolar boxes (bmy, 9/15/00)
   if ( MTYPE.HalfPolar ) then begin
      mYMID(0)      = ( mYEDGE(0) + mYEDGE(1) ) / 2.
      mYMID(mJMX-1) = - mYMID(0)
   endif else begin
      ; For grids w/o halfpolar boxes, add 1/2 of the 
      ; box size to MYMID as computed above (bmy, 9/15/00)
      mYMID = mYMID + ( mYEDGE(1) - mYEDGE(0) ) / 2.
   endelse
   
   ; numerical fix
   ind = where(abs(mXEDGE) lt 1.e-5)
   if (ind(0) ge 0) then mXEDGE(ind) = 0.
   ind = where(abs(mXMID) lt 1.e-5)
   if (ind(0) ge 0) then mXMID(ind) = 0.
   ind = where(abs(mYEDGE) lt 1.e-5)
   if (ind(0) ge 0) then mYEDGE(ind) = 0.
   ind = where(abs(mYMID) lt 1.e-5)
   if (ind(0) ge 0) then mYMID(ind) = 0.

   ;====================================================================
   ;  get vertical structure information
   ;====================================================================
   if notvert then goto,output  ; no vertical information requested

   ; create copy of NLAYERS to pass to getsigma
   nlayers = MTYPE.nlayers

   ; keyword psurf overrides grid definition structure
   if ( n_elements( PSURF ) ne 1 ) then PSURF = MTYPE.psurf
   
   ; For MOPITT grid only: Always set PSURF = 1000 hPa, so that the 
   ; pressure levels will be computed correctly (clh, bmy, 10/15/02)
   if ( StrTrim( MType.Family, 2 ) eq 'MOPITT' ) then Psurf = 1000.0

   ; Get sigma/eta and pressure coordinates
   ;-----------------------------------------------------------------------
   ; Prior to 11/4/03:
   ;if ( StrPos( StrTrim( MType.Name, 2 ), 'GEOS4' ) ge 0  OR $
   ;     StrPos( StrTrim( MType.Name, 2 ), 'GISS_II' ) then begin 
   ;-----------------------------------------------------------------------
   if ( MType.Hybrid ) then begin

      ;=================================================================
      ; HYBRID GRIDS (e.g. GEOS-4, GISS_II_PRIME 23L) 
      ; We must use the ETA coordinate for vertical levels
      ;=================================================================

      ; Get ETA coordinate at grid box centers
      CETA   = GetEta( MType.Name, NLayers, PSurf=PSurf, /Center )

      ; check if number of layers is as expected
      if ( nlayers ne MTYPE.nlayers ) $
         then Message, '** number of layers inconsistent ! **'

      ; Get ETA coordinates at grid box edges
      EETA   = GetEta( MTYPE.name, nlayers, PSurf=PSurf, /Edges )

      ; Construct pressures at box centers and edges
      ; Pressure = ( ETA * ( Psurf - PTOP ) ) + PTOP
      CPRESS = CETA * ( psurf - MTYPE.ptop ) + MTYPE.ptop
      EPRESS = EETA * ( psurf - MTYPE.ptop ) + MTYPE.ptop
      
      ; Set ESIG, CSIG to zero, we don't have sigma coordinates
      ESIG   = FltArr( N_Elements( EETA ) )
      CSIG   = FltArr( N_Elements( CETA ) )

   endif else begin

      ;=================================================================
      ; PURE SIGMA GRIDS (e.g. GEOS-1, GEOS-STRAT, GEOS-3)
      ; We must use the SIGMA coordinate for vertical levels
      ;=================================================================      

      ; Get SIGMA centers
      CSIG = getsigma(MTYPE.name,nlayers,/CENTER)

      ; check if number of layers is as expected
      if ( nlayers ne MTYPE.nlayers ) $
         then Message, '** number of layers inconsistent ! **'
   
      ; Get SIGMA edges
      ESIG = getsigma(MTYPE.name,nlayers,/EDGES)
   
      ; compute approx. pressure levels
      ;     sigma = (P - Ptop) / (Psurf - Ptop)
   
      ;------------------------------------------------------------------------
      ; Prior to 11/4/03:
      ; GISS_II_PRIME is now handled above (bmy, 11/4/03)
      ;; Compute pressures corresponding to sigma centers and edges
      ;if ( MType.HYBRID ) then begin
      ;
      ;   ; Pressure centers for hybrid sigma-pressure models
      ;   ; Use 984 mb for the "surface pressure" for fixed pressure levels
      ;   ; NOTE: This is primarily for the GISS_II_PRIME model
      ;   N             = MType.NTROP-1
      ;   CPRESS        = FltArr( NLayers )
      ;   CPRESS[  0:N] = CSIG[  0:N] * ( psurf - MTYPE.ptop ) + MTYPE.ptop
      ;   CPRESS[N+1:*] = CSIG[N+1:*] * ( 984.0 - MTYPE.ptop ) + MTYPE.ptop
      ;   
      ;   ; Pressure edges for hybrid sigma-pressure models
      ;   ; Use 984 mb for the "surface pressure" for fixed pressure levels
      ;   ; NOTE: This is primarily for the GISS_II_PRIME model
      ;   N             = MType.NTROP
      ;   EPRESS        = FltArr( NLayers + 1 )
      ;   EPRESS[  0:N] = ESIG[  0:N] * ( psurf - MTYPE.ptop ) + MTYPE.ptop
      ;   EPRESS[N+1:*] = ESIG[N+1:*] * ( 984.0 - MTYPE.ptop ) + MTYPE.ptop
      ;
      ;endif else begin
      ;
      ;   ; Pressure levels for pure sigma-level models
      ;   ; This includes GEOS-1, GEOS-STRAT, GEOS-3, GISS_II, FSU, etc
      ;   CPRESS = CSIG * ( psurf - MTYPE.ptop ) + MTYPE.ptop
      ;   EPRESS = ESIG * ( psurf - MTYPE.ptop ) + MTYPE.ptop
      ; 
      ;endelse
      ;------------------------------------------------------------------------

      ; Pressure levels for pure sigma-level models
      ; This includes GEOS-1, GEOS-STRAT, GEOS-3, GISS_II, FSU, etc
      CPRESS = CSIG * ( psurf - MTYPE.ptop ) + MTYPE.ptop
      EPRESS = ESIG * ( psurf - MTYPE.ptop ) + MTYPE.ptop

      ; Set EETA and CETA to zero for pure sigma models
      EETA = FltArr( N_Elements( ESIG ) )
      CETA = FltArr( N_Elements( CSIG ) )

   endelse

   ; Call function USSA_ALT to convert Edge and center 
   ; pressures to altitudes (bmy, 6/19/98) 
   mZEDGE = USSA_Alt( EPRESS )
   mZMID  = USSA_Alt( CPRESS )

   ;====================================================================
   ; handle output request : if an output keyword is set, return the 
   ; respective value, else create a structure with all the information
   ;====================================================================

output:
   ; only alternative name for IMX
   if ( keyword_set( NLON    ) ) then return, mIMX 
   if ( keyword_set( NLAT    ) ) then return, mJMX
   if ( keyword_set( IMX     ) ) then return, mIMX
   if ( keyword_set( JMX     ) ) then return, mJMX
   if ( keyword_set( DI      ) ) then return, mDI
   if ( keyword_set( DJ      ) ) then return, mDJ
   if ( keyword_set( XEDGE   ) ) then return, mXEDGE
   if ( keyword_set( YEDGE   ) ) then return, mYEDGE
   if ( keyword_set( XMID    ) ) then return, mXMID
   if ( keyword_set( YMID    ) ) then return, mYMID
   
   if ( keyword_set( LMX     ) ) then return, MTYPE.nlayers
   if ( keyword_set( SIGEDGE ) ) then return, ESIG
   if ( keyword_set( SIGMID  ) ) then return, CSIG
   if ( keyword_set( ETAEDGE ) ) then return, EETA
   if ( keyword_set( ETAMID  ) ) then return, CETA
   if ( keyword_set( PEDGE   ) ) then return, EPRESS
   if ( keyword_set( PMID    ) ) then return, CPRESS
   if ( keyword_set( ZEDGE   ) ) then return, mZEDGE
   if ( keyword_set( ZMID    ) ) then return, mZMID

   result = { IMX:mIMX,     JMX:mJMX,     DI:mDI,     DJ:mDJ,     $
              XEDGE:mXEDGE, YEDGE:mYEDGE, XMID:mXMID, YMID:mYMID }

   ; Added ETAMID, ETAEDGE tags (bmy, 11/6/01)
   if (not notvert) then $
      result = CREATE_STRUCT(result,                   $
                             'LMX',     MTYPE.nlayers, $
                             'SIGMID',  CSIG,          $
                             'SIGEDGE', ESIG,          $
                             'ETAMID',  CETA,          $
                             'ETAEDGE', EETA,          $
                             'PMID',    CPRESS,        $
                             'PEDGE',   EPRESS,        $
                             'ZEDGE',   mZEDGE,        $
                             'ZMID',    mZMID )

   return,result


end



