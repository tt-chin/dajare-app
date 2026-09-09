export const maxDajareLength = 80;

export class RequestValidationError extends Error {
  constructor() {
    super("Invalid judgeDajare request");
    this.name = "RequestValidationError";
  }
}

export class UnsafeInputError extends Error {
  constructor() {
    super("Unsafe judgeDajare input");
    this.name = "UnsafeInputError";
  }
}

export function validateJudgeRequest(data: unknown): string {
  if (data === null || typeof data !== "object" || Array.isArray(data)) {
    throw new RequestValidationError();
  }

  const payload = data as Record<string, unknown>;
  if (Object.keys(payload).some((key) => key !== "text")) {
    throw new RequestValidationError();
  }
  const text = payload.text;
  if (typeof text !== "string") {
    throw new RequestValidationError();
  }

  const normalizedText = text.trim();
  if (
    normalizedText.length === 0 ||
    normalizedText.length > maxDajareLength
  ) {
    throw new RequestValidationError();
  }

  return normalizedText;
}
