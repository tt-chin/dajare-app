import {JudgeResult} from "./judging";

export interface JudgeServiceDependencies {
  judge: (text: string) => Promise<JudgeResult>;
  save: (uid: string, text: string, result: JudgeResult) => Promise<void>;
  onSaveFailure: (error: unknown) => void;
}

export async function judgeAndPersist(
  uid: string,
  text: string,
  dependencies: JudgeServiceDependencies,
): Promise<JudgeResult> {
  const result = await dependencies.judge(text);

  try {
    await dependencies.save(uid, text, result);
  } catch (error) {
    dependencies.onSaveFailure(error);
  }

  return result;
}
