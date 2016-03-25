((window, $, templates) ->

  diskFormContainer = $ '#dashboard-diskspace-panel'
  section = diskFormContainer.parents '.o-collapsible-section'
  diskForm = diskFormContainer.find 'form'
  url = diskForm.attr 'action'
  stateUrl = diskForm.data 'state-url'
  currentId = diskForm.data 'started'
  errorMessage = templates.diskspaceConsolidateSubmitError
  diskField = null


  addDiskField = () ->
    # AJAX submission cannot submit different values based on what submit
    # button is clicked. We would work around this by submitting to an iframe,
    # but that doesn't sounds so good. Instead, we will add a hidden field that
    # will hold the value we want to submit.
    field = $ '<input type="hidden" name="disk_id">'
    (diskFormContainer.find 'form').append field
    return field


  updateForm = (markup) ->
    diskFormContainer.html markup
    diskForm = diskFormContainer.find 'form'
    diskField = addDiskField()
    section.trigger 'remax'
    return


  reloadForm = () ->
    res = $.get url
    res.done updateForm


  setIcon = (button, name) ->
    (button.find '.icon').remove()
    button.prepend "<span class=\"icon icon-#{name}\"></span>"


  markDone = (diskId) ->
    button = diskFormContainer.find '#' + diskId
    setIcon button, 'ok'
    button.addClass 'diskspace-consolidation-started'
    setTimeout () ->
      reloadForm()
    , 6000


  pollState = (diskField) ->
    setTimeout () ->
      res = $.get stateUrl
      res.done (data) ->
        if data.state?
          reloadForm()
          pollState diskField
          return
        markDone diskField
        return
    , 2000


  submitData = (e) ->
    e.preventDefault()
    res = $.post url, diskForm.serialize()
    diskId = diskField.val()
    res.done (data) ->
      updateForm data
      if (diskFormContainer.find '.o-form-errors').length
        return
      pollState diskField
      return
    res.fail () ->
      diskFormContainer.prepend errorMessage
      return
    return


  handleButton = (e) ->
    el = $ e.target
    diskId = el.attr 'value'
    diskField.val diskId
    return

  diskField = addDiskField()
  diskFormContainer.on 'click', 'button', handleButton
  diskFormContainer.on 'submit', 'form', submitData

  if currentId
    # Cick off the spinner immediately
    pollState currentId


) this, this.jQuery, this.templates
