import { api, LightningElement } from 'lwc';

const BEHAVIOUR_EVENTS = {
  DOWN: 'down',
  MOVE: 'move',
  OUT: 'out',
  UP: 'up',
};

const TYPE_EVENT = {
  MOUSE: 'mouse',
  TOUCH: 'touch',
};

export default class SignaturePadCanvas extends LightningElement {
  @api border;
  @api background;
  @api lineWidth;
  @api lineStroke;
  @api hasSignature = false;

  // =======================================================================================================================================================================================================================================
  // private variables
  // =======================================================================================================================================================================================================================================
  _isDrawing = false;
  _temporaryFileData = undefined;
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
    this.template.addEventListener('mousemove', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.MOVE, TYPE_EVENT.MOUSE),
    );
    this.template.addEventListener('mousedown', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.DOWN, TYPE_EVENT.MOUSE),
    );
    this.template.addEventListener('mouseup', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.UP, TYPE_EVENT.MOUSE),
    );
    this.template.addEventListener('mouseout', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.OUT, TYPE_EVENT.MOUSE),
    );
    this.template.addEventListener('touchstart', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.DOWN, TYPE_EVENT.TOUCH),
    );
    this.template.addEventListener('touchmove', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.MOVE, TYPE_EVENT.TOUCH),
    );
    this.template.addEventListener('touchend', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.UP, TYPE_EVENT.TOUCH),
    );
    this.template.addEventListener('touchcancel', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.OUT, TYPE_EVENT.TOUCH),
    );

    window.addEventListener('orientationchange', () => this._startCanvas(true));
  }

  disconnectedCallback() {
    this.template.removeEventListener('mousemove', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.MOVE, TYPE_EVENT.MOUSE),
    );
    this.template.removeEventListener('mousedown', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.DOWN, TYPE_EVENT.MOUSE),
    );
    this.template.removeEventListener('mouseup', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.UP, TYPE_EVENT.MOUSE),
    );
    this.template.removeEventListener('mouseout', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.OUT, TYPE_EVENT.MOUSE),
    );
    this.template.removeEventListener('touchstart', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.DOWN, TYPE_EVENT.TOUCH),
    );
    this.template.removeEventListener(
      'touchmove',
      (e) => this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.MOVE, TYPE_EVENT.TOUCH),
      { passive: false },
    );
    this.template.removeEventListener('touchend', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.UP, TYPE_EVENT.TOUCH),
    );
    this.template.removeEventListener('touchcancel', (e) =>
      this._handleMouseTouchEvent(e, BEHAVIOUR_EVENTS.OUT, TYPE_EVENT.TOUCH),
    );
    window.removeEventListener('orientationchange', () => this._startCanvas(true));
  }

  // render and resize the canvas on finalizing the rendering
  renderedCallback() {
    this._startCanvas();
  }

  // =======================================================================================================================================================================================================================================
  // getter methods
  // =======================================================================================================================================================================================================================================
  get _lineWidth() {
    return parseFloat(this.lineWidth.replace(/[^\d.-]/g, ''));
  }

  get boxStyle() {
    return `border: ${this.border}; background: ${this.background}; width: 100%; height: 100%; touch-action: none; position: absolute; left: 0; top: 0; user-select: none`;
  }

  // =======================================================================================================================================================================================================================================
  // private methods
  // =======================================================================================================================================================================================================================================
  _startCanvas(orientationChange = false) {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    window.setTimeout(() => {
      this._canvas = this.template.querySelector('canvas');
      this._canvasContext = this._canvas.getContext('2d');

      if (orientationChange && this.hasSignature && !this._temporaryFileData) {
        this._temporaryFileData = this._canvas.toDataURL(this.saveFormat);
      }

      this.clearCanvas(false);
      this._resizeCanvas();

      if (orientationChange && this._temporaryFileData) {
        this._drawFromURL();
      }
    }, 500);
  }

  _setCoordinates(event, origin) {
    const clientRect = this._canvas.getBoundingClientRect();

    this._previousX_Position = this._currentX_Position;
    this._previousY_Position = this._currentY_Position;

    // mouse
    if (origin === TYPE_EVENT.MOUSE) {
      this._currentX_Position = event.clientX - clientRect.left;
      this._currentY_Position = event.clientY - clientRect.top;
    } else {
      // touch
      const target = event.touches[0];

      this._currentX_Position = target.clientX - clientRect.left;
      this._currentY_Position = target.clientY - clientRect.top;
    }
  }

  _drawLines() {
    this._canvasContext.beginPath();
    this._canvasContext.moveTo(this._previousX_Position, this._previousY_Position);
    this._canvasContext.lineTo(this._currentX_Position, this._currentY_Position);
    this._canvasContext.strokeStyle = this.lineStroke;
    this._canvasContext.lineWidth = this._lineWidth;
    this._canvasContext.stroke();
    this._canvasContext.closePath();
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
  _handleMouseTouchEvent(event, type, origin) {
    if (event.target.tagName === 'CANVAS') {
      event.stopPropagation();
      event.preventDefault();

      // if it's down or touch start draw a dot, and start the drawing
      if (type === BEHAVIOUR_EVENTS.DOWN) {
        this._isDrawing = true;
        this._setCoordinates(event, origin);
        this._drawDot();
      }

      // on mouse up or leave or touch end, stop the drawing
      if ([BEHAVIOUR_EVENTS.UP, BEHAVIOUR_EVENTS.OUT].indexOf(type) !== -1) {
        if (this._isDrawing) {
          this._setFileOutput();
        }

        this._isDrawing = false;
      }

      // if we are drawing, recalculate the coordinates and draw the lines
      if (this._isDrawing) {
        document.body.style.overflow = 'hidden';
        this._setCoordinates(event, origin);
        this._drawLines();
      }
    }
  }

  _setFileOutput() {
    const dataURL = this._canvas.toDataURL(this.saveFormat);
    let hasSignature = false;
    let fileBase64 = null;

    this._resetPositions();

    if (dataURL) {
      document.body.style.overflow = 'auto';

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

  _resetPositions() {
    this._previousX_Position = 0;
    this._previousY_Position = 0;
    this._currentX_Position = 0;
    this._currentY_Position = 0;
  }

  _drawFromURL() {
    return new Promise((resolve, reject) => {
      const image = new Image();
      const ratio = Math.max(window.devicePixelRatio || 1, 1);
      const width = this._canvas.width / ratio;
      const height = this._canvas.height / ratio;

      image.onload = () => {
        // get the scale
        const scale = Math.min(width / image.width, height / image.height);
        // get the top left position of the image
        const x = width / 2 - (image.width / 2) * scale;
        const y = height / 2 - (image.height / 2) * scale;

        this._canvasContext.drawImage(image, x, y, image.width * scale, image.height * scale);
        resolve();
      };

      image.onerror = (error) => {
        reject(error);
      };

      image.crossOrigin = 'anonymous';
      image.src = this._temporaryFileData;
    });
  }

  @api
  clearCanvas(fromButton = true) {
    // reset the positions
    this._resetPositions();

    if (fromButton) {
      this._temporaryFileData = undefined;
    }

    // empty the canvas and pain it again with background color
    this._canvasContext.clearRect(0, 0, this._canvas.width, this._canvas.height);
    this._canvasContext.fillStyle = this.background;
    this._canvasContext.fillRect(0, 0, this._canvas.width, this._canvas.height);
  }
}
