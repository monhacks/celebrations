Daycare_Script:
	jp EnableAutoTextBoxDrawing

Daycare_TextPointers:
	def_text_pointers
	dw_const DaycareGentlemanText, TEXT_DAYCARE_GENTLEMAN

DaycareGentlemanText:
	text_asm
	call SaveScreenTilesToBuffer2
	ld a, [wDayCareInUse]
	and a
	jp nz, .daycareInUse
	ld hl, .IntroText
	rst _PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ld hl, .ComeAgainText
	jp nz, .done
	ld a, [wPartyCount]
	dec a
	ld hl, .OnlyHaveOneMonText
	jp z, .done
	ld hl, .WhichMonText
	rst _PrintText
	xor a
	ld [wUpdateSpritesEnabled], a
	ld [wPartyMenuTypeOrMessageID], a
	ld [wMenuItemToSwap], a
	call DisplayPartyMenu
	push af
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	pop af
	ld hl, .AllRightThenText
	jp c, .done
;	callfar KnowsHMMove
;	ld hl, .CantAcceptMonWithHMText
;	jp c, .done
	xor a
	ld [wPartyAndBillsPCSavedMenuItem], a
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	ld hl, .WillLookAfterMonText
	rst _PrintText
	ld a, 1
	ld [wDayCareInUse], a
	ld a, PARTY_TO_DAYCARE
	ld [wMoveMonType], a
	call MoveMon
	xor a
	ld [wRemoveMonFromBox], a
	call RemovePokemon
	ld a, [wcf91]
	call PlayCry
	ld hl, .ComeSeeMeInAWhileText
	jp .done

.daycareInUse
	xor a
	ld hl, wDayCareMonName
	call GetPartyMonName
	ld a, DAYCARE_DATA
	ld [wMonDataLocation], a
	call LoadMonData
	callfar CalcLevelFromExperience

	push bc
	ld a, [wDifficulty] ; Check if player is on hard mode
	and a
	ld b, MAX_LEVEL
	jr z, .next1 ; no level caps if not on hard mode

	ld a, [wGameStage] ; Check if player has beat the game
	and a
	jr nz, .next1
	farcall GetBadgesObtained
	ld a, [wNumSetBits]
	cp 8
	ld b, 65 ; Blastoise/Charizard/Venusaur's level
	jr nc, .next1
	cp 7
	ld b, 53 ; Rhydon's level
	jr nc, .next1
	cp 6
	ld b, 50 ; Arcanine's level
	jr nc, .next1
	cp 5
	ld b, 48 ; Alakazam's level
	jr nc, .next1
    	cp 4
	ld b, 44 ; Weezing's level
	jr nc, .next1
	cp 3
	ld b, 37 ; Vileplume's level
	jr nc, .next1
	cp 2
        ld b, 28 ; Raichu's level
	jr nc, .next1
	cp 1
	ld b, 22 ; Starmie's level
	jr nc, .next1
	ld b, 15 ; Onix's level
.next1
	ld a, b
	ld [wMaxDaycareLevel], a
	ld a, d
	cp b
	pop bc
	jr c, .skipCalcExp

	ld a, [wMaxDaycareLevel]
	ld d, a
	callfar CalcExperience
	ld hl, wDayCareMonExp
	ldh a, [hExperience]
	ld [hli], a
	ldh a, [hExperience + 1]
	ld [hli], a
	ldh a, [hExperience + 2]
	ld [hl], a
	ld a, [wMaxDaycareLevel]
	ld d, a

.skipCalcExp
	xor a
	ld [wDayCareNumLevelsGrown], a
	ld hl, wDayCareMonBoxLevel
	ld a, [hl]
	ld [wDayCareStartLevel], a
	cp d
	ld [hl], d
	ld hl, .MonNeedsMoreTimeText
	jr z, .next
	ld a, [wDayCareStartLevel]
	ld b, a
	ld a, d
	sub b
	ld [wDayCareNumLevelsGrown], a
	ld hl, .MonHasGrownText

.next
	rst _PrintText
	ld a, [wPartyCount]
	cp PARTY_LENGTH
	ld hl, .NoRoomForMonText
	jp z, .leaveMonInDayCare
	ld de, wDayCareTotalCost
	xor a
	ld [de], a
	inc de
	ld [de], a
	ld hl, wDayCarePerLevelCost
	ld a, $1
	ld [hli], a
	ld [hl], $0
	ld a, [wDayCareNumLevelsGrown]
	inc a
	ld b, a
	ld c, 2
.calcPriceLoop
	push hl
	push de
	push bc
	predef AddBCDPredef
	pop bc
	pop de
	pop hl
	dec b
	jr nz, .calcPriceLoop
	ld hl, .OweMoneyText
	rst _PrintText
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	call YesNoChoice
	ld hl, .AllRightThenText
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .leaveMonInDayCare
	ld hl, wDayCareTotalCost
	ldh [hMoney], a
	ld a, [hli]
	ldh [hMoney + 1], a
	ld a, [hl]
	ldh [hMoney + 2], a
	call HasEnoughMoney
	jr nc, .enoughMoney
	ld hl, .NotEnoughMoneyText
	jp .leaveMonInDayCare

.enoughMoney
	xor a
	ld [wDayCareInUse], a
	ld hl, wDayCareNumLevelsGrown
	ld [hli], a
	inc hl
	ld de, wPlayerMoney + 2
	ld c, $3
	predef SubBCDPredef
	ld a, SFX_PURCHASE
	call PlaySoundWaitForCurrent
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	ld hl, .HeresYourMonText
	rst _PrintText
	ld a, DAYCARE_TO_PARTY
	ld [wMoveMonType], a
	call MoveMon
	ld a, [wDayCareMonSpecies]
	ld [wcf91], a
	ld a, [wPartyCount]
	dec a
	push af
	ld bc, wPartyMon2 - wPartyMon1
	push bc
	ld hl, wPartyMon1Moves
	call AddNTimes
	ld d, h
	ld e, l
	ld a, 1
	ld [wLearningMovesFromDayCare], a
	predef WriteMonMoves
	pop bc
	pop af

; set mon's HP to max
	ld hl, wPartyMon1HP
	call AddNTimes
	ld d, h
	ld e, l
	ld bc, wPartyMon1MaxHP - wPartyMon1HP
	add hl, bc
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a

	ld a, [wcf91]
	call PlayCry
	ld hl, .GotMonBackText
	jr .done

.leaveMonInDayCare
	ld a, [wDayCareStartLevel]
	ld [wDayCareMonBoxLevel], a

.done
	rst _PrintText
	rst TextScriptEnd

.IntroText:
	text_far _DaycareGentlemanIntroText
	text_end

.WhichMonText:
	text_far _DaycareGentlemanWhichMonText
	text_end

.WillLookAfterMonText:
	text_far _DaycareGentlemanWillLookAfterMonText
	text_end

.ComeSeeMeInAWhileText:
	text_far _DaycareGentlemanComeSeeMeInAWhileText
	text_end

.MonHasGrownText:
	text_far _DaycareGentlemanMonHasGrownText
	text_end

.OweMoneyText:
	text_far _DaycareGentlemanOweMoneyText
	text_end

.GotMonBackText:
	text_far _DaycareGentlemanGotMonBackText
	text_end

.MonNeedsMoreTimeText:
	text_far _DaycareGentlemanMonNeedsMoreTimeText
	text_end

.AllRightThenText:
	text_far _DaycareGentlemanAllRightThenText
.ComeAgainText:
	text_far _DaycareGentlemanComeAgainText
	text_end

.NoRoomForMonText:
	text_far _DaycareGentlemanNoRoomForMonText
	text_end

.OnlyHaveOneMonText:
	text_far _DaycareGentlemanOnlyHaveOneMonText
	text_end

.CantAcceptMonWithHMText:
	text_far _DaycareGentlemanCantAcceptMonWithHMText
	text_end

.HeresYourMonText:
	text_far _DaycareGentlemanHeresYourMonText
	text_end

.NotEnoughMoneyText:
	text_far _DaycareGentlemanNotEnoughMoneyText
	text_end
