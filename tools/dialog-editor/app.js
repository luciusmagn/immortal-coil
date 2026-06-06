import { exportGraph, parseDialog } from "./lisp.js";
import {
  NODE_HEIGHT,
  NODE_WIDTH,
  applyGraph,
  autoLayout,
  clearTargetReferences,
  defaultNode,
  nodeById,
  replaceTargetReferences,
  seedGraph,
  selectedNode,
  state,
  uniqueNodeId
} from "./graph-model.js";
import {
  configureView,
  render,
  renderGraphAndSource,
  setWorldTransform
} from "./graph-view.js";

const elements = {};

function collectElements() {
  [
    "loadOpeningButton",
    "fileInput",
    "layoutButton",
    "exportButton",
    "graphCount",
    "startNodeLabel",
    "zoomOutButton",
    "zoomResetButton",
    "zoomInButton",
    "graphStage",
    "graphWorld",
    "edgeLayer",
    "nodeLayer",
    "selectedTitle",
    "addNodeButton",
    "nodeForm",
    "nodeIdInput",
    "nodeKindSelect",
    "visualFields",
    "nodeParticlesSelect",
    "nodeParticleFadeInput",
    "layoutField",
    "nodeLayoutSelect",
    "textField",
    "nodeTextInput",
    "nextField",
    "nodeNextInput",
    "inputFields",
    "nodeTargetInput",
    "nodeResponseKeyInput",
    "nodeMinField",
    "nodeMinLabel",
    "nodeMinInput",
    "nodeMaxField",
    "nodeMaxLabel",
    "nodeMaxInput",
    "allowEmptyField",
    "nodeAllowEmptyInput",
    "minigameFields",
    "nodeMinigameInput",
    "nodeSuccessTargetInput",
    "nodeFailureTargetInput",
    "choicesField",
    "choicesList",
    "addChoiceButton",
    "branchesField",
    "branchesList",
    "addBranchButton",
    "setStartButton",
    "deleteNodeButton",
    "sourceOutput",
    "copyButton",
    "nodeIds"
  ].forEach((id) => {
    elements[id] = document.getElementById(id);
  });
}

function updateSelectedNode(callback, fullRender) {
  const node = selectedNode();

  if (!node) {
    return;
  }

  callback(node);

  if (fullRender) {
    render();
  } else {
    renderGraphAndSource();
  }
}

function loadSource(source) {
  applyGraph(parseDialog(source));
  render();
}

function loadOpening(options) {
  const quiet = options && options.quiet;

  return fetch("../../game/opening.lisp")
    .then((response) => {
      if (!response.ok) {
        throw new Error("Opening file returned " + response.status + ".");
      }
      return response.text();
    })
    .then(loadSource)
    .catch((error) => {
      if (!quiet) {
        window.alert("Could not load game/opening.lisp. Start the local server from the repository root, or use Import.");
      }
      throw error;
    });
}

function renameSelectedNode(value) {
  const node = selectedNode();
  const newId = value.trim();

  if (!node || !newId || newId === node.id) {
    return;
  }

  if (nodeById(newId)) {
    elements.nodeIdInput.value = node.id;
    return;
  }

  const oldId = node.id;
  node.id = newId;
  state.selectedId = newId;

  if (state.startId === oldId) {
    state.startId = newId;
  }

  replaceTargetReferences(oldId, newId);
  render();
}

function addNode() {
  const rect = elements.graphStage.getBoundingClientRect();
  const x = Math.max(40, (rect.width / 2 - state.pan.x) / state.zoom - NODE_WIDTH / 2);
  const y = Math.max(40, (rect.height / 2 - state.pan.y) / state.zoom - NODE_HEIGHT / 2);
  const node = defaultNode(uniqueNodeId("base/new-node"), x, y);

  state.nodes.push(node);
  state.selectedId = node.id;

  if (!state.startId) {
    state.startId = node.id;
  }

  render();
}

function deleteSelectedNode() {
  const node = selectedNode();

  if (!node) {
    return;
  }

  const id = node.id;
  state.nodes = state.nodes.filter((candidate) => candidate.id !== id);
  clearTargetReferences(id);

  if (state.startId === id) {
    state.startId = state.nodes[0] ? state.nodes[0].id : "";
  }

  state.selectedId = state.startId || (state.nodes[0] ? state.nodes[0].id : "");
  render();
}

function setStartNode() {
  const node = selectedNode();

  if (!node) {
    return;
  }

  state.startId = node.id;
  render();
}

function changeNodeKind(kind) {
  updateSelectedNode((node) => {
    node.kind = kind;

    if (kind === "choice" && !node.choices.length) {
      node.choices.push({ label: "option", target: "", condition: "" });
    }

    if (kind === "branch" && !node.branches.length) {
      node.branches.push({ condition: "t", target: "" });
    }

    if (kind === "string" && !node.maxLength) {
      node.maxLength = "32";
    }

    if (kind === "minigame" && !node.minigame) {
      node.minigame = "wire-flight";
    }
  }, true);
}

function addChoice() {
  updateSelectedNode((node) => {
    node.choices.push({ label: "option", target: "", condition: "" });
  }, true);
}

function addBranch() {
  updateSelectedNode((node) => {
    node.branches.push({ condition: "t", target: "" });
  }, true);
}

function exportDownload() {
  const blob = new Blob([exportGraph(state)], { type: "text/plain;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");

  link.href = url;
  link.download = "opening.lisp";
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

function copySource() {
  const text = elements.sourceOutput.value;

  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(text);
    return;
  }

  elements.sourceOutput.focus();
  elements.sourceOutput.select();
  document.execCommand("copy");
}

function handleNodePointerDown(event, node) {
  event.preventDefault();
  event.stopPropagation();
  state.selectedId = node.id;
  state.draggingNode = {
    id: node.id,
    pointerX: event.clientX,
    pointerY: event.clientY,
    nodeX: node.x,
    nodeY: node.y
  };
  render();
}

function bindGraphMovement() {
  elements.graphStage.addEventListener("pointerdown", (event) => {
    event.preventDefault();
    state.panning = {
      pointerX: event.clientX,
      pointerY: event.clientY,
      panX: state.pan.x,
      panY: state.pan.y
    };
    elements.graphStage.classList.add("dragging");
  });

  elements.graphStage.addEventListener("wheel", (event) => {
    event.preventDefault();
    const oldZoom = state.zoom;
    const nextZoom = event.deltaY < 0
      ? Math.min(1.8, state.zoom * 1.08)
      : Math.max(0.35, state.zoom * 0.92);
    const rect = elements.graphStage.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;
    const worldX = (x - state.pan.x) / oldZoom;
    const worldY = (y - state.pan.y) / oldZoom;

    state.zoom = nextZoom;
    state.pan.x = x - worldX * nextZoom;
    state.pan.y = y - worldY * nextZoom;
    renderGraphAndSource();
  }, { passive: false });

  window.addEventListener("pointermove", (event) => {
    if (state.draggingNode) {
      const node = nodeById(state.draggingNode.id);

      if (!node) {
        return;
      }

      node.x = Math.max(0, state.draggingNode.nodeX + (event.clientX - state.draggingNode.pointerX) / state.zoom);
      node.y = Math.max(0, state.draggingNode.nodeY + (event.clientY - state.draggingNode.pointerY) / state.zoom);
      renderGraphAndSource();
      return;
    }

    if (state.panning) {
      state.pan.x = state.panning.panX + event.clientX - state.panning.pointerX;
      state.pan.y = state.panning.panY + event.clientY - state.panning.pointerY;
      setWorldTransform();
    }
  });

  window.addEventListener("pointerup", () => {
    state.draggingNode = null;
    state.panning = null;
    elements.graphStage.classList.remove("dragging");
  });
}

function bindToolbar() {
  elements.loadOpeningButton.addEventListener("click", () => {
    loadOpening({ quiet: false }).catch(() => {});
  });

  elements.fileInput.addEventListener("change", () => {
    const file = elements.fileInput.files[0];

    if (!file) {
      return;
    }

    file.text().then(loadSource);
    elements.fileInput.value = "";
  });

  elements.layoutButton.addEventListener("click", () => {
    autoLayout();
    render();
  });

  elements.exportButton.addEventListener("click", exportDownload);
  elements.copyButton.addEventListener("click", copySource);
  elements.addNodeButton.addEventListener("click", addNode);
}

function bindInspector() {
  elements.deleteNodeButton.addEventListener("click", deleteSelectedNode);
  elements.setStartButton.addEventListener("click", setStartNode);
  elements.addChoiceButton.addEventListener("click", addChoice);
  elements.addBranchButton.addEventListener("click", addBranch);

  elements.nodeIdInput.addEventListener("change", () => {
    renameSelectedNode(elements.nodeIdInput.value);
  });

  elements.nodeKindSelect.addEventListener("change", () => {
    changeNodeKind(elements.nodeKindSelect.value);
  });

  elements.nodeLayoutSelect.addEventListener("change", () => {
    updateSelectedNode((node) => {
      node.layout = elements.nodeLayoutSelect.value;
    }, false);
  });

  elements.nodeParticlesSelect.addEventListener("change", () => {
    updateSelectedNode((node) => {
      node.particleMode = elements.nodeParticlesSelect.value;
    }, false);
  });

  elements.nodeParticleFadeInput.addEventListener("input", () => {
    updateSelectedNode((node) => {
      node.particleFadeSeconds = elements.nodeParticleFadeInput.value;
    }, false);
  });

  elements.nodeTextInput.addEventListener("input", () => {
    updateSelectedNode((node) => {
      node.text = elements.nodeTextInput.value;
    }, false);
  });

  elements.nodeNextInput.addEventListener("input", () => {
    updateSelectedNode((node) => {
      node.next = elements.nodeNextInput.value;
    }, false);
  });

  elements.nodeTargetInput.addEventListener("input", () => {
    updateSelectedNode((node) => {
      node.target = elements.nodeTargetInput.value;
    }, false);
  });

  elements.nodeResponseKeyInput.addEventListener("input", () => {
    updateSelectedNode((node) => {
      node.responseKey = elements.nodeResponseKeyInput.value;
    }, false);
  });

  elements.nodeMinInput.addEventListener("input", () => {
    updateSelectedNode((node) => {
      node.min = elements.nodeMinInput.value;
    }, false);
  });

  elements.nodeMaxInput.addEventListener("input", () => {
    updateSelectedNode((node) => {
      if (node.kind === "string") {
        node.maxLength = elements.nodeMaxInput.value;
      } else {
        node.max = elements.nodeMaxInput.value;
      }
    }, false);
  });

  elements.nodeAllowEmptyInput.addEventListener("change", () => {
    updateSelectedNode((node) => {
      node.allowEmpty = elements.nodeAllowEmptyInput.checked;
    }, false);
  });

  elements.nodeMinigameInput.addEventListener("input", () => {
    updateSelectedNode((node) => {
      node.minigame = elements.nodeMinigameInput.value;
    }, false);
  });

  elements.nodeSuccessTargetInput.addEventListener("input", () => {
    updateSelectedNode((node) => {
      node.successTarget = elements.nodeSuccessTargetInput.value;
    }, false);
  });

  elements.nodeFailureTargetInput.addEventListener("input", () => {
    updateSelectedNode((node) => {
      node.failureTarget = elements.nodeFailureTargetInput.value;
    }, false);
  });
}

function bindZoomControls() {
  elements.zoomOutButton.addEventListener("click", () => {
    state.zoom = Math.max(0.35, state.zoom * 0.88);
    renderGraphAndSource();
  });

  elements.zoomResetButton.addEventListener("click", () => {
    state.zoom = 1;
    state.pan = { x: 64, y: 52 };
    renderGraphAndSource();
  });

  elements.zoomInButton.addEventListener("click", () => {
    state.zoom = Math.min(1.8, state.zoom * 1.12);
    renderGraphAndSource();
  });
}

function bindControls() {
  bindToolbar();
  bindInspector();
  bindZoomControls();
  bindGraphMovement();
}

function init() {
  collectElements();
  configureView(elements, {
    onNodePointerDown: handleNodePointerDown
  });
  bindControls();
  seedGraph();
  render();
  loadOpening({ quiet: true }).catch(() => {});
}

globalThis.DialogGraphEditor = {
  parseDialog: parseDialog,
  exportGraph: exportGraph
};

window.addEventListener("DOMContentLoaded", init);
