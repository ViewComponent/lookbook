export default function page() {
  return {
    init() {},
    scrollToTop() {
      console.log("scroll");
      this.$refs.scroller.scrollTop = 0;
    },
    checkForNavigation(event) {
      const link = event.target.closest("a[href]");
      if (link && !isExternalLink(link.href)) {
        event.preventDefault();
        this.setLocation(link.href);
      }
    },
    reloadIframes() {
      window.iFrameResize(
        {
          heightCalculationMethod: "lowestElement",
          onResized: (data) => this.$dispatch("iframe:resized", data),
        },
        `[x-ref='iframe']`
      );
    },
  };
}

function isExternalLink(url) {
  const tmp = document.createElement("a");
  tmp.href = url;
  return tmp.host !== window.location.host;
}