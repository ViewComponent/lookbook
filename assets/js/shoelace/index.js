import { setBasePath } from "@shoelace-style/shoelace/dist/utilities/base-path.js";
import { registerIconLibrary } from "@shoelace-style/shoelace/dist/utilities/icon-library.js";

import "@shoelace-style/shoelace/dist/components/icon/icon.js";

import "@shoelace-style/shoelace/dist/components/button/button.js";
import "@shoelace-style/shoelace/dist/components/icon-button/icon-button.js";
import "@shoelace-style/shoelace/dist/components/copy-button/copy-button.js";
import "@shoelace-style/shoelace/dist/components/button-group/button-group.js";

import "@shoelace-style/shoelace/dist/components/split-panel/split-panel.js";

import "@shoelace-style/shoelace/dist/components/tree/tree.js";
import "@shoelace-style/shoelace/dist/components/tree-item/tree-item.js";

import "@shoelace-style/shoelace/dist/components/tab-group/tab-group.js";
import "@shoelace-style/shoelace/dist/components/tab/tab.js";
import "@shoelace-style/shoelace/dist/components/tab-panel/tab-panel.js";

import "@shoelace-style/shoelace/dist/components/popup/popup.js";
import "@shoelace-style/shoelace/dist/components/tooltip/tooltip.js";
import "@shoelace-style/shoelace/dist/components/resize-observer/resize-observer.js";

export default function initShoelace({ router, logger }) {
  if (process.env.NODE_ENV !== "production") {
    setBasePath("/lookbook-dev/shoelace");
  } else {
    setBasePath("/lookbook-assets/shoelace");
  }

  registerIconLibrary("default", {
    resolver: (name) =>
      `https://cdn.jsdelivr.net/npm/lucide-static@0.344.0/icons/${name}.svg`,
  });
}
