import {JudgeResult} from "./judging";

export interface JudgeServiceDependencies {
  consumeQuota?: (uid: string) => Promise<void>;
  judge: (text: string) => Promise<JudgeResult>;
  save: (uid: string, text: string, result: JudgeResult) => Promise<void>;
  onSaveFailure: (error: unknown) => void;
  cleanup?: (uid: string) => Promise<void>;
  onCleanupFailure?: (error: unknown) => void;
}

export async function judgeAndPersist(
  uid: string,
  text: string,
  dependencies: JudgeServiceDependencies,
): Promise<JudgeResult> {
  await dependencies.consumeQuota?.(uid);
  const result = await dependencies.judge(text);

  try {
    await dependencies.save(uid, text, result);
  } catch (error) {
    dependencies.onSaveFailure(error);
    return result;
  }

  try {
    await dependencies.cleanup?.(uid);
  } catch (error) {
    dependencies.onCleanupFailure?.(error);
  }

  return result;
}
