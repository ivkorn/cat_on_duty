import { Modal } from 'bootstrap';

export default {
  mounted() {
    Modal.getOrCreateInstance(this.el).show();
  },
  destroyed() {
    Modal.getOrCreateInstance(this.el).hide();
  },
};
