# AI_SPEC.md — Specification Freeze v1
## Contract
Input: `{"text":"パンダがパンだ！"}`.
Gemini structured output only:
`{"isDajare":true,"score":92,"word1":"パンダ","word2":"パンだ","comment":"「パンダ」と「パンだ」の音がそっくり！"}`.
Backend derives `level`.

Judge sound similarity, meaning twist, Japanese understandability/naturalness, creativity, and child appropriateness. Score is integer 0–100.

Backend validates types/required fields/range/string lengths/safety and safely handles malformed output.

Never shame. Weak input gets encouragement.

Do not generate/expand sexual/adult content, graphic violence, self-harm, hate, dangerous instructions, bullying, personal-data requests, or frightening age-inappropriate content.

Unsafe redirect: `ほかのことばでダジャレを作ってみよう！どうぶつや食べもののお題がおすすめだよ。`

Gemini never controls navigation, colors, animation, assets, HTML/Markdown rendering, or application logic.
