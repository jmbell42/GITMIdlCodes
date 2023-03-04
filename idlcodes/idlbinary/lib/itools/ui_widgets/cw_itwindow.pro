; $Id: //depot/idl/IDL_63_RELEASE/idldir/lib/itools/ui_widgets/cw_itwindow.pro#1 $
; Copyright (c) 2002-2006, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.
;+
; NAME:
;   CW_ITWINDOW
;
; PURPOSE:
;   This function implements the compound widget for the IT window.
;
; CALLING SEQUENCE:
;   Result = CW_ITWINDOW(Parent, Tool)
;
; INPUTS:
;   Parent: Set this argument to the widget ID of the parent base.
;
;   Tool: Set this argument to the object reference for the IDL Tool.
;
; KEYWORD PARAMETERS:
;
;
; MODIFICATION HISTORY:
;   Written by:  CT, RSI, March 2002
;   Modified:
;
;-


;-------------------------------------------------------------------------
; Purpose:
;   Callback routine for the widget, allowing it to
;   receive update messages from the system.
;
; Parameters:
;   wBase     - Base id of this widget
;
;   strID     - ID of the message.
;
;   MessageIn - What is the message
;
;   userdata  - Data associated with the message
;
pro cw_itwindow_callback, wDraw, strID, messageIn, userdata

    compile_opt idl2, hidden

    if (~WIDGET_INFO(wDraw, /VALID)) then $
        return

    case messageIn of

    'CONTEXTMENU': begin
        cw_itwindow_setContextMenu, wDraw, userData
        end

    'BOB': begin
        userdata = 33
        end

    'IGNOREACCELERATORS': begin
        WIDGET_CONTROL, wDraw, IGNORE_ACCELERATORS=userdata
        end

    'CONTEXTMENUDISPLAY': begin
        wChild = WIDGET_INFO(wDraw, /CHILD)
        WIDGET_CONTROL, wChild, GET_UVALUE=state
        if (~widget_info(state.wCurrContext,/valid_id)) then $
            break
        WIDGET_DISPLAYCONTEXTMENU, wDraw, $
            userdata[0], userdata[1], state.wCurrContext
        end

    else: ; ignore other messages

    endcase

end


;-------------------------------------------------------------------------
pro cw_itwindow_resize, wDraw, newVisW, newVisH

    compile_opt idl2, hidden

    WIDGET_CONTROL, wDraw, GET_VALUE=oWindow
    if (~OBJ_VALID(oWindow)) then $
        return

    ; Resize the widgets.

    ; Retrieve the original geometry.
    oldGeom = WIDGET_INFO(wDraw, /GEOMETRY)

    oWindow->GetProperty, CURRENT_ZOOM=currentZoom, $
        MINIMUM_VIRTUAL_DIMENSIONS=minVirtualDims, $
        AUTO_RESIZE=autoResize

    ; Virtual dimensions are updated as follows:
    ;
    ; If the new visible dimensions are larger than the minumum
    ; virtual dimensions, then the new virtual dimensionss are set to:
    ;   - the new visible dims, multiplied by the current
    ;     window zoom factor, or
    ;
    ; Otherwise, the new virtual dims are set to:
    ;   - the minimum virtual dims, multiplied by the current
    ;     window zoom factor
    ;
    newDims = [newVisW, newVisH]

    ; Motif automatically leaves room for the scrollbars, while Windows
    ; doesn't. So on Windows, we need to check if scrollbars are being
    ; added or removed, and adjust the final draw widget size.
    ; Otherwise, the user will resize the iTool window, but the final
    ; size will end up slightly different.
    if (!version.os_family eq 'Windows') then begin

        ; Here we check the Y dimension and adjust the X size.
        if (newDims[1] lt minVirtualDims[1]) then begin
            ; If adding a scrollbar take its space away from the draw.
            ; Here we have to guess at the scrollbar size.
            if (oldGeom.scr_xsize eq oldGeom.xsize) then $
                newDims[0] -= 21
        endif else begin
            ; If removing a scrollbar, add its space back to the draw.
            ; Here we can use geom to get the scrollbar size.
            newDims[0] += (oldGeom.scr_xsize - oldGeom.xsize)
        endelse

        ; Here we check the X dimension and adjust the Y size.
        if (newDims[0] lt minVirtualDims[0]) then begin
            ; If adding a scrollbar take its space away from the draw.
            if (oldGeom.scr_ysize eq oldGeom.ysize) then $
                newDims[1] -= 21
        endif else begin
            ; If removing a scrollbar, add its space back to the draw.
            newDims[1] += (oldGeom.scr_ysize - oldGeom.ysize)
        endelse
    endif

    if (autoResize) then begin

        virtualDims = currentZoom*(newDims > minVirtualDims)

        ; Resize the window and the widget.
        WIDGET_CONTROL, wDraw, $
            DRAW_XSIZE=virtualDims[0], DRAW_YSIZE=virtualDims[1], $
            XSIZE=newDims[0], YSIZE=newDims[1]

    endif else begin

        ; Resize just the widget.
        WIDGET_CONTROL, wDraw, XSIZE=newDims[0], YSIZE=newDims[1]

    endelse

end


;-------------------------------------------------------------------------
pro cw_itwindow_event, event

    compile_opt idl2, hidden

    wChild = WIDGET_INFO(event.handler, /CHILD)
    WIDGET_CONTROL, wChild, GET_UVALUE=state

;    case TAG_NAMES(event, /STRUCTURE_NAME) of
;    'WIDGET_DRAW': begin
;        end
;
;    else: ; do nothing
;
;    endcase   ; event.type

end


;-------------------------------------------------------------------------
pro cw_itwindow_realize, wDraw

    compile_opt idl2, hidden

    wChild = WIDGET_INFO(wDraw, /CHILD)
    WIDGET_CONTROL, wChild, GET_UVALUE=state, /NO_COPY

    ; Retrieve the draw window object reference.
    WIDGET_CONTROL, wDraw, GET_VALUE=oWindow
    winDims = oWindow->GetDimensions(VIRTUAL_DIMENSIONS=virtualDims)

    ; Set the MINIMUM_VIRTUAL_DIMENSIONS to match the virtual dims.
    ; We also manually set the VIRTUAL_DIMENSIONS property, because if the
    ; X/Y_SCROLL_SIZE was the same as the X/YSIZE on the WIDGET_DRAW,
    ; then the VIRTUAL_DIMENSIONS are set to [0,0], which implies
    ; matching the dimensions.
    ; Set AUTO_RESIZE to true if VIRTUAL_DIMENSIONS was passed in.
    oWindow->SetProperty, MINIMUM_VIRTUAL_DIMENSIONS=virtualDims, $
        VIRTUAL_DIMENSIONS=virtualDims, $
        AUTO_RESIZE=state.autoResize

    oTool = state.oUI->GetTool()
    oTool->_SetCurrentWindow, oWindow

    ; Register ourself as a widget with the UI object.
    ; Returns a string containing our identifier.
    strObserverIdentifier = state.oUI->RegisterWidget(wDraw, 'ToolDraw', $
        'cw_itwindow_callback')

    ; Register for our messages.
    state.oUI->AddOnNotifyObserver, strObserverIdentifier, $
        oWindow->GetFullIdentifier()

    ; Start out with a 1x1 gridded layout.
    oWindow->SetProperty, LAYOUT_INDEX=1

    ; Set initial canvas zoom to 100% so our checked menus get updated.
    oWindow->SetProperty, CURRENT_ZOOM=1

    WIDGET_CONTROL, wChild, SET_UVALUE=state, /NO_COPY


end


;-------------------------------------------------------------------------
; cw_itwindow_setContextMenu
;
; Purpose:
;   This procedure sets the current context menu for the draw window area.
;
; Arguments:
;   wDraw: The widget id of the draw window.
;
;   strId: A string representing the identifier of the context
;     menu to be set as current.  The empty string denotes the
;     default context menu for the tool.
;
pro cw_itwindow_setContextMenu, wDraw, strId

    compile_opt idl2, hidden

    ; Retrieve the state structure.
    wChild = WIDGET_INFO(wDraw, /CHILD)
    WIDGET_CONTROL, wChild, GET_UVALUE=state

    ; Look for a match or set to the default.
    state.wCurrContext = KEYWORD_SET(strId) ? $
        WIDGET_INFO(wDraw, FIND_BY_UNAME=STRUPCASE(strID)) : $
        state.wDefContext

    WIDGET_CONTROL, wChild, SET_UVALUE=state

end


;-------------------------------------------------------------------------
function cw_itwindow, Parent, oUI, $
    DIMENSIONS=dimensionsIn, $
    VIRTUAL_DIMENSIONS=virtualdimIn, $
    _REF_EXTRA=_extra

    compile_opt idl2, hidden

nparams = 2  ; must be defined for cw_iterror
@cw_iterror

    ; Drawing area.
    dimensions = (N_ELEMENTS(dimensionsIn) eq 2) ? dimensionsIn : [640,480]

    ; If not specified, make the virtual drawing area the
    ; same size as the visible.
    hasVirtualDim = N_ELEMENTS(virtualdimIn) eq 2
    virtualdim = hasVirtualDim ? virtualdimIn : dimensions

    if (MIN(dimensions) le 0) then $
        MESSAGE, 'Illegal keyword value for DIMENSIONS.'

    if (MIN(virtualdim) le 0) then $
        MESSAGE, 'Illegal keyword value for VIRTUAL_DIMENSIONS.'

    oTool = oUI->GetTool()

    ; Drawing area.
    wDraw = WIDGET_DRAW(Parent, $
        CLASSNAME='IDLitgrWinScene', $  ; Component window
        EVENT_PRO='cw_itwindow_event', $
        GRAPHICS_LEVEL=2, $         ; Object graphics
        NOTIFY_REALIZE='cw_itwindow_realize', $
        /APP_SCROLL, $
        X_SCROLL_SIZE=dimensions[0], Y_SCROLL_SIZE=dimensions[1], $
        XSIZE=virtualDim[0], YSIZE=virtualDim[1], $
        _EXTRA=_extra)

    ; Prepare the context menus.
    oContextContainer = oTool->GetByIdentifier('ContextMenu')
    nmenu = 0
    if (OBJ_VALID(oContextContainer)) then $
        oMenus = oContextContainer->Get(/ALL, COUNT=nmenu)

    if (nmenu gt 0) then begin

        for i=0,nmenu-1 do begin
            ; Create a context menu for the registered target.  The
            ; target is a container of operations that will be included
            ; in the context menu. Use the UNAME so we can find this
            ; context menu in _SetContextMenu.
            contextMenu = oMenus[i]->GetFullIdentifier()
            wContext = CW_ITMENU(wDraw, oUI, contextMenu, $
                /CONTEXT_MENU, $
                UNAME=IDLitBasename(contextMenu))

            ; If this context menu has been identified as the default,
            ; store it as such.
            if (i eq 0) then $
                wDefContext = wContext
        endfor

    endif else begin

        ; Create a dummy child so we can store our state.
        wVoid = WIDGET_BASE(wDraw, /CONTEXT_MENU)
        wDefContext = 0L

    endelse

    state = { $
        oUI: oUI, $
        wDefContext: wDefContext, $
        wCurrContext: wDefContext, $
        autoResize: ~hasVirtualDim }

    WIDGET_CONTROL, WIDGET_INFO(wDraw, /CHILD), SET_UVALUE=state, /NO_COPY

    return, wDraw

end

