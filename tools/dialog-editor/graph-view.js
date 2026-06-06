import { exportGraph } from "./lisp.js";
import {
  NODE_HEIGHT,
  NODE_WIDTH,
  allEdges,
  nodeById,
  outgoingEdges,
  selectedNode,
  state
} from "./graph-model.js";

let elements = {};
let handlers = {};

export function configureView(nextElements, nextHandlers) {
  elements = nextElements;
  handlers = nextHandlers;
}

export function truncate(value, length) {
  const text = String(value || "");
  return text.length > length ? text.slice(0, Math.max(0, length - 3)) + "..." : text;
}

function createSvg(name) {
  return document.createElementNS("http://www.w3.org/2000/svg", name);
}

export function setWorldTransform() {
  elements.graphWorld.style.transform = "translate(" + state.pan.x + "px, " + state.pan.y + "px) scale(" + state.zoom + ")";
}

function renderMeta() {
  const count = state.nodes.length;
  elements.graphCount.textContent = count + (count === 1 ? " node" : " nodes");
  elements.startNodeLabel.textContent = state.startId ? "start: " + state.startId : "no start node";
}

function renderNodeIds() {
  elements.nodeIds.innerHTML = "";

  state.nodes.forEach((node) => {
    const option = document.createElement("option");
    option.value = node.id;
    elements.nodeIds.appendChild(option);
  });
}

function renderEdges() {
  elements.edgeLayer.innerHTML = "";

  allEdges().forEach((edge, index) => {
    const from = nodeById(edge.from);
    const to = nodeById(edge.to);

    if (!from) {
      return;
    }

    const startX = from.x + NODE_WIDTH;
    const startY = from.y + NODE_HEIGHT / 2;
    const endX = to ? to.x : from.x + NODE_WIDTH + 120;
    const endY = to ? to.y + NODE_HEIGHT / 2 : from.y + 32 + index * 14;
    const bend = Math.max(88, Math.abs(endX - startX) * 0.42);
    const path = createSvg("path");
    const classes = ["edge", edge.kind];

    if (edge.conditional) {
      classes.push("conditional");
    }

    if (!to) {
      classes.push("missing");
    }

    path.setAttribute("class", classes.join(" "));
    path.setAttribute(
      "d",
      "M " + startX + " " + startY +
      " C " + (startX + bend) + " " + startY +
      ", " + (endX - bend) + " " + endY +
      ", " + endX + " " + endY
    );
    elements.edgeLayer.appendChild(path);

    const label = createSvg("text");
    label.setAttribute("class", "edge-label");
    label.setAttribute("x", String((startX + endX) / 2));
    label.setAttribute("y", String((startY + endY) / 2 - 8));
    label.textContent = truncate(edge.label, 18);
    elements.edgeLayer.appendChild(label);
  });
}

function appendNodeLinks(card, node) {
  const links = document.createElement("div");
  links.className = "node-links";

  outgoingEdges(node).slice(0, 4).forEach((edge) => {
    const link = document.createElement("span");
    link.textContent = truncate(edge.to, 20);
    links.appendChild(link);
  });

  if (links.childNodes.length) {
    card.appendChild(links);
  }
}

function renderNodes() {
  elements.nodeLayer.innerHTML = "";

  state.nodes.forEach((node) => {
    const card = document.createElement("button");
    card.type = "button";
    card.className = "node-card" +
      (node.id === state.selectedId ? " selected" : "") +
      (node.id === state.startId ? " start" : "");
    card.style.left = node.x + "px";
    card.style.top = node.y + "px";

    const top = document.createElement("div");
    top.className = "node-top";

    const id = document.createElement("div");
    id.className = "node-id";
    id.textContent = node.id;

    const kind = document.createElement("div");
    kind.className = "node-kind";
    kind.textContent = node.kind;

    top.appendChild(id);
    top.appendChild(kind);
    card.appendChild(top);

    const text = document.createElement("div");
    text.className = "node-text";
    text.textContent = node.kind === "branch"
      ? node.branches.length + " branch" + (node.branches.length === 1 ? "" : "es")
      : node.text || "(empty)";
    card.appendChild(text);

    appendNodeLinks(card, node);

    card.addEventListener("pointerdown", (event) => {
      if (handlers.onNodePointerDown) {
        handlers.onNodePointerDown(event, node);
      }
    });

    elements.nodeLayer.appendChild(card);
  });
}

function setVisibility(element, visible) {
  element.hidden = !visible;
}

function setFormEnabled(enabled) {
  elements.nodeForm.querySelectorAll("input, select, textarea, button").forEach((control) => {
    control.disabled = !enabled;
  });
}

function renderChoiceRows(node) {
  elements.choicesList.innerHTML = "";

  node.choices.forEach((choice, index) => {
    const row = document.createElement("div");
    row.className = "repeater-row";

    const labelField = document.createElement("label");
    const labelCaption = document.createElement("span");
    const labelInput = document.createElement("input");
    labelCaption.textContent = "Label";
    labelInput.value = choice.label || "";
    labelInput.autocomplete = "off";
    labelInput.addEventListener("input", () => {
      choice.label = labelInput.value;
      renderGraphAndSource();
    });
    labelField.appendChild(labelCaption);
    labelField.appendChild(labelInput);

    const targetField = document.createElement("label");
    const targetCaption = document.createElement("span");
    const targetInput = document.createElement("input");
    targetCaption.textContent = "Target";
    targetInput.value = choice.target || "";
    targetInput.setAttribute("list", "nodeIds");
    targetInput.autocomplete = "off";
    targetInput.addEventListener("input", () => {
      choice.target = targetInput.value;
      renderGraphAndSource();
    });
    targetField.appendChild(targetCaption);
    targetField.appendChild(targetInput);

    const deleteButton = document.createElement("button");
    deleteButton.type = "button";
    deleteButton.textContent = "X";
    deleteButton.setAttribute("aria-label", "Delete choice");
    deleteButton.addEventListener("click", () => {
      node.choices.splice(index, 1);
      render();
    });

    const conditionField = document.createElement("label");
    conditionField.className = "condition-field";
    const conditionCaption = document.createElement("span");
    const conditionInput = document.createElement("input");
    conditionCaption.textContent = "Condition";
    conditionInput.value = choice.condition || "";
    conditionInput.placeholder = "#'(lambda () ...)";
    conditionInput.autocomplete = "off";
    conditionInput.addEventListener("input", () => {
      choice.condition = conditionInput.value;
      renderGraphAndSource();
    });
    conditionField.appendChild(conditionCaption);
    conditionField.appendChild(conditionInput);

    row.appendChild(labelField);
    row.appendChild(targetField);
    row.appendChild(deleteButton);
    row.appendChild(conditionField);
    elements.choicesList.appendChild(row);
  });
}

function renderBranchRows(node) {
  elements.branchesList.innerHTML = "";

  node.branches.forEach((branch, index) => {
    const row = document.createElement("div");
    row.className = "repeater-row";

    const conditionField = document.createElement("label");
    const conditionCaption = document.createElement("span");
    const conditionInput = document.createElement("input");
    conditionCaption.textContent = "Condition";
    conditionInput.value = branch.condition || "";
    conditionInput.placeholder = "t";
    conditionInput.autocomplete = "off";
    conditionInput.addEventListener("input", () => {
      branch.condition = conditionInput.value;
      renderGraphAndSource();
    });
    conditionField.appendChild(conditionCaption);
    conditionField.appendChild(conditionInput);

    const targetField = document.createElement("label");
    const targetCaption = document.createElement("span");
    const targetInput = document.createElement("input");
    targetCaption.textContent = "Target";
    targetInput.value = branch.target || "";
    targetInput.setAttribute("list", "nodeIds");
    targetInput.autocomplete = "off";
    targetInput.addEventListener("input", () => {
      branch.target = targetInput.value;
      renderGraphAndSource();
    });
    targetField.appendChild(targetCaption);
    targetField.appendChild(targetInput);

    const deleteButton = document.createElement("button");
    deleteButton.type = "button";
    deleteButton.textContent = "X";
    deleteButton.setAttribute("aria-label", "Delete branch");
    deleteButton.addEventListener("click", () => {
      node.branches.splice(index, 1);
      render();
    });

    row.appendChild(conditionField);
    row.appendChild(targetField);
    row.appendChild(deleteButton);
    elements.branchesList.appendChild(row);
  });
}

function renderInspector() {
  const node = selectedNode();

  if (!node) {
    elements.selectedTitle.textContent = "None";
    setFormEnabled(false);
    elements.nodeIdInput.value = "";
    elements.nodeTextInput.value = "";
    elements.choicesList.innerHTML = "";
    elements.branchesList.innerHTML = "";
    return;
  }

  state.selectedId = node.id;
  setFormEnabled(true);
  elements.selectedTitle.textContent = truncate(node.id, 28);
  elements.nodeIdInput.value = node.id;
  elements.nodeKindSelect.value = node.kind;
  elements.nodeLayoutSelect.value = node.layout || "horizontal";
  elements.nodeTextInput.value = node.text || "";
  elements.nodeNextInput.value = node.next || "";
  elements.nodeTargetInput.value = node.target || "";
  elements.nodeResponseKeyInput.value = node.responseKey || "";
  elements.nodeMinInput.value = node.min || "";
  elements.nodeMaxInput.value = node.kind === "string"
    ? node.maxLength || ""
    : node.max || "";
  elements.nodeAllowEmptyInput.checked = Boolean(node.allowEmpty);

  setVisibility(elements.layoutField, node.kind === "choice");
  setVisibility(elements.textField, node.kind !== "branch");
  setVisibility(elements.nextField, node.kind === "text");
  setVisibility(elements.inputFields, node.kind === "number" || node.kind === "string");
  setVisibility(elements.nodeMinField, node.kind === "number");
  setVisibility(elements.allowEmptyField, node.kind === "string");
  setVisibility(elements.choicesField, node.kind === "choice");
  setVisibility(elements.branchesField, node.kind === "branch");

  elements.nodeMaxLabel.textContent = node.kind === "string" ? "Max Length" : "Max";
  elements.nodeMaxInput.name = node.kind === "string" ? "maxLength" : "max";

  renderChoiceRows(node);
  renderBranchRows(node);
}

export function renderGraphAndSource() {
  renderMeta();
  renderNodeIds();
  setWorldTransform();
  renderEdges();
  renderNodes();
  elements.sourceOutput.value = exportGraph(state);
}

export function render() {
  renderGraphAndSource();
  renderInspector();
}
