DisplayPokemonCenterDialogue_::
	call SaveScreenTilesToBuffer1 ; save screen
	ld hl, PokemonCenterWelcomeText
	rst _PrintText
	ld hl, wd72e
	bit 2, [hl]
	set 1, [hl]
	set 2, [hl]
	jr nz, .skipShallWeHealYourPokemon
	ld hl, ShallWeHealYourPokemonText
	rst _PrintText
.skipShallWeHealYourPokemon
	call YesNoChoicePokeCenter ; yes/no menu
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .declinedHealing ; if the player chose No
	call SetLastBlackoutMap
	call LoadScreenTilesFromBuffer1 ; restore screen
	ld hl, NeedYourPokemonText
	rst _PrintText
	ld a, $18
	ld [wSprite01StateData1ImageIndex], a ; make the nurse turn to face the machine
	call Delay3
	predef HealParty
	farcall AnimateHealingMachine ; do the healing machine animation
	xor a
	ld [wMusicFade], a
;	ld a, [wAudioSavedROMBank]
;	ld [wAudioROMBank], a
	ld a, [wMapMusicSoundID]
	ld [wLastMusicSoundID], a
;	ld [wNewSoundID], a
	call PlayMusic
	ld hl, PokemonFightingFitText
	rst _PrintText
	ld a, $14
	ld [wSprite01StateData1ImageIndex], a ; make the nurse bow
	ld c, a
	rst _DelayFrames
	jr .done
.declinedHealing
	call LoadScreenTilesFromBuffer1 ; restore screen
.done
	ld hl, PokemonCenterFarewellText
	rst _PrintText
	jp UpdateSprites

PokemonCenterWelcomeText:
	text_far _PokemonCenterWelcomeText
	text_end

ShallWeHealYourPokemonText:
	text_pause
	text_far _ShallWeHealYourPokemonText
	text_end

NeedYourPokemonText:
	text_far _NeedYourPokemonText
	text_end

PokemonFightingFitText:
	text_far _PokemonFightingFitText
	text_end

PokemonCenterFarewellText:
	text_pause
	text_far _PokemonCenterFarewellText
	text_end
