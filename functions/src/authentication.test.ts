import assert from "node:assert/strict";
import test from "node:test";

import {
  requireAuthenticatedUid,
  UnauthenticatedRequestError,
} from "./authentication";

test("rejects an unauthenticated request", () => {
  assert.throws(
    () => requireAuthenticatedUid(undefined),
    UnauthenticatedRequestError,
  );
});

test("returns the authenticated uid", () => {
  assert.equal(requireAuthenticatedUid({uid: "test-user"}), "test-user");
});
