/// Settings module — the allowed hanzi script / font values.
///
/// Ported from `yi-chinese-manage/lib/han/hanConvert.ts` (`HANZI_FONTS`,
/// `HANZI_SCRIPTS`). The runtime CJK-glyph swap these drive is deferred (Slice
/// R-UI): this slice persists the preference only, it does not re-render text.
library;

const List<String> hanziFonts = [
  'SimSun',
  'Segoe UI',
  'Roboto',
  'Helvetica Neue',
  'Noto Sans',
];
const String defaultHanziFont = 'Roboto';

const List<String> hanziScripts = ['simplified', 'traditional'];
const String defaultHanziScript = 'simplified';

/// Clamp a stored value to an allowed option, falling back to the default.
String normalizeHanziFont(String? font) =>
    font != null && hanziFonts.contains(font) ? font : defaultHanziFont;

String normalizeHanziScript(String? script) =>
    script != null && hanziScripts.contains(script)
    ? script
    : defaultHanziScript;
