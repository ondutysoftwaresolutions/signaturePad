import { LightningElement, api } from 'lwc';

export default class SignaturePadButtons extends LightningElement {
  @api showSave = false;
  @api saveLabel = 'Save';
  @api saveIcon = 'utility:save';
  @api saveVariant = 'brand';
  @api saveDisabled = false;
  @api clearLabel = 'Clear';
  @api clearIcon = 'utility:delete';
  @api clearVariant = 'border';
  @api showLabelIcon = false;

  get classClearButton() {
    if (this.showSave) {
      return 'slds-m-left_x-small';
    }

    return '';
  }

  handleSave() {
    this.dispatchEvent(new CustomEvent('save'));
  }

  handleClear() {
    this.dispatchEvent(new CustomEvent('clear'));
  }
}
