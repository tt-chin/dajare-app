import {logger} from "firebase-functions";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {
  RequestValidationError,
  validateJudgeRequest,
} from "./validation";

interface JudgeDajareResponse {
  message: string;
}

export const judgeDajare = onCall<unknown, Promise<JudgeDajareResponse>>(
  {region: "asia-northeast1"},
  async (request) => {
    try {
      validateJudgeRequest(request.data);
      return {message: "Hello Dajare!"};
    } catch (error) {
      if (error instanceof RequestValidationError) {
        throw new HttpsError(
          "invalid-argument",
          "入力内容を確認してください。",
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
