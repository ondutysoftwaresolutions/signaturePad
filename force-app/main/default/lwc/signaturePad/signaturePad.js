import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';
import saveSignature from '@salesforce/apex/SignaturePadController.saveSignature';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SignaturePad extends LightningElement {
  @api recordId;
  @api objectApiName;
  @api availableActions = [];

  // =======================================================================================================================================================================================================================================
  // main component variables
  // =======================================================================================================================================================================================================================================
  @api showTitle;
  @api showIcon;
  @api iconName;
  @api title;

  // =======================================================================================================================================================================================================================================
  // signature box variables
  // =======================================================================================================================================================================================================================================
  @api boxWidth;
  @api boxHeight;
  @api boxBorderWidth;
  @api boxBorderStyle;
  @api boxBorderColor;
  @api boxBackground;

  // =======================================================================================================================================================================================================================================
  // draw lines variables
  // =======================================================================================================================================================================================================================================
  @api lineStroke;
  @api lineWidth;

  // =======================================================================================================================================================================================================================================
  // buttons variables
  // =======================================================================================================================================================================================================================================
  @api saveLabel;
  @api saveIcon;
  @api saveVariant;
  @api clearLabel;
  @api clearIcon;
  @api clearVariant;
  @api buttonsPosition;

  // =======================================================================================================================================================================================================================================
  // flow input specific variables
  // =======================================================================================================================================================================================================================================
  @api showSaveButton;
  @api showLabelAndIconButtons;
  @api requiredMessage;
  @api isRequired;

  // =======================================================================================================================================================================================================================================
  // flow output variables
  // =======================================================================================================================================================================================================================================
  @api contentDocumentId;
  @api contentVersionId;
  @api contentDocumentLinkId;
  @api fileBase64;
  @api fileExtension;
  @api saveSuccess;
  @api errorMessage;

  // =======================================================================================================================================================================================================================================
  // save behavior variables
  // =======================================================================================================================================================================================================================================
  @api saveAndLinkToRecord;
  @api fileTitle;
  @api recordIdToLinkTo;
  @api saveFormat;
  @api clearSignatureAfterSave;

  // =======================================================================================================================================================================================================================================
  // toast variables
  // =======================================================================================================================================================================================================================================
  @api showToastOnSave;
  @api toastMessage;

  // =======================================================================================================================================================================================================================================
  // UI variables
  // =======================================================================================================================================================================================================================================
  errorGetting = undefined;
  titleToShow;
  savingData = false;
  hasSignature = false;

  // =======================================================================================================================================================================================================================================
  // private variables
  // =======================================================================================================================================================================================================================================
  _fileTitleToSave;
  _recordIdToSave;

  // =======================================================================================================================================================================================================================================
  // lifecycle methods
  // =======================================================================================================================================================================================================================================
  connectedCallback() {
    this._setDefaultValues();
  }

  // =======================================================================================================================================================================================================================================
  // validate for flow screen, if it has a signature or it doesn't but it was saved or it doesn't but it's not required
  // =======================================================================================================================================================================================================================================
  @api validate() {
    if (this.hasSignature || (!this.hasSignature && !this.isRequired) || (!this.hasSignature && this.saveSuccess)) {
      return { isValid: true };
    }
    return {
      isValid: false,
      errorMessage: this.requiredMessage,
    };
  }

  // =======================================================================================================================================================================================================================================
  // wire methods
  // =======================================================================================================================================================================================================================================
  // get the current record data
  @wire(getRecord, { recordId: '$recordId', fields: '$_mainRecordFields' })
  getCurrentRecordData({ error, data }) {
    if (data) {
      this._mainRecordFields.forEach((fl) => {
        let regex = new RegExp('{{' + fl + '}}', 'g');

        // value to use
        const theValue = getFieldDisplayValue(data, fl) || getFieldValue(data, fl);

        // build the title if any
        if (this.titleToShow.indexOf(fl) !== -1) {
          this.titleToShow = this.titleToShow.replace(regex, theValue);
        }

        // build the file title if any
        if (this._fileTitleToSave.indexOf(fl) !== -1) {
          this._fileTitleToSave = this._fileTitleToSave.replace(regex, theValue);
        }

        // build record to link to if any
        if (this._recordIdToSave.indexOf(fl) !== -1) {
          this._recordIdToSave = this._recordIdToSave.replace(regex, theValue);
        }

        this.errorGetting = undefined;
      });
    } else if (error) {
      this.errorGetting = `Error getting data - ${this._getErrorFromObject(error)}`;
    }
  }

  // =======================================================================================================================================================================================================================================
  // getter methods
  // =======================================================================================================================================================================================================================================
  get boxStyle() {
    const width = isNaN(this.boxWidth) ? this.boxWidth : `${this.boxWidth}px`;
    const height = isNaN(this.boxHeight) ? this.boxHeight : `${this.boxHeight}px`;
    const borderWidth = isNaN(this.boxBorderWidth) ? this.boxBorderWidth : `${this.boxBorderWidth}px`;
    return `border: ${borderWidth} ${this.boxBorderStyle} ${this.boxBorderColor}; background: ${this.boxBackground}; width: ${width}; height: ${height};`;
  }

  get footerClass() {
    return `slds-text-align--${this.buttonsPosition}`;
  }

  get isSaveDisabled() {
    return !this.hasSignature;
  }

  get isInFlow() {
    return !this.recordId && this.availableActions.length > 0;
  }

  get _formattedTitle() {
    return this.title ? this.title.replace('Record.', `${this.objectApiName}.`) : '';
  }

  get _formattedFileTitle() {
    return this.fileTitle ? this.fileTitle.replace('Record.', `${this.objectApiName}.`) : '';
  }

  get _formattedRecordIdLinkTo() {
    return this.recordIdToLinkTo ? this.recordIdToLinkTo.replace('Record.', `${this.objectApiName}.`) : '';
  }

  get _fileExtension() {
    return this.saveFormat.split('/')[1];
  }

  get _mainRecordFields() {
    let fields = [`${this.objectApiName}.Id`];

    const hasMergeFields =
      this._formattedFileTitle.indexOf('{{') !== -1 ||
      this._formattedRecordIdLinkTo.indexOf('{{') !== -1 ||
      this._formattedTitle.indexOf('{{') !== -1;

    if (hasMergeFields) {
      // if we have a merge field in the title
      if (this._formattedTitle && this._formattedTitle.indexOf('{{') !== -1) {
        fields = fields.concat(this._getFieldsFromString(this._formattedTitle));
      }

      // if we have a merge field in the file title
      if (this._formattedFileTitle && this._formattedFileTitle.indexOf('{{') !== -1) {
        fields = fields.concat(this._getFieldsFromString(this._formattedFileTitle));
      }

      // if we have a merge field in the record to link to
      if (this._formattedRecordIdLinkTo && this._formattedRecordIdLinkTo.indexOf('{{') !== -1) {
        fields = fields.concat(this._getFieldsFromString(this._formattedRecordIdLinkTo));
      }

      // take unique fields
      fields = [...new Set(fields)];
    }

    return fields;
  }

  // =======================================================================================================================================================================================================================================
  // private methods
  // =======================================================================================================================================================================================================================================
  _setDefaultValues() {
    // set default specifically for flows, this is because flows does not use the default from the configuration XML file yet.
    if (this.isInFlow) {
      this.showSaveButton = this.showSaveButton === undefined ? false : this.showSaveButton;
      this.showLabelAndIconButtons = this.showLabelAndIconButtons === undefined ? false : this.showLabelAndIconButtons;
      this.showTitle = this.showTitle === undefined ? true : this.showTitle;
      this.title = this.title || 'Sign here please';
      this.showIcon = this.showIcon === undefined ? true : this.showIcon;
      this.iconName = this.iconName || 'utility:signature';
      this.boxWidth = this.boxWidth || '100%';
      this.boxHeight = this.boxHeight || '300px';
      this.boxBorderWidth = this.boxBorderWidth || '2px';
      this.boxBorderStyle = this.boxBorderStyle || 'solid';
      this.boxBorderColor = this.boxBorderColor || 'rgb(136, 135, 135)';
      this.boxBackground = this.boxBackground || 'transparent';
      this.lineStroke = this.lineStroke || 'blue';
      this.lineWidth = this.lineWidth || '1.5';
      this.saveLabel = this.saveLabel || 'Save';
      this.saveIcon = this.saveIcon || 'utility:save';
      this.saveVariant = this.saveVariant || 'brand';
      this.clearLabel = this.clearLabel || 'Clear';
      this.clearIcon = this.clearIcon || 'utility:delete';
      this.clearVariant = this.clearVariant || 'neutral';
      this.buttonsPosition = this.buttonsPosition || 'left';
      this.saveFormat = this.saveFormat || 'image/png';
      this.saveAndLinkToRecord = this.saveAndLinkToRecord === undefined ? false : this.saveAndLinkToRecord;
      this.clearSignatureAfterSave = this.clearSignatureAfterSave === undefined ? true : this.clearSignatureAfterSave;
      this.requiredMessage = this.requiredMessage || 'The signature is required';
      this.isRequired = this.isRequired === undefined ? true : this.isRequired;
    }

    // build the default values for all the types of components
    this.titleToShow = this._formattedTitle;
    this._fileTitleToSave = this._formattedFileTitle || null;
    this._recordIdToSave = this._formattedRecordIdLinkTo || this.recordId || null;
  }

  _showToastMessage(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
      }),
    );
  }

  // function to get fields that are between double brackets
  _getFieldsFromString(field) {
    return field.match(/(?<={{)(.*?)(?=}})/g);
  }

  _getErrorFromObject(error) {
    if (error.body) {
      if (Array.isArray(error.body)) {
        return error.body.map((e) => e.message).join(', ');
      } else if (typeof error.body.message === 'string') {
        let errorToReturn;
        // try the json
        try {
          const parsed = JSON.parse(error.body.message);
          const statusCode = parsed.code;
          errorToReturn = `${statusCode !== 700 ? 'ERROR: ' : ''}${parsed.message}`;
        } catch (e) {
          errorToReturn = error.body.message;
        }

        return errorToReturn;
      }
    }

    return error.message;
  }

  // =======================================================================================================================================================================================================================================
  // handler methods
  // =======================================================================================================================================================================================================================================
  handleSave() {
    // build the object to save
    const objectToSave = {
      signatureString: this.fileBase64,
      extension: this._fileExtension,
      title: this._fileTitleToSave,
      recordId: this.saveAndLinkToRecord && this._recordIdToSave ? this._recordIdToSave : null,
    };
    this.savingData = true;

    saveSignature({ jsonRequest: JSON.stringify(objectToSave) })
      .then((result) => {
        this.savingData = false;
        if (result.isSuccess) {
          if (this.isInFlow) {
            this.saveSuccess = true;
            this.errorMessage = undefined;
            this.contentDocumentId = result.contentDocumentId;
            this.contentVersionId = result.contentVersionId;
            this.contentDocumentLinkId = result.contentDocumentLinkId;
          } else {
            if (this.showToastOnSave) {
              this._showToastMessage('Success', this.toastMessage, 'success');
            }
          }
        } else {
          if (this.isInFlow) {
            this.saveSuccess = false;
            this.errorMessage = result.errorMessage;
          } else {
            this._showToastMessage('Error', result.errorMessage, 'error');
          }
        }

        // clear after save if required
        if (this.clearSignatureAfterSave) {
          this.handleClear();
        }
      })
      .catch((error) => {
        this.savingData = false;
        const errorMessage = this._getErrorFromObject(error);

        if (this.isInFlow) {
          this.saveSuccess = false;
          this.errorMessage = errorMessage;
        } else {
          this._showToastMessage('Error', errorMessage, 'error');
        }
      });
  }

  handleFinishDrawing(event) {
    this.hasSignature = event.detail.hasSignature;
    this.fileBase64 = event.detail.fileBase64;
    this.fileExtension = this._fileExtension;
  }

  // clear the signature pad
  handleClear() {
    // call the children api for clear
    this.template.querySelector('c-signature-pad-canvas').clearCanvas();

    this.hasSignature = false;
    this.fileBase64 = null;
  }
}
