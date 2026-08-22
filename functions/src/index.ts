import {logger} from "firebase-functions";
import {defineSecret} from "firebase-functions/params";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {
  GeminiUnavailableError,
  InvalidGeminiResponseError,
  runGeminiConnectionTest,
} from "./gemini";
import {
  RequestValidationError,
  validateJudgeRequest,
} from "./validation";

interface JudgeDajareResponse {
  message: string;
}

const geminiApiKey = defineSecret("GEMINI_API_KEY");

export const judgeDajare = onCall<unknown, Promise<JudgeDajareResponse>>(
  {region: "asia-northeast1", secrets: [geminiApiKey]},
  async (request) => {
    try {
      validateJudgeRequest(request.data);
      const result = await runGeminiConnectionTest(geminiApiKey.value());
      return {message: result.message};
    } catch (error) {
      if (error instanceof RequestValidationError) {
        throw new HttpsError(
          "invalid-argument",
          "入力内容を確認してください。",
        );
      }

      if (
        error instanceof GeminiUnavailableError ||
        error instanceof InvalidGeminiResponseError
      ) {
        logger.warn("judgeDajare Gemini connection test failed", {
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
