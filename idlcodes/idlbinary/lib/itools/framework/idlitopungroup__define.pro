; $Id: //depot/idl/IDL_63_RELEASE/idldir/lib/itools/framework/idlitopungroup__define.pro#1 $
;
; Copyright (c) 2003-2006, Research Systems, Inc.  All rights reserved.
;   Unauthorized reproduction prohibited.
;----------------------------------------------------------------------------
; PURPOSE:
;   This file implements the statistics action.

;---------------------------------------------------------------------------
; Lifecycle Routines
;---------------------------------------------------------------------------
; IDLitopUngroup::Init
;
; Purpose:
; The constructor of the IDLitopUngroup object.
;
; Parameters:
; None.
;
function IDLitopUngroup::Init, _REF_EXTRA=_extra

    compile_opt idl2, hidden

    success = self->IDLitOperation::Init( $
        NAME="Ungroup", $
        TYPE=['VISUALIZATION'], $
        DESCRIPTION="iTools Group", $
        _EXTRA=_extra)

    return, success
end


;-------------------------------------------------------------------------
; IDLitopUngroup::Cleanup
;
; Purpose:
; The destructor of the IDLitopUngroup object.
;
; Parameters:
; None.
;
;pro IDLitopUngroup::Cleanup
;    ;; Pragmas
;    compile_opt idl2, hidden
;    self->IDLitOperation::Cleanup
;end


;---------------------------------------------------------------------------
; Purpose:
;  Undo the commands contained in the command set.
;
function IDLitopUngroup::UndoOperation, oCommandSet

    compile_opt idl2, hidden

    ; Call our superclass method.
    return, self->IDLitopGrouping::_DoGroupCommand(oCommandSet)

end


;---------------------------------------------------------------------------
; Purpose:
;  Undo the commands contained in the command set.
;
function IDLitopUngroup::RedoOperation, oCommandSet

    compile_opt idl2, hidden

    ; Call our superclass method.
    return, self->IDLitopGrouping::_DoUngroupCommand(oCommandSet)

end


;---------------------------------------------------------------------------
; Purpose:
;  Perform the Ungrouping operation on the selected item(s).
;
function IDLitopUngroup::DoAction, oTool

    compile_opt idl2, hidden

    ; Make sure we have a tool.
    if not obj_valid(oTool) then $
        return, obj_new()

    ; Get the selected objects.
    oSelVis = oTool->GetSelectedItems(count=nVis)

    ; Let's make a commmand set for this operation. This is produced
    ; by the super-class
    oCommandSet = self->IDLitOperation::DoAction(oTool)
    oCommandSet->SetProperty, NAME='Ungroup'

    ; This is trickier than Grouping because we might have multiple
    ; groups to ungroup. So build up a command set, one command for each.
    for i=0, nVis-1 do begin

        oGroup = oSelVis[i]

        ; Only allow groups to be ungrouped.
        if (~OBJ_ISA(oGroup, 'IDLitVisGroup')) then $
            continue

        ; Retrieve properties needed for undo/redo.
        oGroup->GetProperty, _PARENT=oGroupParent

        oVis = oGroup->Get(/ALL)
        good = WHERE(~OBJ_ISA(oVis, 'IDLitManipulatorVisual'), count)
        if (count eq 0) then $
            continue
        oVis = oVis[good]

        idVis = STRARR(count)
        idParent = oGroupParent->GetFullIdentifier()

        for j=0,count-1 do begin
            ; Construct the original full identifier for the
            ; grouped items. Assumes they all have the same
            ; parent.
            oVis[j]->GetProperty, IDENTIFIER=myID
            idVis[j] = idParent + '/' + myID
        endfor

        ; Construct our command in case we want to undo the Ungroup.
        oCmd = OBJ_NEW('IDLitCommand', $
            TARGET_IDENTIFIER=oGroup->GetFullIdentifier())
        dummy = oCmd->AddItem('GROUPED_ITEMS', idVis)
        oCommandSet->Add, oCmd

    endfor

    ; Call our superclass method.
    dummy = self->IDLitopGrouping::_DoUngroupCommand(oCommandSet)

    return, oCommandSet

end


;-------------------------------------------------------------------------
pro IDLitopUngroup__define

    compile_opt idl2, hidden

    struc = {IDLitopUngroup, $
             inherits IDLitopGrouping $
            }

end

