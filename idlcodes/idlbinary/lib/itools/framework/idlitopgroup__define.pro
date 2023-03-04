; $Id: //depot/idl/IDL_63_RELEASE/idldir/lib/itools/framework/idlitopgroup__define.pro#1 $
;
; Copyright (c) 2003-2006, Research Systems, Inc.  All rights reserved.
;   Unauthorized reproduction prohibited.
;----------------------------------------------------------------------------
; PURPOSE:
;   This file implements the statistics action.

;---------------------------------------------------------------------------
; Lifecycle Routines
;---------------------------------------------------------------------------
; IDLitopGroup::Init
;
; Purpose:
; The constructor of the IDLitopGroup object.
;
; Parameters:
; None.
;
function IDLitopGroup::Init, _REF_EXTRA=_extra
    ;; Pragmas
    compile_opt idl2, hidden

    success = self->IDLitopGrouping::Init( $
        NAME="Group", $
        TYPE=['VISUALIZATION'], $
        DESCRIPTION="iTools Group", _EXTRA=_extra)

    return, success
end


;-------------------------------------------------------------------------
; IDLitopGroup::Cleanup
;
; Purpose:
; The destructor of the IDLitopGroup object.
;
; Parameters:
; None.
;
;pro IDLitopGroup::Cleanup
;    ;; Pragmas
;    compile_opt idl2, hidden
;    self->IDLitopGrouping::Cleanup
;end


;---------------------------------------------------------------------------
; Purpose:
;  Undo the commands contained in the command set.
;
function IDLitopGroup::UndoOperation, oCommandSet

    compile_opt idl2, hidden

    ; Call our superclass method.
    return, self->IDLitopGrouping::_DoUngroupCommand(oCommandSet)

end


;---------------------------------------------------------------------------
; Purpose:
;  Undo the commands contained in the command set.
;
function IDLitopGroup::RedoOperation, oCommandSet

    compile_opt idl2, hidden

    ; Call our superclass method.
    return, self->IDLitopGrouping::_DoGroupCommand(oCommandSet)

end


;---------------------------------------------------------------------------
; Purpose:
;  Perform the Grouping operation on the selected items.
;
function IDLitopGroup::DoAction, oTool

    compile_opt idl2, hidden

    ; Make sure we have a tool.
    if not obj_valid(oTool) then $
        return, obj_new()

    ; Get the selected objects.
    oSelVis = oTool->GetSelectedItems(COUNT=nVis)

    ; Nothing selected, or only 1 item.
    if (nVis le 1) then $
        return, OBJ_NEW()

    oSelVis[0]->GetProperty, _PARENT=oParent

    ; All selected objects must have the same parent.
    ; We also need to retrieve the positions.
    isContained = oParent->IsContained(oSelVis, POSITION=positions)
    if (MIN(isContained) eq -1) then $
        return, OBJ_NEW()

    ; We want to group objects in the same order as they were in their
    ; parent, not in their selection order.
    oSelVis = oSelVis[SORT(positions)]

    idSelVis = STRARR(nVis)
    idSelVis[0] = oSelVis[0]->GetFullIdentifier()

    for i=1, nVis-1 do $
        idSelVis[i] = oSelVis[i]->GetFullIdentifier()


    ; Let's make a commmand set for this operation. This is produced
    ; by the super-class.
    oCommandSet = self->IDLitOperation::DoAction(oTool)
    oCommandSet->SetProperty, NAME='Group'
    oCmd = OBJ_NEW('IDLitCommand')
    dummy = oCmd->AddItem('GROUPED_ITEMS', idSelVis)
    oCommandSet->Add, oCmd

    oTool->DisableUpdates, PREVIOUSLY_DISABLED=previouslyDisabled

    ; Call our superclass method.
    dummy = self->IDLitopGrouping::_DoGroupCommand(oCommandSet, oSelVis)

    IF (~previouslyDisabled) THEN $
      oTool->EnableUpdates

    return, oCommandSet

end


;-------------------------------------------------------------------------
pro IDLitopGroup__define

    compile_opt idl2, hidden

    struc = {IDLitopGroup, $
             inherits IDLitopGrouping $
            }

end

