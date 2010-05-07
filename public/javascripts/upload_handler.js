// Class to hold the file upload information.
var FileToUpload = function(id, name) {
  object = {
    removeFrom: function(arr) { arr.remove(this); }
  };
  object.id   = id;
  object.name = name;
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
  isEmpty: function() { return this.length == 0; }
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
  filenameFromEvent:      function(event)                 { return $.grep(this.filesToUpload, function(v) { return v.id == event.id; })[ 0 ].name; },
  updateProgress:         function(message, step)         { this.progressElement.row(message, step); },

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

  // Handles the YUI Uploader informing us that it is ready to do some work.
  contentReadyHandler: function() {
    this.uploader.setAllowLogging(true); 
    this.uploader.setAllowMultipleFiles(true);
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
    $.each(event.fileList, function(file, information) { 
      var fileInfo = FileToUpload(information.id, information.name);
      filesToUpload.push(fileInfo);
      fileList.row('<span class="filename">' + fileInfo.name + '</span> (<a href="#" class="file_to_upload">Remove</a>)');
      $('a', fileList.lastChild()).click(removeHandlerFor(fileInfo));
    });
    this.updateButtonState();
  },

  // Handles the start of uploading an individual file.
  uploadStartHandler: function(event) {
    this.updateProgess('Uploading <span class="filename">' + this.filenameFromEvent(event) + '</span> ...', 'intermediate');
  },

  // Handles the completion of uploading an individual file.
  uploadCompleteHandler: function(event) {
    this.updateProgress('Completed upload of <span class="filename">' + this.filenameFromEvent(event) + '</span>', 'intermediate');
  },

  // Handles the completion of a response from the server for an individual file
  uploadCompleteDataHandler: function(event) {
    this.filesToUpload.pop();  // TODO[md12]: We don't really care but maybe an error could occur!
    if (this.filesToUpload.isEmpty()) {
      this.updateProgress('Completed bulk upload, redirecting to batch view ...', 'finished');
      window.location = this.finishPath.replacement(this.batchId());
    }
  },

  // TODO[md12]: uploadErrorHandler needed
  // TODO[md12]: uploadProgressHandler needed

  clickToUploadEventHandler: function(event) {
    this.cancelButton.disable();
    $.each(this.filesToUpload, $.proxy(function(index, file) {
      this.uploader.upload(file.id, this.uploadPath.replacement('' + index), 'POST', { '_method': 'put' }, 'data');
    }, this));
    this.disableButtons();
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
    $.each([ 'contentReady', 'fileSelect', 'uploadComplete', 'uploadStart', 'uploadCompleteData' ], function(index, event_name) {
      uploader.addListener(event_name, $.proxy(handler[ event_name + 'Handler' ], handler));
    });
  }
};

