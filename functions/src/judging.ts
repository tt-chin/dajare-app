import {containsUnsafeContent} from "./safety";

export type DajareLevel = "cold" | "good" | "laugh" | "genius" | "legend";

export interface JudgeResult {
  isDajare: boolean;
  score: number;
  word1: string;
  word2: string;
  comment: string;
  level: DajareLevel;
}

export const unsafeRedirect =
  "ほかのことばでダジャレを作ってみよう！どうぶつや食べもののお題がおすすめだよ。";

const maxWordLength = 40;
const maxCommentLength = 120;
const forbiddenPresentation = /<[^>]*>|```|\[[^\]]*\]\([^)]*\)|https?:\/\//iu;

export class InvalidGeminiResponseError extends Error {
  constructor() {
    super("Gemini returned an invalid judge response");
    this.name = "InvalidGeminiResponseError";
  }
}

export function levelFromScore(score: number): DajareLevel {
  if (!Number.isInteger(score) || score < 0 || score > 100) {
    throw new RangeError("score must be an integer from 0 to 100");
  }
  if (score === 100) return "legend";
  if (score >= 90) return "genius";
  if (score >= 70) return "laugh";
  if (score >= 40) return "good";
  return "cold";
}

export function createUnsafeFallback(): JudgeResult {
  return {
    isDajare: false,
    score: 0,
    word1: "",
    word2: "",
    comment: unsafeRedirect,
    level: "cold",
  };
}

export function parseGeminiJudgeResponse(
  responseText: string | undefined,
): JudgeResult {
  if (responseText === undefined) {
    throw new InvalidGeminiResponseError();
  }

  let value: unknown;
  try {
    value = JSON.parse(responseText);
  } catch {
    throw new InvalidGeminiResponseError();
  }

  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new InvalidGeminiResponseError();
  }

  const record = value as Record<string, unknown>;
  const expectedKeys = ["comment", "isDajare", "score", "word1", "word2"];
  if (Object.keys(record).sort().join(",") !== expectedKeys.join(",")) {
    throw new InvalidGeminiResponseError();
  }

  const {isDajare, score, word1, word2, comment} = record;
  if (
    typeof isDajare !== "boolean" ||
    typeof score !== "number" ||
    !Number.isInteger(score) ||
    score < 0 ||
    score > 100 ||
    typeof word1 !== "string" ||
    word1.length > maxWordLength ||
    typeof word2 !== "string" ||
    word2.length > maxWordLength ||
    typeof comment !== "string" ||
    comment.trim().length === 0 ||
    comment.length > maxCommentLength ||
    (isDajare && (word1.trim().length === 0 || word2.trim().length === 0))
  ) {
    throw new InvalidGeminiResponseError();
  }

  if (
    containsUnsafeContent(`${word1}\n${word2}\n${comment}`) ||
    forbiddenPresentation.test(`${word1}\n${word2}\n${comment}`)
  ) {
    return createUnsafeFallback();
  }

  return {
    isDajare,
    score,
    word1: word1.trim(),
    word2: word2.trim(),
    comment: comment.trim(),
    level: levelFromScore(score),
  };
}
