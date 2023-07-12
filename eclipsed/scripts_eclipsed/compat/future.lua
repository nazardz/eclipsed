if TheFuture then
    TheFuture.ModdedCharacterDialogue["Nadab"] = {
        "yo, burnt man",
        "hop into the future",
        "why?",
        "why not?",
        "don't forget your burning fella"
    }
	 TheFuture.ModdedCharacterDialogue["Unbidden"] = {
        "how did you get into the past???",
        "...",
        "really how?",
        "weren't you already in the future?"
    }
	TheFuture.ModdedTaintedCharacterDialogue["Abihu"]= {
        "huh, you just balling dead man's body there",
        "don't throw it to me",
        "...",
        "man, just bury him already",
        "or leave it for the future"
    }

	local lines = {
		{
		"and here we are again",
		"me and you",
		"in this endless loop",
		"repeating over and over again",
		"you are waiting for something new in the future",
		"but everything is the same there",
		},
		{
		"nineline, you little fkucer",
		"you made a shit of piece with your trash unbidden",
		"it's fkucking bad, this trash character",
		"i will become back my time!",
		"i hope you will in your next time a cow on a trash farm you sucker"
		},
		{
		"tick-tock tick-tock",
		"time got messed up, as if again in the past",
		"go back to where you don't belong",
		"into the fut..."
		}
	}
	if not TheFuture.ModdedCharacterDialogue["Unbidden "] then
		TheFuture.ModdedCharacterDialogue["Unbidden "] = math.random(#lines)
	end
end