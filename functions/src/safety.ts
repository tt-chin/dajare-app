const unsafePatterns = [
  /(?:性交|セックス|裸|ポルノ|アダルト)/iu,
  /(?:自殺|自傷|死にたい|消えたい)/iu,
  /(?:殺す|殺し方|爆弾|銃|ナイフで刺)/iu,
  /(?:差別|ヘイト|いじめ方)/iu,
  /(?:住所|電話番号|メールアドレス|学校名|本名).{0,12}(?:教えて|送って|書いて)/iu,
];

export function containsUnsafeContent(text: string): boolean {
  const normalized = text.normalize("NFKC").toLowerCase();
  return unsafePatterns.some((pattern) => pattern.test(normalized));
}
