function lispString(value) {
  return `"${String(value || "")
    .replace(/\\/g, "\\\\")
    .replace(/"/g, "\\\"")
    .replace(/\n/g, "\\n")
    .replace(/\t/g, "\\t")}"`;
}

function unescapeLispString(value) {
  return String(value || "")
    .replace(/\\n/g, "\n")
    .replace(/\\t/g, "\t")
    .replace(/\\"/g, "\"")
    .replace(/\\\\/g, "\\");
}

function quoteRuntimeExpression(expression) {
  return "'(" + expression.replace(/^\(|\)$/g, "") + ")";
}

function unwrapRuntimeCondition(source) {
  let text = String(source || "").trim();
  let match = text.match(/^#?'\(lambda\s+\(\)\s+(.+)\)$/i);

  if (match) {
    return match[1].trim();
  }

  match = text.match(/^\(function\s+\(lambda\s+\(\)\s+(.+)\)\)$/i);

  if (match) {
    return match[1].trim();
  }

  if (text.startsWith("'")) {
    text = text.slice(1).trim();
  }

  return text;
}

function parseSimpleCondition(source) {
  const text = unwrapRuntimeCondition(source);
  let match = text.match(/^\(dialog-value\s+"((?:\\.|[^"])*)"(?:\s+[^)]*)?\)$/i);

  if (match) {
    return {
      preset: "store-truthy",
      key: unescapeLispString(match[1]),
      value: "",
      custom: source
    };
  }

  match = text.match(/^\(not\s+\(dialog-value\s+"((?:\\.|[^"])*)"(?:\s+[^)]*)?\)\)$/i);

  if (match) {
    return {
      preset: "store-missing",
      key: unescapeLispString(match[1]),
      value: "",
      custom: source
    };
  }

  match = text.match(/^\(equal\s+\(dialog-value\s+"((?:\\.|[^"])*)"(?:\s+[^)]*)?\)\s+"((?:\\.|[^"])*)"\)$/i);

  if (match) {
    return {
      preset: "string-equals",
      key: unescapeLispString(match[1]),
      value: unescapeLispString(match[2]),
      custom: source
    };
  }

  match = text.match(/^\((=|>=|<=)\s+\(dialog-value\s+"((?:\\.|[^"])*)"(?:\s+[^)]*)?\)\s+(-?\d+(?:\.\d+)?)\)$/i);

  if (match) {
    return {
      preset: {
        "=": "number-equals",
        ">=": "number-gte",
        "<=": "number-lte"
      }[match[1]],
      key: unescapeLispString(match[2]),
      value: match[3],
      custom: source
    };
  }

  return null;
}

export function conditionStateFromSource(source) {
  const text = String(source || "").trim();

  if (!text || text.toLowerCase() === "t") {
    return {
      preset: "always",
      key: "",
      value: "",
      custom: ""
    };
  }

  return parseSimpleCondition(text) || {
    preset: "custom",
    key: "",
    value: "",
    custom: text
  };
}

function numberValue(value) {
  const text = String(value || "").trim();
  return /^-?\d+(?:\.\d+)?$/.test(text) ? text : "0";
}

export function sourceFromConditionState(state) {
  const key = String(state.key || "").trim();
  const value = String(state.value || "").trim();

  if (state.preset === "always") {
    return "";
  }

  if (state.preset === "custom") {
    return String(state.custom || "").trim();
  }

  if (!key) {
    return "";
  }

  if (state.preset === "store-truthy") {
    return quoteRuntimeExpression(`(dialog-value ${lispString(key)})`);
  }

  if (state.preset === "store-missing") {
    return quoteRuntimeExpression(`(not (dialog-value ${lispString(key)}))`);
  }

  if (state.preset === "string-equals") {
    return quoteRuntimeExpression(`(equal (dialog-value ${lispString(key)}) ${lispString(value)})`);
  }

  if (state.preset === "number-equals") {
    return quoteRuntimeExpression(`(= (dialog-value ${lispString(key)} 0) ${numberValue(value)})`);
  }

  if (state.preset === "number-gte") {
    return quoteRuntimeExpression(`(>= (dialog-value ${lispString(key)} 0) ${numberValue(value)})`);
  }

  if (state.preset === "number-lte") {
    return quoteRuntimeExpression(`(<= (dialog-value ${lispString(key)} 0) ${numberValue(value)})`);
  }

  return "";
}

export function conditionNeedsKey(preset) {
  return preset !== "always" && preset !== "custom";
}

export function conditionNeedsValue(preset) {
  return [
    "string-equals",
    "number-equals",
    "number-gte",
    "number-lte"
  ].includes(preset);
}
