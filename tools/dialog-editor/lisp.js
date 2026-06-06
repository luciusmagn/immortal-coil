function symbol(value) {
  return { type: "symbol", value: value };
}

function stringAtom(value) {
  return { type: "string", value: value };
}

function isStringAtom(value) {
  return value && value.type === "string";
}

function isSymbolAtom(value) {
  return value && value.type === "symbol";
}

function symbolName(value) {
  return isSymbolAtom(value) ? value.value : "";
}

function symbolEquals(value, name) {
  return symbolName(value).toLowerCase() === name.toLowerCase();
}

function stringValue(value) {
  if (isStringAtom(value)) {
    return value.value;
  }

  if (isSymbolAtom(value)) {
    return value.value;
  }

  if (Array.isArray(value)) {
    return sexpToSource(value);
  }

  return "";
}

function lispString(value) {
  return `"${String(value || "")
    .replace(/\\/g, "\\\\")
    .replace(/"/g, "\\\"")
    .replace(/\n/g, "\\n")
    .replace(/\t/g, "\\t")}"`;
}

export function tokenise(source) {
  const tokens = [];
  let index = 0;

  while (index < source.length) {
    const char = source[index];

    if (/\s/.test(char)) {
      index += 1;
      continue;
    }

    if (char === ";") {
      while (index < source.length && source[index] !== "\n") {
        index += 1;
      }
      continue;
    }

    if (char === "(" || char === ")") {
      tokens.push({ type: char });
      index += 1;
      continue;
    }

    if (char === "#" && source[index + 1] === "'") {
      tokens.push({ type: "function-quote" });
      index += 2;
      continue;
    }

    if (char === "'") {
      tokens.push({ type: "quote" });
      index += 1;
      continue;
    }

    if (char === "\"") {
      let value = "";
      index += 1;

      while (index < source.length) {
        const next = source[index];

        if (next === "\"") {
          index += 1;
          break;
        }

        if (next === "\\") {
          const escaped = source[index + 1];

          if (escaped === "n") {
            value += "\n";
          } else if (escaped === "t") {
            value += "\t";
          } else if (escaped) {
            value += escaped;
          }

          index += 2;
          continue;
        }

        value += next;
        index += 1;
      }

      tokens.push({ type: "string", value: value });
      continue;
    }

    let value = "";
    while (
      index < source.length &&
      !/\s/.test(source[index]) &&
      source[index] !== "(" &&
      source[index] !== ")" &&
      source[index] !== "\""
    ) {
      value += source[index];
      index += 1;
    }

    tokens.push({ type: "symbol", value: value });
  }

  return tokens;
}

export const tokenize = tokenise;

export function parseLisp(source) {
  const tokens = tokenise(source);
  let index = 0;

  function parseExpression() {
    const token = tokens[index];

    if (!token) {
      throw new Error("Unexpected end of Lisp source.");
    }

    index += 1;

    if (token.type === "string") {
      return stringAtom(token.value);
    }

    if (token.type === "symbol") {
      return symbol(token.value);
    }

    if (token.type === "quote") {
      return [symbol("quote"), parseExpression()];
    }

    if (token.type === "function-quote") {
      return [symbol("function"), parseExpression()];
    }

    if (token.type === "(") {
      const values = [];

      while (tokens[index] && tokens[index].type !== ")") {
        values.push(parseExpression());
      }

      if (!tokens[index]) {
        throw new Error("Missing closing parenthesis in Lisp source.");
      }

      index += 1;
      return values;
    }

    throw new Error("Unexpected token in Lisp source.");
  }

  const forms = [];

  while (index < tokens.length) {
    forms.push(parseExpression());
  }

  return forms;
}

export function sexpToSource(value) {
  if (isStringAtom(value)) {
    return lispString(value.value);
  }

  if (isSymbolAtom(value)) {
    return value.value;
  }

  if (Array.isArray(value)) {
    if (value.length === 2 && symbolEquals(value[0], "quote")) {
      return "'" + sexpToSource(value[1]);
    }

    if (value.length === 2 && symbolEquals(value[0], "function")) {
      return "#'" + sexpToSource(value[1]);
    }

    return "(" + value.map(sexpToSource).join(" ") + ")";
  }

  return "";
}

function keyArguments(values, startIndex) {
  const keys = new Map();
  const positionals = [];
  let index = startIndex;

  while (index < values.length) {
    const value = values[index];
    const name = symbolName(value);

    if (name.startsWith(":") && index + 1 < values.length) {
      keys.set(name.toLowerCase(), values[index + 1]);
      index += 2;
    } else {
      positionals.push(value);
      index += 1;
    }
  }

  return { keys: keys, positionals: positionals };
}

function readKey(keys, name) {
  return stringValue(keys.get(name.toLowerCase()));
}

function readNumberKey(keys, name, fallback) {
  const value = readKey(keys, name);
  return value === "" ? fallback : value;
}

function readBooleanKey(keys, name) {
  const value = keys.get(name.toLowerCase());

  if (!value) {
    return false;
  }

  if (isSymbolAtom(value)) {
    return value.value.toLowerCase() !== "nil";
  }

  return stringValue(value) !== "";
}

function readKeywordKey(keys, name, fallback) {
  const value = readKey(keys, name);

  if (!value) {
    return fallback;
  }

  return value.replace(/^:/, "");
}

function keywordSource(value) {
  const text = String(value || "wire-flight").trim().replace(/^:/, "");
  return ":" + (text || "wire-flight");
}

function parseDialogOption(form) {
  const args = keyArguments(form, 3);
  const whenValue = args.keys.get(":when");
  const unlessValue = args.keys.get(":unless");
  let condition = "";

  if (whenValue) {
    condition = sexpToSource(whenValue);
  } else if (unlessValue) {
    condition = "(not " + sexpToSource(unlessValue) + ")";
  }

  return {
    label: stringValue(form[1]),
    target: stringValue(form[2]),
    condition: condition
  };
}

function parseBranchEntry(form) {
  if (!Array.isArray(form) || !form[0]) {
    return null;
  }

  if (symbolEquals(form[0], "dialog-default")) {
    return {
      condition: "t",
      target: stringValue(form[1])
    };
  }

  if (symbolEquals(form[0], "dialog-case")) {
    return {
      condition: sexpToSource(form[1]),
      target: stringValue(form[2])
    };
  }

  return null;
}

export function parseDialog(source) {
  const forms = parseLisp(source);
  const nodes = [];
  let startId = "";

  forms.forEach((form) => {
    if (!Array.isArray(form) || !form.length) {
      return;
    }

    const head = symbolName(form[0]).toLowerCase();

    if (head === "dialog-start") {
      startId = stringValue(form[1]);
      return;
    }

    if (head === "dialog-text") {
      const args = keyArguments(form, 3);

      nodes.push({
        id: stringValue(form[1]),
        kind: "text",
        text: stringValue(form[2]),
        next: readKey(args.keys, ":next"),
        layout: "horizontal",
        target: "",
        responseKey: "",
        min: "",
        max: "",
        maxLength: "",
        allowEmpty: false,
        minigame: "wire-flight",
        successTarget: "",
        failureTarget: "",
        choices: [],
        branches: [],
        x: 0,
        y: 0
      });
      return;
    }

    if (head === "dialog-choice" || head === "dialog-pick" || head === "dialog-list") {
      const layout = head === "dialog-pick"
        ? "vertical"
        : head === "dialog-list"
          ? "list"
          : "horizontal";
      const choices = form.slice(3)
        .filter((item) => Array.isArray(item) && symbolEquals(item[0], "dialog-option"))
        .map(parseDialogOption);

      nodes.push({
        id: stringValue(form[1]),
        kind: "choice",
        text: stringValue(form[2]),
        next: "",
        layout: layout,
        target: "",
        responseKey: "",
        min: "",
        max: "",
        maxLength: "",
        allowEmpty: false,
        minigame: "wire-flight",
        successTarget: "",
        failureTarget: "",
        choices: choices,
        branches: [],
        x: 0,
        y: 0
      });
      return;
    }

    if (head === "dialog-number") {
      const args = keyArguments(form, 3);

      nodes.push({
        id: stringValue(form[1]),
        kind: "number",
        text: stringValue(form[2]),
        next: "",
        layout: "horizontal",
        target: readKey(args.keys, ":target"),
        responseKey: readKey(args.keys, ":response-key"),
        min: readNumberKey(args.keys, ":min", ""),
        max: readNumberKey(args.keys, ":max", ""),
        maxLength: "",
        allowEmpty: false,
        minigame: "wire-flight",
        successTarget: "",
        failureTarget: "",
        choices: [],
        branches: [],
        x: 0,
        y: 0
      });
      return;
    }

    if (head === "dialog-string") {
      const args = keyArguments(form, 3);

      nodes.push({
        id: stringValue(form[1]),
        kind: "string",
        text: stringValue(form[2]),
        next: "",
        layout: "horizontal",
        target: readKey(args.keys, ":target"),
        responseKey: readKey(args.keys, ":response-key"),
        min: "",
        max: "",
        maxLength: readNumberKey(args.keys, ":max-length", ""),
        allowEmpty: readBooleanKey(args.keys, ":allow-empty"),
        minigame: "wire-flight",
        successTarget: "",
        failureTarget: "",
        choices: [],
        branches: [],
        x: 0,
        y: 0
      });
      return;
    }

    if (head === "dialog-minigame") {
      const args = keyArguments(form, 3);

      nodes.push({
        id: stringValue(form[1]),
        kind: "minigame",
        text: stringValue(form[2]),
        next: "",
        layout: "horizontal",
        target: "",
        responseKey: "",
        min: "",
        max: "",
        maxLength: "",
        allowEmpty: false,
        minigame: readKeywordKey(args.keys, ":game", "wire-flight"),
        successTarget: readKey(args.keys, ":success"),
        failureTarget: readKey(args.keys, ":failure"),
        choices: [],
        branches: [],
        x: 0,
        y: 0
      });
      return;
    }

    if (head === "dialog-branch") {
      const branches = form.slice(2)
        .map(parseBranchEntry)
        .filter(Boolean);

      nodes.push({
        id: stringValue(form[1]),
        kind: "branch",
        text: "",
        next: "",
        layout: "horizontal",
        target: "",
        responseKey: "",
        min: "",
        max: "",
        maxLength: "",
        allowEmpty: false,
        minigame: "wire-flight",
        successTarget: "",
        failureTarget: "",
        choices: [],
        branches: branches,
        x: 0,
        y: 0
      });
    }
  });

  if (!startId && nodes.length) {
    startId = nodes[0].id;
  }

  return {
    startId: startId,
    selectedId: startId,
    nodes: nodes
  };
}

function dialogCommandForLayout(layout) {
  if (layout === "vertical") {
    return "dialog-pick";
  }

  if (layout === "list") {
    return "dialog-list";
  }

  return "dialog-choice";
}

function commandIndent(command) {
  return " ".repeat(command.length + 2);
}

function optionSource(choice, indent) {
  let line = indent + "(dialog-option " + lispString(choice.label) + " " + lispString(choice.target);

  if (choice.condition && choice.condition.trim()) {
    line += " :when " + choice.condition.trim();
  }

  return line + ")";
}

function branchSource(branch, indent) {
  const condition = (branch.condition || "t").trim();

  if (!condition || condition.toLowerCase() === "t") {
    return indent + "(dialog-default " + lispString(branch.target) + ")";
  }

  return indent + "(dialog-case " + condition + " " + lispString(branch.target) + ")";
}

function nodeSource(node) {
  if (node.kind === "choice") {
    const command = dialogCommandForLayout(node.layout);
    const indent = commandIndent(command);
    const lines = [
      "(" + command + " " + lispString(node.id),
      indent + lispString(node.text || "")
    ];

    node.choices.forEach((choice) => {
      lines.push(optionSource(choice, indent));
    });

    return lines.join("\n") + ")";
  }

  if (node.kind === "number") {
    const command = "dialog-number";
    const indent = commandIndent(command);
    const lines = [
      "(" + command + " " + lispString(node.id),
      indent + lispString(node.text || "")
    ];

    if (node.responseKey) {
      lines.push(indent + ":response-key " + lispString(node.responseKey));
    }

    if (node.min !== "") {
      lines.push(indent + ":min " + node.min);
    }

    if (node.max !== "") {
      lines.push(indent + ":max " + node.max);
    }

    if (node.target) {
      lines.push(indent + ":target " + lispString(node.target));
    }

    return lines.join("\n") + ")";
  }

  if (node.kind === "string") {
    const command = "dialog-string";
    const indent = commandIndent(command);
    const lines = [
      "(" + command + " " + lispString(node.id),
      indent + lispString(node.text || "")
    ];

    if (node.responseKey) {
      lines.push(indent + ":response-key " + lispString(node.responseKey));
    }

    if (node.maxLength !== "" && node.maxLength != null) {
      lines.push(indent + ":max-length " + node.maxLength);
    }

    if (node.allowEmpty) {
      lines.push(indent + ":allow-empty t");
    }

    if (node.target) {
      lines.push(indent + ":target " + lispString(node.target));
    }

    return lines.join("\n") + ")";
  }

  if (node.kind === "branch") {
    const command = "dialog-branch";
    const indent = commandIndent(command);
    const lines = [
      "(" + command + " " + lispString(node.id)
    ];

    node.branches.forEach((branch) => {
      lines.push(branchSource(branch, indent));
    });

    return lines.join("\n") + ")";
  }

  if (node.kind === "minigame") {
    const command = "dialog-minigame";
    const indent = commandIndent(command);
    const lines = [
      "(" + command + " " + lispString(node.id),
      indent + lispString(node.text || ""),
      indent + ":game " + keywordSource(node.minigame)
    ];

    if (node.successTarget) {
      lines.push(indent + ":success " + lispString(node.successTarget));
    }

    if (node.failureTarget) {
      lines.push(indent + ":failure " + lispString(node.failureTarget));
    }

    return lines.join("\n") + ")";
  }

  const command = "dialog-text";
  const indent = commandIndent(command);
  const lines = [
    "(" + command + " " + lispString(node.id),
    indent + lispString(node.text || "")
  ];

  if (node.next) {
    lines.push(indent + ":next " + lispString(node.next));
  }

  return lines.join("\n") + ")";
}

export function exportGraph(graph) {
  const lines = [];

  if (graph.startId) {
    lines.push("(dialog-start " + lispString(graph.startId) + ")");
    lines.push("");
  }

  graph.nodes.forEach((node, index) => {
    if (index > 0) {
      lines.push("");
    }
    lines.push(nodeSource(node));
  });

  return lines.join("\n").trimEnd() + "\n";
}
