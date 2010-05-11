// Class to hold the file upload information.
var FileToUpload = function(id, name, index) {
  object = {
    removeFrom: function(arr) { arr.remove(this); },
    toString: function() { return '[' + id + ':' + name + ',index=' + index + ',tries=' + this.tries + ']'; },

    uploadVia: function(uploader, callback) {
      this.tries++;
      uploader.uploader.upload(this.id, uploader.uploadPath.replacement('' + this.index), 'POST', { '_method': 'put' }, 'data');
      if (callback != undefined) { callback(); }
    }
  };
  object.id    = id;
  object.name  = name;
  object.index = index;
  object.tries = 0;
  return object;
};
var ButtonStateHelper = {
  disable: function() { this.attr('disabled', 'disabled'); },
  enable:  function() { this.removeAttr('disabled'); },
  stateTo: function(enableState) { if (enableState) { this.enable(); } else { this.disable(); } }
};
var ReplaceableContentHelper = {
  replacement: function(value) { 
    return this.value.replace('XXX', value); 
  } 
};
var ArrayExtensions = {
  remove: function(element) { this.splice($.inArray(element, this), 1); },
  isEmpty: function() { return this.length == 0; },
  first: function() { return this[ 0 ]; },
  last: function() { return this[ this.length-1 ]; }
};
var ListElement = {
  row: function(content, row_class) {
    row_class = (row_class == undefined) ? '' : ' class="' + row_class + '"'; 
    this.append('<li' + row_class + '>' + content + '</li>'); 
  },
  lastChild: function() { return $('li:last-child', this); }
};

var handler = {
  // Path functions
  setFinishPath: function(path) { this.finishPath = $.extend({ value: path }, ReplaceableContentHelper); },
  setUploadPath: function(path) { this.uploadPath = $.extend({ value: path }, ReplaceableContentHelper); },
  setCancelPath: function(path) { this.cancelPath = path; },

  // Utility functions used later
  fileFromEvent:  function(event)         { return $.grep(this.filesToUpload, function(v) { return v.id == event.id; })[ 0 ]; },
  updateProgress: function(file, message) { $('#' + file.id).replaceWith('<span id="' + file.id + '">' + message + '</span>'); },

  clearFileList: function() { 
    this.filesToUpload = $.extend([], ArrayExtensions);
    this.fileUploadElement.empty(); 
    this.uploader.clearFileList(); 
  },

  // Button handling code
  buttonHandler:   function(button, handler) { button.click($.proxy(handler, this)); $.extend(button, ButtonStateHelper); },
  disableButtons:  function()        { $.each([ this.uploadButton, this.clearButton ], function(index, button) { button.disable(); }) },
  setUploadButton: function(element) { this.uploadButton = element ; this.buttonHandler(element, this.clickToUploadEventHandler); },
  setClearButton:  function(element) { this.clearButton = element ; this.buttonHandler(element, this.clickToClearEventHandler); },
  setCancelButton: function(element) { this.cancelButton = element; this.buttonHandler(element, this.clickToCancelEventHandler); },

  updateButtonState: function() {
    var uploadButton = true, clearButton = true;
    if (this.batchId() == '')         { uploadButton = false; }                       // No batch ID enter, no upload!
    if (this.filesToUpload.isEmpty()) { uploadButton = false; clearButton = false; }  // No files, no upload or clear!
    this.uploadButton.stateTo(uploadButton);
    this.clearButton.stateTo(clearButton);
  },

  // Working with batch ID
  batchId:      function()      { return this.batchIdField.value; },
  batchIdField: function(field) { this.batchIdField = field[ 0 ]; field.change($.proxy(this.updateButtonState, this)); },

  // Various elements we need access to
  setProgressElement: function(element) { this.progressElement = $.extend(element, ListElement); },
  setFileUploadList: function(element) { this.fileUploadElement = $.extend(element, ListElement); },

  redirect: function() { window.location = this.finishPath.replacement(this.batchId()); },

  startUploadingNextFile: function(callback) {
    if (this.filesToUpload.isEmpty()) {
      callback();
    } else {
      this.filesToUpload.first().uploadVia(this);
    }
  },

  // Handles the YUI Uploader informing us that it is ready to do some work.
  contentReadyHandler: function() {
    this.uploader.setAllowLogging(true); 
    this.uploader.setAllowMultipleFiles(true);
    this.uploader.setSimUploadLimit(1);
    //this.uploader.setFileFilters([ { description: 'Clusterview Images', extensions: '*.tif' } ]);
  },

  removeHandlerFor: function(fileInfo) {
    return $.proxy(function(event) {
      fileInfo.removeFrom(this.filesToUpload);
      this.uploader.removeFile(fileInfo.id);
      this.updateButtonState();
      $(event.target).parent().remove();
    }, this);
  },

  // Handles storing the files selected for upload so that the user can see what they're
  // going to be pushing and adjust it if necessary.
  fileSelectHandler: function(event) {
    // Proxy this method so that it works in the event handling code!
    var removeHandlerFor = $.proxy(this.removeHandlerFor, this);

    // NOTE[md12]: One file can be selected for upload many times, which is a bit of a pain!
    //
    // There's nothing that can be done about this because we can't tell the difference between the
    // two instance by the looks of it (name is not a full path, id is different).
    var filesToUpload = this.filesToUpload, fileList = this.fileUploadElement;
    fileList.empty();

    var indexOfImageWithinUpload = filesToUpload.isEmpty() ? 0 : filesToUpload.last().index + 1;
    $.each(event.fileList, function(file, information) { 
      var fileInfo = FileToUpload(information.id, information.name, indexOfImageWithinUpload++);
      filesToUpload.push(fileInfo);
      fileList.row('<span class="filename">' + fileInfo.name + '</span> (<a href="#" id="' + fileInfo.id + '" class="file_to_upload">Remove</a>)');
      $('a', fileList.lastChild()).click(removeHandlerFor(fileInfo));
    });
    this.updateButtonState();
  },

  // Handles the start of uploading an individual file.
  uploadStartHandler: function(event) {
    this.updateProgress(event, '<span class="status intermediate">Starting to upload ...</span>');
  },

  // Handles the completion of uploading an individual file.
  uploadCompleteHandler: function(event) {
    this.updateProgress(event, '<span class="status intermediate">Upload complete, waiting for server ...</span>');
  },

  // Handles the completion of a response from the server for an individual file
  uploadCompleteDataHandler: function(event) {
    var fileJustUploaded = this.fileFromEvent(event);
    fileJustUploaded.removeFrom(this.filesToUpload);
    this.updateProgress(event, '<span class="status finished">Upload complete</span>');

    this.startUploadingNextFile($.proxy(this.redirect, this));
  },

  // Handles the error events from the uploader for an individual file
  uploadErrorHandler: function(event) {
    var fileJustFailed = this.fileFromEvent(event);
    fileJustFailed.removeFrom(this.filesToUpload);
    this.updateProgress(event, '<span class="status error">Error uploading (' + event.status + ')</span>');

    this.startUploadingNextFile($.proxy(function() {
      alert('Failed to upload the files you selected.  Please reselect and try again.');
      this.clearFileList();
    }, this));
  },

  clickToUploadEventHandler: function(event) {
    this.cancelButton.disable();
    this.disableButtons();
    this.startUploadingNextFile($.proxy(this.redirect, this));
  },

  clickToClearEventHandler: function(event) {
    this.clearFileList();
    this.disableButtons();
  },

  clickToCancelEventHandler: function(event) {
    window.location = this.cancelPath;
  },

  init: function() {
    this.filesToUpload = $.extend([], ArrayExtensions);
  },

  uploader: function(uploader) {
    var handler = this;
    this.uploader = uploader;
    $.each([ 
      'contentReady', 
      'fileSelect', 
      'uploadStart', 
      'uploadComplete', 
      'uploadCompleteData',
      'uploadError'
    ], function(index, event_name) {
      uploader.addListener(event_name, $.proxy(handler[ event_name + 'Handler' ], handler));
    });
  }
};

