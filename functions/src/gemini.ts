export const geminiModel = "gemini-3.7-flash";

const interactionsEndpoint =
  "https://generativelanguage.googleapis.com/v1beta/interactions";

const expectedStatus = "ok";
const expectedMessage = "Hello Dajare!";

const connectionTestPrompt = `
This is a controlled backend connection test.
Do not judge, rewrite, or otherwise process any user-provided content.
Return status "ok" and message "Hello Dajare!" using the required JSON schema.
`.trim();

const connectionTestSchema = {
  type: "object",
  properties: {
    status: {type: "string", enum: [expectedStatus]},
    message: {type: "string", enum: [expectedMessage]},
  },
  required: ["status", "message"],
  additionalProperties: false,
};

export interface GeminiConnectionTestResult {
  status: "ok";
  message: "Hello Dajare!";
}

export class GeminiUnavailableError extends Error {
  constructor() {
    super("Gemini request failed");
    this.name = "GeminiUnavailableError";
  }
}

export class InvalidGeminiResponseError extends Error {
  constructor() {
    super("Gemini returned an invalid connection-test response");
    this.name = "InvalidGeminiResponseError";
  }
}

export function parseGeminiConnectionTestResponse(
  responseText: string | undefined,
): GeminiConnectionTestResult {
  if (responseText === undefined) {
    throw new InvalidGeminiResponseError();
  }

  let value: unknown;
  try {
    value = JSON.parse(responseText);
  } catch {
    throw new InvalidGeminiResponseError();
  }

  if (
    typeof value !== "object" ||
    value === null ||
    Array.isArray(value)
  ) {
    throw new InvalidGeminiResponseError();
  }

  const record = value as Record<string, unknown>;
  if (
    Object.keys(record).length !== 2 ||
    record.status !== expectedStatus ||
    record.message !== expectedMessage
  ) {
    throw new InvalidGeminiResponseError();
  }

  return {status: expectedStatus, message: expectedMessage};
}

export function extractInteractionOutputText(
  interaction: unknown,
): string | undefined {
  if (typeof interaction !== "object" || interaction === null) {
    return undefined;
  }

  const record = interaction as Record<string, unknown>;
  if (record.status !== "completed" || !Array.isArray(record.steps)) {
    return undefined;
  }

  for (let index = record.steps.length - 1; index >= 0; index -= 1) {
    const step = record.steps[index];
    if (typeof step !== "object" || step === null) {
      continue;
    }

    const stepRecord = step as Record<string, unknown>;
    if (stepRecord.type !== "model_output" || !Array.isArray(stepRecord.content)) {
      continue;
    }

    const textParts = stepRecord.content.flatMap((item) => {
      if (typeof item !== "object" || item === null) {
        return [];
      }
      const content = item as Record<string, unknown>;
      return content.type === "text" && typeof content.text === "string" ?
        [content.text] : [];
    });
    return textParts.length > 0 ? textParts.join("") : undefined;
  }

  return undefined;
}

export async function runGeminiConnectionTest(
  apiKey: string,
  request: typeof fetch = fetch,
): Promise<GeminiConnectionTestResult> {
  if (apiKey.trim().length === 0) {
    throw new GeminiUnavailableError();
  }

  let responseText: string | undefined;

  try {
    const response = await request(interactionsEndpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": apiKey,
      },
      body: JSON.stringify({
        model: geminiModel,
        input: connectionTestPrompt,
        response_format: {
          type: "text",
          mime_type: "application/json",
          schema: connectionTestSchema,
        },
      }),
    });

    if (!response.ok) {
      throw new GeminiUnavailableError();
    }

    const interaction: unknown = await response.json();
    responseText = extractInteractionOutputText(interaction);
  } catch {
    throw new GeminiUnavailableError();
  }

  return parseGeminiConnectionTestResponse(responseText);
}
