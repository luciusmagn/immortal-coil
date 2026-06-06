export const WORLD_WIDTH = 4200;
export const WORLD_HEIGHT = 3000;
export const NODE_WIDTH = 260;
export const NODE_HEIGHT = 132;

const GRID_X = 430;
const GRID_Y = 190;

export const state = {
  startId: "",
  selectedId: "",
  nodes: [],
  pan: { x: 64, y: 52 },
  zoom: 0.9,
  draggingNode: null,
  panning: null
};

export function nodeById(id) {
  return state.nodes.find((node) => node.id === id) || null;
}

export function selectedNode() {
  return nodeById(state.selectedId) || nodeById(state.startId) || state.nodes[0] || null;
}

export function uniqueNodeId(prefix) {
  let index = 1;
  let id = prefix;

  while (nodeById(id)) {
    index += 1;
    id = prefix + "-" + index;
  }

  return id;
}

export function defaultNode(id, x, y) {
  return {
    id: id,
    kind: "text",
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
    branches: [],
    x: x || 100,
    y: y || 100
  };
}

export function outgoingEdges(node) {
  if (node.kind === "text") {
    return node.next ? [{
      from: node.id,
      to: node.next,
      label: "next",
      kind: "text",
      conditional: false
    }] : [];
  }

  if (node.kind === "number" || node.kind === "string") {
    return node.target ? [{
      from: node.id,
      to: node.target,
      label: node.kind,
      kind: node.kind,
      conditional: false
    }] : [];
  }

  if (node.kind === "minigame") {
    const edges = [];

    if (node.successTarget) {
      edges.push({
        from: node.id,
        to: node.successTarget,
        label: "success",
        kind: "minigame",
        conditional: false
      });
    }

    if (node.failureTarget) {
      edges.push({
        from: node.id,
        to: node.failureTarget,
        label: "failure",
        kind: "minigame",
        conditional: false
      });
    }

    return edges;
  }

  if (node.kind === "choice") {
    return node.choices
      .filter((choice) => choice.target)
      .map((choice) => ({
        from: node.id,
        to: choice.target,
        label: choice.label || "choice",
        kind: "choice",
        conditional: Boolean(choice.condition && choice.condition.trim())
      }));
  }

  if (node.kind === "branch") {
    return node.branches
      .filter((branch) => branch.target)
      .map((branch) => {
        const condition = (branch.condition || "t").trim();

        return {
          from: node.id,
          to: branch.target,
          label: condition.toLowerCase() === "t" ? "default" : "case",
          kind: "branch",
          conditional: condition.toLowerCase() !== "t"
        };
      });
  }

  return [];
}

export function allEdges() {
  return state.nodes.flatMap(outgoingEdges);
}

export function autoLayout() {
  const byId = new Map(state.nodes.map((node) => [node.id, node]));
  const levels = new Map();
  const queue = [];

  if (state.startId && byId.has(state.startId)) {
    levels.set(state.startId, 0);
    queue.push(state.startId);
  }

  while (queue.length) {
    const id = queue.shift();
    const node = byId.get(id);
    const level = levels.get(id);

    outgoingEdges(node).forEach((edge) => {
      if (!byId.has(edge.to) || levels.has(edge.to)) {
        return;
      }

      levels.set(edge.to, level + 1);
      queue.push(edge.to);
    });
  }

  let disconnectedLevel = Math.max(0, ...Array.from(levels.values())) + 1;

  state.nodes.forEach((node) => {
    if (!levels.has(node.id)) {
      levels.set(node.id, disconnectedLevel);
      disconnectedLevel += 1;
    }
  });

  const buckets = new Map();

  state.nodes.forEach((node) => {
    const level = levels.get(node.id) || 0;

    if (!buckets.has(level)) {
      buckets.set(level, []);
    }

    buckets.get(level).push(node);
  });

  buckets.forEach((nodes, level) => {
    const columnHeight = (nodes.length - 1) * GRID_Y;
    const startY = Math.max(70, 220 - columnHeight / 2);

    nodes.forEach((node, index) => {
      node.x = 90 + level * GRID_X;
      node.y = startY + index * GRID_Y;
    });
  });
}

export function replaceTargetReferences(oldId, newId) {
  state.nodes.forEach((node) => {
    if (node.next === oldId) {
      node.next = newId;
    }

    if (node.target === oldId) {
      node.target = newId;
    }

    if (node.successTarget === oldId) {
      node.successTarget = newId;
    }

    if (node.failureTarget === oldId) {
      node.failureTarget = newId;
    }

    node.choices.forEach((choice) => {
      if (choice.target === oldId) {
        choice.target = newId;
      }
    });

    node.branches.forEach((branch) => {
      if (branch.target === oldId) {
        branch.target = newId;
      }
    });
  });
}

export function clearTargetReferences(id) {
  state.nodes.forEach((node) => {
    if (node.next === id) {
      node.next = "";
    }

    if (node.target === id) {
      node.target = "";
    }

    if (node.successTarget === id) {
      node.successTarget = "";
    }

    if (node.failureTarget === id) {
      node.failureTarget = "";
    }

    node.choices.forEach((choice) => {
      if (choice.target === id) {
        choice.target = "";
      }
    });

    node.branches.forEach((branch) => {
      if (branch.target === id) {
        branch.target = "";
      }
    });
  });
}

export function applyGraph(graph) {
  state.startId = graph.startId || "";
  state.selectedId = graph.selectedId || graph.startId || "";
  state.nodes = graph.nodes || [];

  autoLayout();

  if (!selectedNode() && state.nodes.length) {
    state.selectedId = state.nodes[0].id;
  }
}

export function seedGraph() {
  applyGraph({
    startId: "base/awake",
    selectedId: "base/awake",
    nodes: [
      {
        id: "base/awake",
        kind: "text",
        text: "you awake in a strange world...",
        next: "base/choice",
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
      },
      {
        id: "base/choice",
        kind: "choice",
        text: "exit bed?",
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
        choices: [
          { label: "yes", target: "base/yes", condition: "" },
          { label: "no", target: "base/no", condition: "" }
        ],
        branches: [],
        x: 0,
        y: 0
      },
      {
        id: "base/yes",
        kind: "text",
        text: "you stand beside the bed.",
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
        branches: [],
        x: 0,
        y: 0
      },
      {
        id: "base/no",
        kind: "text",
        text: "you go back to sleep.",
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
        branches: [],
        x: 0,
        y: 0
      }
    ]
  });
}
