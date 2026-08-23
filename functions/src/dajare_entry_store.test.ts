import assert from "node:assert/strict";
import test from "node:test";

import {
  DAJARE_ENTRY_FIELDS,
  saveTrustedDajareEntry,
  TrustedDajareEntry,
} from "./dajare_entry_store";
import {JudgeResult} from "./judging";

const result: JudgeResult = {
  isDajare: true,
  score: 88,
  level: "genius",
  word1: "パンダ",
  word2: "パンだ",
  comment: "いい音だね！",
};

test("writes only the trusted fields under the authenticated user path", async () => {
  const timestamp = {serverTimestamp: true};
  let writtenPath = "";
  let writtenEntry: TrustedDajareEntry | undefined;

  await saveTrustedDajareEntry("user-1", "パンダがパンだ！", result, {
    serverTimestamp: () => timestamp,
    write: async (path, entry) => {
      writtenPath = path;
      writtenEntry = entry;
    },
  });

  assert.equal(writtenPath, "users/user-1/dajareEntries");
  assert.deepEqual(Object.keys(writtenEntry!).sort(), [...DAJARE_ENTRY_FIELDS].sort());
  assert.equal(writtenEntry!.createdAt, timestamp);
  assert.equal(writtenEntry!.submittedText, "パンダがパンだ！");
  assert.equal(writtenEntry!.score, 88);
});
