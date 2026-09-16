import assert from "node:assert/strict";
import test from "node:test";
import {FieldPath, Firestore} from "firebase-admin/firestore";
import {cleanupDajareEntries, cleanupBatchSize} from "./collection_retention";

interface Entry { id: string; time: number; path: string; }

// A small query-aware Firestore double: exercises the production query builder,
// cursor exclusion, batch sizes and collection scoping without cloud writes.
function store(count: number, tied = false) {
  const ownPath = "users/owner/dajareEntries";
  const otherPath = "users/other/dajareEntries";
  let entries: Entry[] = Array.from({length: count}, (_, index) => ({
    id: String(index).padStart(6, "0"), time: tied ? 1 : index, path: ownPath,
  }));
  entries.push({id: "other-entry", time: -1, path: otherPath});
  const deleted: string[] = [];
  const batches: number[] = [];
  const reads: number[] = [];
  let failCommit = false;
  class Query {
    orders: string[] = [];
    direction = "asc";
    maximum = 0;
    boundary?: [number, string];
    projection?: string[];
    constructor(readonly path: string) {}
    orderBy(field: string | FieldPath, direction: string) {
      const query = Object.assign(new Query(this.path), this);
      query.orders = [...this.orders, typeof field === "string" ? field : "__name__"];
      query.direction = direction;
      return query;
    }
    select(...fields: string[]) { this.projection = fields; return this; }
    limit(count: number) { this.maximum = count; return this; }
    endBefore(time: number, id: string) { this.boundary = [time, id]; return this; }
    async get() {
      assert.deepEqual(this.orders, ["createdAt", "__name__"]);
      assert.ok(this.maximum > 0 && this.maximum <= cleanupBatchSize);
      assert.deepEqual(this.projection, this.boundary ? [] : ["createdAt"]);
      const compare = (a: Entry, b: Entry) => a.time - b.time || a.id.localeCompare(b.id);
      const rows = entries.filter((entry) => entry.path === this.path &&
        (!this.boundary || compare(entry, {time: this.boundary[0],
          id: this.boundary[1], path: this.path}) < 0))
        .sort((a, b) => compare(a, b) * (this.direction === "desc" ? -1 : 1))
        .slice(0, this.maximum);
      reads.push(rows.length);
      return {size: rows.length, empty: rows.length === 0, docs: rows.map((entry) => ({
        id: entry.id, get: () => entry.time, ref: entry,
      }))};
    }
  }
  const firestore = {
    collection: (path: string) => new Query(path),
    batch: () => {
      const pending: Entry[] = [];
      return {
        delete: (ref: Entry) => { pending.push(ref); },
        commit: async () => {
          if (failCommit) throw Object.assign(new Error("private input"), {code: 7});
          batches.push(pending.length);
          for (const entry of pending) {
            assert.equal(entry.path, ownPath);
            deleted.push(entry.id);
            entries = entries.filter((candidate) => candidate !== entry);
          }
        },
      };
    },
  } as unknown as Firestore;
  return {firestore, deleted, batches, reads,
    own: () => entries.filter((entry) => entry.path === ownPath),
    other: () => entries.filter((entry) => entry.path === otherPath),
    fail: () => { failCommit = true; },
  };
}

for (const count of [0, 1, 99, 100, 101, 105, 1305]) {
  test(`retains newest 100 out of ${count}, never deletes another UID`, async () => {
    const database = store(count);
    await cleanupDajareEntries("owner", database.firestore);
    assert.equal(database.own().length, Math.min(count, 100));
    assert.equal(database.other().length, 1);
    assert.deepEqual(database.deleted, Array.from({length: Math.max(0, count - 100)},
      (_, i) => String(i).padStart(6, "0")));
    assert.ok(database.batches.every((size) => size <= cleanupBatchSize));
    assert.equal(database.reads.reduce((sum, value) => sum + value, 0), count);
    // Re-running cleanup is idempotent.
    await cleanupDajareEntries("owner", database.firestore);
    assert.equal(database.own().length, Math.min(count, 100));
  });
}

test("equal timestamps retain exactly 100 with a stable document-ID boundary", async () => {
  const database = store(105, true);
  await cleanupDajareEntries("owner", database.firestore);
  assert.equal(database.own().length, 100);
  assert.deepEqual(database.deleted, ["000000", "000001", "000002", "000003", "000004"]);
});

test("failed delete leaves entries available for a later cleanup", async () => {
  const database = store(105);
  database.fail();
  await assert.rejects(cleanupDajareEntries("owner", database.firestore));
  assert.equal(database.own().length, 105);
});
