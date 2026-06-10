-- =================================================================
-- ITEMS FOR LF-ANIMALRIDE FOR OX_INVENTORY
-- ---------------------------------------------------------------
-- The summon/buff items use `consume = 1`, so ox_inventory removes
-- one on use and the server reacts to the trusted `usedItem` event.
-- The saddle is used through the target eye, not the inventory.
-- =================================================================

['saddle'] = {
	label = 'Saddle',
	weight = 3000,
	stack = true,
	close = false,
	description = 'A leather saddle for riding animals.'
},
['cow_whistle'] = {
	label = 'Cow Whistle',
	weight = 100,
	stack = true,
	close = true,
	consume = 1,
	description = 'A special whistle. I wonder what will answer the call?'
},
['boar_caller'] = {
	label = 'Boar Caller',
	weight = 250,
	stack = true,
	close = true,
	consume = 1,
	description = 'A horn that produces a deep grunt. Might attract something wild.'
},
['animal_stimulant'] = {
	label = 'Animal Stimulant',
	weight = 200,
	stack = true,
	close = true,
	consume = 1,
	description = 'A potent concoction that will make your animal companion run much faster for a short time.'
},
['ironhide_apple'] = {
	label = 'Ironhide Apple',
	weight = 500,
	stack = true,
	close = true,
	consume = 1,
	description = 'An enchanted apple that makes your animal companion temporarily invincible.'
},

-- =================================================================
-- ITEMS FOR LF-ANIMALRIDE FOR QBCORE
-- =================================================================

['saddle'] = {
	['name'] = 'saddle',
	['label'] = 'Saddle',
	['weight'] = 3000,
	['type'] = 'item',
	['image'] = 'saddle.png',
	['unique'] = false,
	['usable'] = false,
	['shouldClose'] = false,
	['description'] = 'A leather saddle for riding animals.'
},
['cow_whistle'] = {
	['name'] = 'cow_whistle',
	['label'] = 'Cow Whistle',
	['weight'] = 100,
	['type'] = 'item',
	['image'] = 'cow_whistle.png',
	['unique'] = false,
	['usable'] = true,
	['shouldClose'] = true,
	['description'] = 'A special whistle. I wonder what will answer the call?'
},
['boar_caller'] = {
	['name'] = 'boar_caller',
	['label'] = 'Boar Caller',
	['weight'] = 250,
	['type'] = 'item',
	['image'] = 'boar_caller.png',
	['unique'] = false,
	['usable'] = true,
	['shouldClose'] = true,
	['description'] = 'A horn that produces a deep grunt. Might attract something wild.'
},
['animal_stimulant'] = {
	['name'] = 'animal_stimulant',
	['label'] = 'Animal Stimulant',
	['weight'] = 200,
	['type'] = 'item',
	['image'] = 'animal_stimulant.png',
	['unique'] = false,
	['usable'] = true,
	['shouldClose'] = true,
	['description'] = 'A potent concoction that will make your animal companion run much faster for a short time.'
},
['ironhide_apple'] = {
	['name'] = 'ironhide_apple',
	['label'] = 'Ironhide Apple',
	['weight'] = 500,
	['type'] = 'item',
	['image'] = 'ironhide_apple.png',
	['unique'] = false,
	['usable'] = true,
	['shouldClose'] = true,
	['description'] = 'An enchanted apple that makes your animal companion temporarily invincible.'
},