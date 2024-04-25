import AlpineComponent from "@js/alpine/component";
import Cookies from "js-cookie";

export default AlpineComponent("statusBar", () => {
  return {
    reset() {
      Cookies.remove("lookbook-display-options");
      Alpine.store("app").clear();
      window.location.reload();
      this.$logger.info(`Local storage cleared`);
    },
  };
});
