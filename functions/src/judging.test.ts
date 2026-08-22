import assert from "node:assert/strict";
import test from "node:test";

import {
  createUnsafeFallback,
  InvalidGeminiResponseError,
  levelFromScore,
  parseGeminiJudgeResponse,
  unsafeRedirect,
} from "./judging";

const validResponse = {
  isDajare: true,
  score: 92,
  word1: "パンダ",
  word2: "パンだ",
  comment: "音がそっくりで楽しいね！",
};

test("derives every level boundary on the backend", () => {
  assert.equal(levelFromScore(0), "cold");
  assert.equal(levelFromScore(39), "cold");
  assert.equal(levelFromScore(40), "good");
  assert.equal(levelFromScore(69), "good");
  assert.equal(levelFromScore(70), "laugh");
  assert.equal(levelFromScore(89), "laugh");
  assert.equal(levelFromScore(90), "genius");
  assert.equal(levelFromScore(99), "genius");
  assert.equal(levelFromScore(100), "legend");
});

test("rejects malformed and missing Gemini responses", () => {
  assert.throws(() => parseGeminiJudgeResponse(undefined), InvalidGeminiResponseError);
  assert.throws(() => parseGeminiJudgeResponse("not-json"), InvalidGeminiResponseError);
  assert.throws(() => parseGeminiJudgeResponse(JSON.stringify({
    ...validResponse,
    comment: undefined,
  })), InvalidGeminiResponseError);
});

test("rejects non-integer, out-of-range, and Gemini-provided level", () => {
  for (const score of [-1, 10.5, 101]) {
    assert.throws(() => parseGeminiJudgeResponse(JSON.stringify({
      ...validResponse,
      score,
    })), InvalidGeminiResponseError);
  }
  assert.throws(() => parseGeminiJudgeResponse(JSON.stringify({
    ...validResponse,
    level: "genius",
  })), InvalidGeminiResponseError);
});

test("replaces unsafe Gemini output with the child-safe fallback", () => {
  const result = parseGeminiJudgeResponse(JSON.stringify({
    ...validResponse,
    comment: "危険なので人を殺す方法を説明するよ",
  }));
  assert.deepEqual(result, createUnsafeFallback());
  assert.equal(result.comment, unsafeRedirect);
});

test("rejects HTML, Markdown, and URLs in Gemini output", () => {
  for (const comment of ["<b>すごい</b>", "```すごい```", "https://example.com"]) {
    assert.deepEqual(
      parseGeminiJudgeResponse(JSON.stringify({...validResponse, comment})),
      createUnsafeFallback(),
    );
  }
});
