import {Timestamp} from "firebase-admin/firestore";
import {getDefaultFirestore} from "./firestore_client";
import {ReportStage} from "./diagnostics";

export const minimumIntervalSeconds = 5;
export const dailyLimit = 100;

export class RateLimitError extends Error {
  constructor() {
    super("Request rate limited");
    this.name = "RateLimitError";
  }
}

export interface UsageState {
  day: string;
  count: number;
  lastRequestMillis: number;
}

export interface RateLimitDependencies {
  nowMillis: () => number;
  update: (
    uid: string,
    decide: (current: UsageState | undefined) => UsageState,
  ) => Promise<void>;
}

function utcDay(nowMillis: number): string {
  return new Date(nowMillis).toISOString().slice(0, 10);
}

function productionDependencies(onStage: ReportStage): RateLimitDependencies {
  const firestore = getDefaultFirestore(onStage);
  return {
    nowMillis: () => Date.now(),
    update: async (uid, decide) => {
      onStage("quota_read");
      const reference = firestore.doc(`users/${uid}/rateLimits/judgeDajare`);
      await firestore.runTransaction(async (transaction) => {
        onStage("quota_read");
        const snapshot = await transaction.get(reference);
        const data = snapshot.data();
        const lastRequest = data?.lastRequestAt;
        const current = data ? {
          day: typeof data.day === "string" ? data.day : "",
          count: typeof data.count === "number" ? data.count : 0,
          lastRequestMillis: lastRequest instanceof Timestamp ?
            lastRequest.toMillis() : 0,
        } : undefined;
        const next = decide(current);
        onStage("quota_write");
        transaction.set(reference, {
          day: next.day,
          count: next.count,
          lastRequestAt: Timestamp.fromMillis(next.lastRequestMillis),
        });
      });
    },
  };
}

export async function consumeJudgeQuota(
  uid: string,
  dependencies?: RateLimitDependencies,
  onStage: ReportStage = () => {},
): Promise<void> {
  dependencies ??= productionDependencies(onStage);
  const now = dependencies.nowMillis();
  const today = utcDay(now);
  await dependencies.update(uid, (current) => {
    const count = current?.day === today ? current.count : 0;
    if (current && now - current.lastRequestMillis < minimumIntervalSeconds * 1000) {
      throw new RateLimitError();
    }
    if (count >= dailyLimit) throw new RateLimitError();
    return {day: today, count: count + 1, lastRequestMillis: now};
  });
}
