; displays yes/no choice
; yes -> set carry
YesNoChoice::
	call SaveScreenTilesToBuffer1
	call InitYesNoTextBoxParameters
	jr DisplayYesNoChoice

;TwoOptionMenu:: ; unreferenced
;	ld a, TWO_OPTION_MENU
;	ld [wTextBoxID], a
;	call InitYesNoTextBoxParameters
;	jp DisplayTextBoxID

InitYesNoTextBoxParameters::
	xor a ; YES_NO_MENU
	ld [wTwoOptionMenuID], a
	hlcoord 14, 7
	lb bc, 8, 15
	ret

YesNoChoicePokeCenter::
	call SaveScreenTilesToBuffer1
	ld a, HEAL_CANCEL_MENU
	ld [wTwoOptionMenuID], a
	hlcoord 11, 6
	lb bc, 8, 12
	jr DisplayYesNoChoice

DisplayYesNoChoice::
	ld a, TWO_OPTION_MENU
	ld [wTextBoxID], a
	call DisplayTextBoxID
	jp LoadScreenTilesFromBuffer1

DisplayMultiChoiceTextBox::
	xor a
	ld [wCurrentMenuItem], a
DisplayMultiChoiceTextBoxNoMenuReset::
	ld a, l
	ld [wListPointer], a
	ld a, h
	ld [wListPointer + 1], a
	ld a, b
	ld [wMenuWatchedKeys], a
	callfar DisplayMultiChoiceMenu
	ldh a, [hJoy5]
	bit BIT_B_BUTTON, a
	ret