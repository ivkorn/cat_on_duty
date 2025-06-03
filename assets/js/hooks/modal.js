import Modal from 'bootstrap/js/dist/modal';

export default {
  mounted() {
    Modal.getOrCreateInstance(this.el).show();
  },
  destroyed() {
    Modal.getOrCreateInstance(this.el).hide();
  },
};
