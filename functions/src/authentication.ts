export class UnauthenticatedRequestError extends Error {
  constructor() {
    super("Authentication is required.");
    this.name = "UnauthenticatedRequestError";
  }
}

export function requireAuthenticatedUid(
  auth: {uid?: unknown} | undefined,
): string {
  if (typeof auth?.uid !== "string" || auth.uid.length === 0) {
    throw new UnauthenticatedRequestError();
  }

  return auth.uid;
}
