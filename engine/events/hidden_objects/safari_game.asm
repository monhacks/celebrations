SafariZoneCheck::
	CheckEventHL EVENT_IN_SAFARI_ZONE ; if we are not in the Safari Zone,
	jr z, SafariZoneGameStillGoing ; don't bother printing game over text
	ld a, [wSafariType]
	cp SAFARI_TYPE_FREE_ROAM
	jr z, SafariZoneGameStillGoing
	ld a, [wNumSafariBalls]
	and a
	jr z, SafariZoneGameOver
	jr SafariZoneGameStillGoing

SafariZoneCheckSteps::
IF DEF(_DEBUG)
	call DebugPressedOrHeldB
	ret nz
ENDC
	ld a, [wSafariType]
	cp SAFARI_TYPE_FREE_ROAM
	ret z
	ld a, [wSafariSteps]
	ld b, a
	ld a, [wSafariSteps + 1]
	ld c, a
	or b
	jr z, SafariZoneGameOver
	dec bc
	ld a, b
	ld [wSafariSteps], a
	ld a, c
	ld [wSafariSteps + 1], a
SafariZoneGameStillGoing:
	xor a
	ld [wSafariZoneGameOver], a
	ret

SafariZoneGameOver:
	call EnableAutoTextBoxDrawing
	xor a
	ld [wMusicFade], a
	dec a ; SFX_STOP_ALL_MUSIC
	rst _PlaySound
	ld c, 0 ; BANK(SFX_Safari_Zone_PA)
	ld a, SFX_SAFARI_ZONE_PA
	rst _PlaySound

	call WaitForSoundToFinish
;.waitForMusicToPlay
;	ld a, [wChannelSoundIDs + CHAN5]
;	cp SFX_SAFARI_ZONE_PA
;	jr nz, .waitForMusicToPlay

	ld a, TEXT_SAFARI_GAME_OVER
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	xor a
	ld [wPlayerMovingDirection], a
	ld a, SAFARI_ZONE_GATE
	ldh [hWarpDestinationMap], a
	ld a, $3
	ld [wDestinationWarpID], a
	ld a, SCRIPT_SAFARIZONEGATE_LEAVING_SAFARI
	ld [wSafariZoneGateCurScript], a
	SetEvent EVENT_SAFARI_GAME_OVER
	ld a, 1
	ld [wSafariZoneGameOver], a
	ret

PrintSafariGameOverText::
	xor a
	ld [wJoyIgnore], a
	ld hl, SafariGameOverText
	jp PrintText

SafariGameOverText:
	text_asm
	ld a, [wNumSafariBalls]
	and a
	jr z, .noMoreSafariBalls
	ld hl, TimesUpText
	rst _PrintText
.noMoreSafariBalls
	ld hl, GameOverText
	rst _PrintText
	rst TextScriptEnd

; PureRGBnote: ADDED: used when leaving the safari zone by flying, teleporting, blacking out, etc.
;                     clears all variables related to the safari game you were in
ClearSafariFlags::
	ResetEvents EVENT_SAFARI_GAME_OVER, EVENT_IN_SAFARI_ZONE
	xor a
	ld [wSafariType], a
	ld [wNumSafariBalls], a
	ld [wSafariSteps], a
	ld [wSafariZoneGameOver], a 
	ld [wSafariZoneGateCurScript], a ; SCRIPT_SAFARIZONEGATE_DEFAULT
	ret

TimesUpText:
	text_far _TimesUpText
	text_end

GameOverText:
	text_far _GameOverText
	text_end
