import {FieldValue} from "firebase-admin/firestore";
import {getDefaultFirestore} from "./firestore_client";

import {JudgeResult} from "./judging";
import {ReportStage} from "./diagnostics";

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

function productionDependencies(onStage: ReportStage): DajareEntryStoreDependencies {
  const firestore = getDefaultFirestore(onStage);
  return {
    serverTimestamp: () => FieldValue.serverTimestamp(),
    write: async (path, entry) => {
      await firestore.collection(path).add(entry);
    },
  };
}

export async function saveTrustedDajareEntry(
  uid: string,
  submittedText: string,
  result: JudgeResult,
  dependencies?: DajareEntryStoreDependencies,
  onStage: ReportStage = () => {},
): Promise<void> {
  dependencies ??= productionDependencies(onStage);
  onStage("entry_write");
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
