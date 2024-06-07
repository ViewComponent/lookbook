import { LitElement, css, html } from "lit";

export class LookbookEmbed extends LitElement {
  static get styles() {
    return css`
      :host {
        display: block;
      }

      iframe {
        width: 100%;
        border: 0;
      }
    `;
  }

  static properties = {
    app: { type: String },
    preview: { type: String },
    scenario: { type: String },
    panels: { type: String },
    actions: { type: String },
    params: { attribute: false },
  };

  constructor() {
    super();

    this.onEmbedResize = this.onEmbedResize.bind(this);
    this.refreshIframe = this.refreshIframe.bind(this);

    this.params = {};
    for (const attr of this.attributes) {
      if (attr.name.startsWith("param-")) {
        this.params[attr.name.replace("param-", "")] = attr.value;
      }
    }
  }

  connectedCallback() {
    super.connectedCallback();
    window.addEventListener("message", this.onEmbedResize);
    window.addEventListener("color-scheme:change", this.refreshIframe);
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    window.removeEventListener("message", this.onEmbedResize);
    window.removeEventListener("color-scheme:change", this.refreshIframe);
  }

  onEmbedResize(message) {
    try {
      if (message.source === this.iframeElement.contentWindow) {
        const data = JSON.parse(message.data);
        if (data.action === "embed:resize") {
          this.iframeElement.style.height = `${data.height}px`;
        }
      }
    } catch {}
  }

  refreshIframe() {
    this.iframeElement.src = this.iframeElement.src;
  }

  get iframeElement() {
    return this.renderRoot.querySelector("iframe");
  }

  get src() {
    let baseUrl = this.app || guessBasePath();
    if (baseUrl.startsWith("/")) {
      baseUrl = `${location.protocol}//${location.host}${baseUrl}`;
    }

    const srcUrl = new URL(`${baseUrl}/embed`);

    if (this.preview) {
      srcUrl.searchParams.set("preview", this.preview);
    }
    if (this.scenario) {
      srcUrl.searchParams.set("scenario", this.scenario);
    }
    if (this.panels) {
      srcUrl.searchParams.set("panels", this.panels);
    }
    if (this.actions) {
      srcUrl.searchParams.set("actions", this.actions);
    }
    if (Object.keys(this.params).length) {
      srcUrl.searchParams.set("params", JSON.stringify(this.params));
    }

    return srcUrl;
  }

  render() {
    return html` <iframe src="${this.src}" frameborder="0" seamless></iframe> `;
  }
}

function guessBasePath() {
  const script =
    document.currentScript ||
    document.querySelector('script[src*="lookbook-assets"]');
  const scriptSrc = script.src;

  if (scriptSrc && scriptSrc.includes("lookbook-assets")) {
    return scriptSrc.split("?")[0].split("lookbook-assets")[0] + "lookbook";
  }

  return `//${location.host}/lookbook`;
}

customElements.define("lookbook-embed", LookbookEmbed);