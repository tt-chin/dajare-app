import {getApps, initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore} from "firebase-admin/firestore";

import {JudgeResult} from "./judging";

export const DAJARE_ENTRY_FIELDS = [
  "submittedText",
  "isDajare",
  "score",
  "level",
  "word1",
  "word2",
  "comment",
  "createdAt",
] as const;

export interface TrustedDajareEntry {
  submittedText: string;
  isDajare: boolean;
  score: number;
  level: JudgeResult["level"];
  word1: string;
  word2: string;
  comment: string;
  createdAt: unknown;
}

export interface DajareEntryStoreDependencies {
  serverTimestamp: () => unknown;
  write: (path: string, entry: TrustedDajareEntry) => Promise<void>;
}

function productionDependencies(): DajareEntryStoreDependencies {
  if (getApps().length === 0) {
    initializeApp();
  }

  return {
    serverTimestamp: () => FieldValue.serverTimestamp(),
    write: async (path, entry) => {
      await getFirestore().collection(path).add(entry);
    },
  };
}

export async function saveTrustedDajareEntry(
  uid: string,
  submittedText: string,
  result: JudgeResult,
  dependencies: DajareEntryStoreDependencies = productionDependencies(),
): Promise<void> {
  const path = `users/${uid}/dajareEntries`;
  const entry: TrustedDajareEntry = {
    submittedText,
    isDajare: result.isDajare,
    score: result.score,
    level: result.level,
    word1: result.word1,
    word2: result.word2,
    comment: result.comment,
    createdAt: dependencies.serverTimestamp(),
  };

  await dependencies.write(path, entry);
}
