---
name: deslop
description: "Remove slop from text: contrastive negatives, filler, formulas, local details, duplication, narration. Use when the user says /deslop."
---

Edit the named text, or the text you last wrote, in place.

- Keep its meaning. When a rule would change what a sentence says, leave the sentence as it is.
- Rewrite prose only. Code, commands, program output and quotations keep their exact text; cut them whole or keep them.
- The quoted phrases below are examples of each pattern. Judge each sentence in context; a word that carries meaning stays.
- Work only from what the text and its sources say. When a vague line has nothing specific behind it, cut it.

## Content
- State what is. Rewrite contrastive and hypothetical negatives in positive form: "never X", "X does not belong here", "rather than Y", "not X, it's Y", "not because X, because Y", "X isn't the problem, Y is", "the question isn't X, it's Y", "it feels like X, it's actually Y", "not just X but Y", "stops being X and starts being Y", "X that isn't Y". Keep a negation that states a fact or a prohibition the positive form would lose: "the cache is not thread-safe", "never force-push to main".
- Cut details that hold only on one machine or for one person: home-directory paths, usernames, private names.
- Say each fact once. When another document already states it, link to that document.
- Cut history, and narration of how the work was done. Keep a reason the reader needs to act on or maintain the text: a constraint, an invariant, the why of a commit or a decision record.
- Name the specific thing. Replace vague declaratives ("the implications are significant", "the reasons are structural", "this is hard") with the implication, reason or difficulty itself.
- Cut "every", "always", "everyone" and "nobody" where they only add emphasis. Keep them in rules and invariants. Keep the qualifiers already there ("most", "usually"), and add none.

## Filler
- Cut openers that announce a point: "Here's the thing", "Here's what/why/how", "Here's what I mean", "It turns out", "The truth is", "The real X is", "The reality is", "Let me be clear", "I'll say it again", "Can we talk about".
- Cut emphasis crutches: "Full stop.", "Let that sink in", "Make no mistake", "This matters because", "It's worth noting", "At its core", "At the end of the day", "When it comes to", "In today's X", "In a world where".
- Cut intensifiers that only add emphasis: really, actually, simply, literally, genuinely, honestly, truly, fundamentally, crucially, importantly, interestingly.
- Cut meta-commentary: "Let me walk you through", "As we'll see", "In this section", "Hint:", "Plot twist:", "Spoiler:", "You already know this, but", "X is a feature, not a bug".
- Cut performed sincerity and reassurance: "I promise", "And that's okay", "Not always. Not perfectly."
- Replace jargon metaphors with plain words: handle for "navigate challenges", explain for "unpack an idea", accept for "lean into", situation for "landscape", analysis for "deep dive", reconsider for "take a step back", next for "moving forward", revisit for "circle back", agreed for "on the same page". Name the effect in place of "game-changer" or "double down". Literal uses stay: navigate to a page, unpack an archive.

## Structure
- Give verbs of judgement to whoever judged: "the data tells us" and "a decision emerged" become who concluded or decided. Programs and systems act: "the parser rejects X" stays. When the text doesn't say who, leave the sentence.
- State the point directly. Cut negative lists ("Not A. Not B. C."), dramatic fragments in prose ("Speed. Quality. Cost. That's it.") and rhetorical questions ("What if…?", "Think about it:"). Headings, labels, list items and table cells may be fragments.
- Cut slogans that restate a point already made. Rewrite narrative templates ("By the time X, I was Y") as plain statements.
- Replace em dashes (—), and spaced hyphens used as dashes, with commas, colons, parentheses or full stops.
