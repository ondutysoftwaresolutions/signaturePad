import { api, LightningElement } from 'lwc';

const MOUSE_EVENTS = {
  DOWN: 'down',
  MOVE: 'move',
  OUT: 'out',
  UP: 'up',
};

export default class SignaturePadCanvas extends LightningElement {
  @api boxStyle;
  @api lineWidth;
  @api lineStroke;

  // =======================================================================================================================================================================================================================================
  // private variables
  // =======================================================================================================================================================================================================================================
  _isDrawing = false;
  _canvas;
  _canvasContext;
  _previousX_Position = 0;
  _currentX_Position = 0;
  _previousY_Position = 0;
  _currentY_Position = 0;

  // =======================================================================================================================================================================================================================================
  // lifecycle methods
  // =======================================================================================================================================================================================================================================
  connectedCallback() {
    this.template.addEventListener('mousemove', (e) => this._handleMouseEvent(e, MOUSE_EVENTS.MOVE));
    this.template.addEventListener('mousedown', (e) => this._handleMouseEvent(e, MOUSE_EVENTS.DOWN));
    this.template.addEventListener('mouseup', (e) => this._handleMouseEvent(e, MOUSE_EVENTS.UP));
    this.template.addEventListener('mouseout', (e) => this._handleMouseEvent(e, MOUSE_EVENTS.OUT));
  }

  disconnectedCallback() {
    this.template.removeEventListener('mousemove', (e) => this._handleMouseEvent(e, MOUSE_EVENTS.MOVE));
    this.template.removeEventListener('mousedown', (e) => this._handleMouseEvent(e, MOUSE_EVENTS.DOWN));
    this.template.removeEventListener('mouseup', (e) => this._handleMouseEvent(e, MOUSE_EVENTS.UP));
    this.template.removeEventListener('mouseout', (e) => this._handleMouseEvent(e, MOUSE_EVENTS.OUT));
  }

  // render and resize the canvas on finalizing the rendering
  renderedCallback() {
    this._canvas = this.template.querySelector('canvas');
    this._canvasContext = this._canvas.getContext('2d');

    this._resizeCanvas();
  }

  // =======================================================================================================================================================================================================================================
  // getter methods
  // =======================================================================================================================================================================================================================================
  get _lineWidth() {
    return parseFloat(this.lineWidth.replace(/[^\d.-]/g, ''));
  }

  // =======================================================================================================================================================================================================================================
  // private methods
  // =======================================================================================================================================================================================================================================
  _setCoordinates(event) {
    const clientRect = this._canvas.getBoundingClientRect();
    this._previousX_Position = this._currentX_Position;
    this._previousY_Position = this._currentY_Position;
    this._currentX_Position = event.clientX - clientRect.left;
    this._currentY_Position = event.clientY - clientRect.top;
  }

  _drawLines() {
    this._canvasContext.beginPath();
    this._canvasContext.moveTo(this._previousX_Position, this._previousY_Position);
    this._canvasContext.lineTo(this._currentX_Position, this._currentY_Position);
    this._canvasContext.strokeStyle = this.lineStroke;
    this._canvasContext.lineWidth = this._lineWidth;
    this._canvasContext.closePath();
    this._canvasContext.stroke();
  }

  //this draws the dot
  _drawDot() {
    this._canvasContext.beginPath();
    this._canvasContext.fillStyle = this._lineWidth;
    this._canvasContext.fillRect(this._currentX_Position, this._currentY_Position, this._lineWidth, this._lineWidth);
    this._canvasContext.closePath();
  }

  _resizeCanvas() {
    // resize
    const ratio = Math.max(window.devicePixelRatio || 1, 1);
    this._canvas.width = this._canvas.offsetWidth * ratio;
    this._canvas.height = this._canvas.offsetHeight * ratio;
    this._canvasContext.scale(ratio, ratio);
  }

  // handler for mouse events
  _handleMouseEvent(event, type) {
    if (event.target.tagName === 'CANVAS') {
      event.preventDefault();

      // if it's down draw a dot, and start the drawing
      if (type === MOUSE_EVENTS.DOWN) {
        this._isDrawing = true;
        this._setCoordinates(event);
        this._drawDot();
      }

      // on mouse up or leave, stop the drawing
      if ([MOUSE_EVENTS.UP, MOUSE_EVENTS.OUT].indexOf(type) !== -1) {
        if (this._isDrawing) {
          this._setFileOutput();
        }

        this._isDrawing = false;
      }

      // if we are drawing, recalculate the coordinates and draw the lines
      if (this._isDrawing) {
        this._setCoordinates(event);
        this._drawLines();
      }
    }
  }

  _setFileOutput() {
    const dataURL = this._canvas.toDataURL(this.saveFormat);
    let hasSignature = false;
    let fileBase64 = null;

    if (dataURL) {
      hasSignature = true;
      fileBase64 = dataURL.replace(/^data:image\/(png|jpg);base64,/, '');
    }

    // dispatch to parent
    this.dispatchEvent(
      new CustomEvent('finish', {
        detail: {
          hasSignature,
          fileBase64,
        },
      }),
    );
  }

  @api
  clearCanvas() {
    this._canvasContext.clearRect(0, 0, this._canvas.width, this._canvas.height);
  }
}
