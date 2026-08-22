import assert from "node:assert/strict";
import test from "node:test";

import {
  GeminiUnavailableError,
  InvalidGeminiResponseError,
  extractInteractionOutputText,
  geminiModel,
  parseGeminiConnectionTestResponse,
  runGeminiConnectionTest,
} from "./gemini";

test("calls the controlled Gemini structured-output request", async () => {
  let requestBody: Record<string, unknown> | undefined;
  const fakeFetch: typeof fetch = async (_input, init) => {
    requestBody = JSON.parse(String(init?.body)) as Record<string, unknown>;
    return new Response(JSON.stringify({
      status: "completed",
      steps: [{
        type: "model_output",
        content: [{
          type: "text",
          text: JSON.stringify({status: "ok", message: "Hello Dajare!"}),
        }],
      }],
    }), {status: 200});
  };

  const result = await runGeminiConnectionTest("test-key", fakeFetch);

  assert.deepEqual(result, {status: "ok", message: "Hello Dajare!"});
  assert.equal(requestBody?.model, geminiModel);
  assert.equal(
    (requestBody?.response_format as Record<string, unknown>).mime_type,
    "application/json",
  );
});

test("extracts text from the REST interaction response", () => {
  assert.equal(extractInteractionOutputText({
    status: "completed",
    steps: [
      {type: "user_input", content: [{type: "text", text: "input"}]},
      {
        type: "model_output",
        content: [
          {type: "text", text: "{\"status\":\"ok\","},
          {type: "text", text: "\"message\":\"Hello Dajare!\"}"},
        ],
      },
    ],
  }), "{\"status\":\"ok\",\"message\":\"Hello Dajare!\"}");
});

test("rejects incomplete REST interaction responses", () => {
  assert.equal(extractInteractionOutputText({
    status: "in_progress",
    steps: [],
  }), undefined);
});

test("normalizes Gemini request failures", async () => {
  const fakeFetch: typeof fetch = async () => new Response("provider error", {
    status: 503,
  });

  await assert.rejects(
    runGeminiConnectionTest("test-key", fakeFetch),
    GeminiUnavailableError,
  );
});

test("accepts the controlled structured response", () => {
  assert.deepEqual(
    parseGeminiConnectionTestResponse(
      JSON.stringify({status: "ok", message: "Hello Dajare!"}),
    ),
    {status: "ok", message: "Hello Dajare!"},
  );
});

test("rejects missing and malformed JSON responses", () => {
  assert.throws(
    () => parseGeminiConnectionTestResponse(undefined),
    InvalidGeminiResponseError,
  );
  assert.throws(
    () => parseGeminiConnectionTestResponse("not-json"),
    InvalidGeminiResponseError,
  );
});

test("rejects unexpected structured values", () => {
  assert.throws(
    () => parseGeminiConnectionTestResponse(
      JSON.stringify({status: "failed", message: "Hello Dajare!"}),
    ),
    InvalidGeminiResponseError,
  );
  assert.throws(
    () => parseGeminiConnectionTestResponse(
      JSON.stringify({status: "ok", message: "different"}),
    ),
    InvalidGeminiResponseError,
  );
});

test("rejects extra response fields", () => {
  assert.throws(
    () => parseGeminiConnectionTestResponse(JSON.stringify({
      status: "ok",
      message: "Hello Dajare!",
      debug: "not allowed",
    })),
    InvalidGeminiResponseError,
  );
});
