import assert from "node:assert/strict";
import test from "node:test";
import {
  consumeJudgeQuota,
  dailyLimit,
  RateLimitDependencies,
  RateLimitError,
  UsageState,
} from "./rate_limit";

function fakeLimiter(now: number) {
  const states = new Map<string, UsageState>();
  const dependencies: RateLimitDependencies = {
    nowMillis: () => now,
    update: async (uid, decide) => {
      states.set(uid, decide(states.get(uid)));
    },
  };
  return {states, dependencies};
}

test("limits rapid requests per authenticated uid", async () => {
  const fake = fakeLimiter(Date.UTC(2026, 0, 1));
  await consumeJudgeQuota("user-a", fake.dependencies);
  await assert.rejects(consumeJudgeQuota("user-a", fake.dependencies), RateLimitError);
  await consumeJudgeQuota("user-b", fake.dependencies);
  assert.equal(fake.states.get("user-b")?.count, 1);
});

test("enforces a simple daily limit", async () => {
  const now = Date.UTC(2026, 0, 1);
  const fake = fakeLimiter(now);
  fake.states.set("user-a", {day: "2026-01-01", count: dailyLimit, lastRequestMillis: 0});
  await assert.rejects(consumeJudgeQuota("user-a", fake.dependencies), RateLimitError);
});
