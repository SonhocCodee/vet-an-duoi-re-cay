# Campaign Balance Baseline

## Scope

This document audits the nine Chapter 2-10 definitions and all 26 campaign enemy and loot resources. It records the current balance curve without changing production assets.

The automated guard lives in `res://tests/campaign/balance/campaign_balance_test.gd`. It treats the three encounter IDs in each `ChapterDefinition` as that chapter's normal-enemy sample and validates every campaign enemy's linked `LootTable`.

## Current Curve

| Chapter | Normal level range (average) | Average HP | Average damage | Average enemy XP | Chapter XP | Boss | Boss L / HP / damage / XP |
| --- | ---: | ---: | ---: | ---: | ---: | --- | ---: |
| 2 | 7-13 (10.3) | 171.7 | 22.0 | 100.0 | 1,200 | Drowned Executioner | 10 / 1,100 / 30 / 520 |
| 3 | 11-15 (13.0) | 200.0 | 27.0 | 126.7 | 2,400 | Hollow Paladin | 13 / 1,500 / 38 / 760 |
| 4 | 13-17 (15.0) | 198.3 | 30.0 | 140.0 | 4,200 | Blind Archivist | 16 / 1,750 / 45 / 980 |
| 5 | 19-23 (21.0) | 356.7 | 42.3 | 260.0 | 7,000 | Quartz Matriarch | 20 / 2,400 / 56 / 1,350 |
| 6 | 21-25 (23.0) | 403.3 | 46.0 | 286.7 | 10,500 | Burning Root | 23 / 2,900 / 64 / 1,650 |
| 7 | 26-30 (28.0) | 523.3 | 57.3 | 460.0 | 15,000 | Betrayer Knight | 25 / 3,400 / 72 / 1,950 |
| 8 | 27-30 (28.3) | 536.7 | 58.3 | 473.3 | 21,000 | Empty Abbot | 28 / 4,100 / 80 / 2,400 |
| 9 | 31-33 (32.0) | 713.3 | 72.0 | 746.7 | 30,000 | False Sun | 31 / 5,200 / 92 / 3,100 |
| 10 | 31-33 (32.0) | 713.3 | 72.0 | 746.7 | 50,000 | Papal Root Avatar | 33 / 6,500 / 105 / 3,900 |

`boss_corrupted_asterion` is the tenth boss resource and an endgame benchmark: level 35, 8,200 HP, 120 damage and 5,000 XP. It is included in the 26-resource integrity and loot checks even though the nine chapter definitions do not currently reference it.

## Intended Shape

- **Levels:** Average normal-enemy level must not decrease between chapters. Reusing the Chapter 9 roster in Chapter 10 is accepted as a plateau because the boss and chapter reward still rise.
- **HP and damage:** A later chapter may dip by at most 10% in either average HP or average base attack. This permits small roster-composition changes such as Chapter 4 while catching a materially weaker later chapter.
- **Enemy XP:** Average normal-enemy XP follows the same 10% regression tolerance so harder chapters do not become less efficient to play.
- **Chapter reward:** `reward_exp` must be strictly increasing and at least 20% above the previous chapter. The current curve rises from 1,200 to 50,000 and clears this floor.
- **Boss floor:** A boss must not be below the weakest normal enemy's level, and must exceed the strongest normal enemy in HP, base attack and XP reward. The level comparison uses the weakest enemy because boss identity is primarily expressed through its much larger stat package rather than matching every elite's level label.
- **Loot validity:** All 26 enemies must have a non-empty loot table. Every entry must use a chance in `0.0..1.0`, positive quantities, and `maximum_amount >= minimum_amount`.

## Audit Findings

- Normal-wave HP has one negligible dip from Chapter 3 to Chapter 4: 200.0 to 198.3, or about 0.8%. Damage, level and XP continue upward, so this is within the 10% composition tolerance.
- Chapter 10 intentionally repeats Chapter 9's three normal enemies. Its difficulty escalation comes from the boss rising from 5,200 to 6,500 HP, 92 to 105 damage, and the chapter reward rising from 30,000 to 50,000 XP.
- Boss HP is 4.78x-7.93x the strongest normal enemy in the same chapter. Boss damage is 1.07x-1.41x, and boss XP is 3.69x-6.53x.
- `boss_betrayer_knight` is level 25 while Chapter 7 normal enemies start at level 26. The test intentionally reports this as a balance regression; production data should raise the boss to at least level 26 or explicitly revise the guardrail after a documented combat-design decision.
- All currently audited loot chances are within `0.0..1.0`; the automated test prevents future invalid probabilities and malformed quantity ranges.

## Running The Guard

Run the dedicated scene headlessly:

```powershell
& "D:\Temp\godot43_validation\Godot_v4.3-stable_win64.exe" --headless --path "D:\Son\GAME" "res://tests/campaign/balance/campaign_balance_test.tscn"
```

The test prints `[CAMPAIGN BALANCE][FAIL]` for every violation and exits with code `1` if any check fails.
