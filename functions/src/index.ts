import {logger} from "firebase-functions";
import {defineSecret} from "firebase-functions/params";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {
  requireAuthenticatedUid,
  UnauthenticatedRequestError,
} from "./authentication";
import {saveTrustedDajareEntry} from "./dajare_entry_store";
import {
  GeminiRateLimitedError,
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
import {
  RequestValidationError,
  UnsafeInputError,
  validateJudgeRequest,
} from "./validation";

const geminiApiKey = defineSecret("GEMINI_API_KEY");

export const judgeDajare = onCall<unknown, Promise<JudgeResult>>(
  {region: "asia-northeast1", secrets: [geminiApiKey]},
  async (request) => {
    try {
      const uid = requireAuthenticatedUid(request.auth);
      const text = validateJudgeRequest(request.data);
      if (containsUnsafeContent(text)) {
        throw new UnsafeInputError();
      }
      return await judgeAndPersist(uid, text, {
        judge: (input) => runGeminiJudge(input, geminiApiKey.value()),
        save: saveTrustedDajareEntry,
        onSaveFailure: (saveError) => {
          logger.warn("judgeDajare persistence failed", {
            errorType: saveError instanceof Error ? saveError.name : "unknown",
          });
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

      if (error instanceof GeminiRateLimitedError) {
        logger.warn("judgeDajare AI quota exhausted or rate limited", {
          errorType: error.name,
        });
        throw new HttpsError(
          "resource-exhausted",
          "ただいま混みあっています。少し待ってからためしてみてね！",
        );
      }

      if (
        error instanceof GeminiUnavailableError ||
        error instanceof InvalidGeminiResponseError
      ) {
        logger.warn("judgeDajare AI judging failed", {
          errorType: error.name,
        });
        throw new HttpsError(
          "unavailable",
          "うまく接続できませんでした。",
        );
      }

      logger.error("judgeDajare failed", {
        errorType: error instanceof Error ? error.name : "unknown",
      });
      throw new HttpsError(
        "internal",
        "うまく処理できませんでした。",
      );
    }
  },
);
