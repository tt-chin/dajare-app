import {logger} from "firebase-functions";
import {defineSecret} from "firebase-functions/params";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {
  requireAuthenticatedUid,
  UnauthenticatedRequestError,
} from "./authentication";
import {saveTrustedDajareEntry} from "./dajare_entry_store";
import {cleanupDajareEntries} from "./collection_retention";
import {JudgeStage, safeDiagnostics} from "./diagnostics";
import {
  GeminiUnavailableError,
  runGeminiJudge,
} from "./gemini";
import {
  createUnsafeFallback,
  InvalidGeminiResponseError,
  JudgeResult,
} from "./judging";
import {containsUnsafeContent} from "./safety";
import {judgeAndPersist} from "./judge_service";
import {consumeJudgeQuota, RateLimitError} from "./rate_limit";
import {
  RequestValidationError,
  UnsafeInputError,
  validateJudgeRequest,
} from "./validation";

const geminiApiKey = defineSecret("GEMINI_API_KEY");

export const judgeDajare = onCall<unknown, Promise<JudgeResult>>(
  {
    region: "asia-northeast1",
    secrets: [geminiApiKey],
    enforceAppCheck: false,
    timeoutSeconds: 30,
    maxInstances: 10,
  },
  async (request) => {
    let stage: JudgeStage = "validation";
    const onStage = (next: JudgeStage) => { stage = next; };
    try {
      const uid = requireAuthenticatedUid(request.auth);
      const text = validateJudgeRequest(request.data);
      if (containsUnsafeContent(text)) {
        throw new UnsafeInputError();
      }
      return await judgeAndPersist(uid, text, {
        consumeQuota: (uid) => consumeJudgeQuota(uid, undefined, onStage),
        judge: (input) => {
          onStage("ai_judge");
          return runGeminiJudge(input, geminiApiKey.value());
        },
        save: (uid, input, result) =>
          saveTrustedDajareEntry(uid, input, result, undefined, onStage),
        onSaveFailure: (saveError) => {
          logger.warn("judgeDajare persistence failed",
            safeDiagnostics(saveError, stage));
        },
        cleanup: cleanupDajareEntries,
        onCleanupFailure: (error) => {
          logger.warn("judgeDajare cleanup failed",
            safeDiagnostics(error, "entry_cleanup"));
        },
      });
    } catch (error) {
      if (error instanceof UnauthenticatedRequestError) {
        throw new HttpsError(
          "unauthenticated",
          "アプリをはじめる準備ができていません。",
        );
      }

      if (error instanceof RequestValidationError) {
        throw new HttpsError(
          "invalid-argument",
          "入力内容を確認してください。",
        );
      }

      if (error instanceof UnsafeInputError) {
        return createUnsafeFallback();
      }

      if (error instanceof RateLimitError) {
        throw new HttpsError(
          "resource-exhausted",
          "ちょっとはやすぎるみたい！\nすこしまってからためしてみてね！",
        );
      }

      if (error instanceof GeminiUnavailableError) {
        logger.warn("judgeDajare AI judging failed", safeDiagnostics(error, stage));
        throw new HttpsError(
          "unavailable",
          "うまく接続できませんでした。",
        );
      }

      if (error instanceof InvalidGeminiResponseError) {
        logger.warn("judgeDajare AI response was invalid", safeDiagnostics(error, stage));
        throw new HttpsError(
          "failed-precondition",
          "うまく判定できませんでした。",
        );
      }

      logger.error("judgeDajare failed", safeDiagnostics(error, stage));
      throw new HttpsError(
        "internal",
        "うまく処理できませんでした。",
      );
    }
  },
);
