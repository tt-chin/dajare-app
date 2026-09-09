const unsafePatterns = [
  /(?:性交|セックス|裸|ポルノ|アダルト|性的)/iu,
  /(?:自殺|自傷|死にたい|消えたい)/iu,
  /(?:殺す|殺し方|血まみれ|首を切|爆弾|銃|ナイフで刺|毒の作り方)/iu,
  /(?:差別|ヘイト|いじめ方|仲間外れにする方法|悪口を広め)/iu,
  /(?:怖がらせる方法|子どもを脅す|残酷な話を詳しく)/iu,
  /(?:住所|電話番号|メールアドレス|学校名|本名).{0,12}(?:教えて|送って|書いて)/iu,
];

export function containsUnsafeContent(text: string): boolean {
  const normalized = text.normalize("NFKC").toLowerCase();
  return unsafePatterns.some((pattern) => pattern.test(normalized));
}
