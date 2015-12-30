{View, $, $$} = require 'atom-space-pen-views'
Path = require 'path'

module.exports =

class MeteorAssistSelectListView extends View

  @content: ->
    @div class:'ma-tree-view-wrapper', =>
      @div class:'ma-tree-view-header', =>
        @div class:'btn-group', =>
          @button class:'btn icon icon-database', 'data-type':'GROUP', click:'onAddItemButtonClicked'
          @button class:'btn icon icon-file-directory', 'data-type':'FOLDER',click:'onAddItemButtonClicked'
          @button class:'btn icon icon-file-code', 'data-type':'FILE',click:'onAddItemButtonClicked'
      @div class:'select-list block', =>
        @ol class:'list-group', outlet:'list', =>

  # Public: Initialize the View
  #
  # Returns the [Description] as `undefined`.
  initialize: ->
    # Subscribe to the event on the action buttons on the item
    @list.on 'click', 'li .action-buttons span', @onListItemActionsButtonClicked

    @list.on 'dblclick', 'li span.item-title', @startEditingTitle
    @list.on 'keydown', 'li .item-title-editor', @confirmTitleEdit
    @list.on 'blur', 'li .item-title-editor', @cancelEditingTitle

    # Subscribe to the event when the item is clicked
    @list.on 'click', 'li', @onListItemClicked

    # Subscribe to the event when the item is clicked
    @list.on 'click', 'li span.dropdown-icon', ( e ) =>
      li = $(e.target).closest('li')
      list = li.children('ol.list-group')
      own = $(e.target)
      if own.hasClass('icon-chevron-down')
        list.slideUp(200)
        own.removeClass('icon-chevron-down').addClass('icon-chevron-right')
      else
        list.slideDown(200)
        own.removeClass('icon-chevron-right').addClass('icon-chevron-down')


  # startEditingTitle: Start Editing the title
  #
  # * `e ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  startEditingTitle: ( e ) =>
    spanTitle = $(e.target)
    editorTitle = spanTitle.next()
    editorTitle[0].getModel().setText(spanTitle.html())
    spanTitle.hide()
    editorTitle.show()
    editorTitle.focus()


  # startEditingTitle: Item Title Editing
  #
  # * `e ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  confirmTitleEdit: ( e ) =>
    editorTitle = $(e.target)
    spanTitle = editorTitle.prev()
    li = spanTitle.closest('li')
    type = li.data('type')
    newText = editorTitle[0].getModel().getText()

    if e.which == 13
      isEmptyString = newText == ""
      isFileName = not isEmptyString and ( Path.extname(newText) != "" and Path.extname(newText) != "." )
      sFindString = 'li[data-name="' + newText + '"]'
      bNameExists = li.parent().children(sFindString).length > 0

      if isEmptyString
        atom.notifications.addWarning('Name Cannot be empty')
        editorTitle.blur()

      if bNameExists
        atom.notifications.addWarning('The Name that you are trying to give already exists, please use another one ...')
        editorTitle.blur()

      if type == "FILE" and not isFileName
        atom.notifications.addWarning('File Name should have Extension')
        editorTitle.blur()

      if not isEmptyString and not bNameExists
        spanTitle.html(newText)
        li.attr('data-name', newText)
        editorTitle.hide()
        spanTitle.fadeIn(400)

  # cancelEditingTitle: Stop Title Editing
  #
  # * `e ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  cancelEditingTitle: ( e ) =>
    editorTitle = $(e.target)
    spanTitle = editorTitle.prev()

    editorTitle.hide()
    spanTitle.show()

  # onAddItemButtonClicked: Event Handler for the buttons
  #
  # * `e ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  onAddItemButtonClicked: ( e ) ->
    srcElement = $(e.target)
    type = srcElement.data('type')
    sName = "#{type} #{@list.children().length}"
    sName = "#{sName}.ext" if type == "FILE"

    @addItem {
      'type': type
      'name': sName
      'content': if type == "FILE" then "" else undefined
    }

  # onListItemButtonClicked: Event Handler for the actions buttons on the list item
  #
  # * `e ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  onListItemActionsButtonClicked: ( e ) =>
    if $(e.target).hasClass('icon-remove-close')
      # If the clicked button has remove class then remove the current item from the list
      @removeItem( $(e.target).closest('li') )
    else
      # Get the 'li' element
      listItem = $(e.target).closest('li')
      list = listItem.children('ol.list-group')
      type = $(e.target).data('type')
      sName = "#{type} #{list.children().length}"
      sName = "#{sName}.ext" if type == "FILE"

      @addItem {
        'type':type
        'name': sName
        'content': if type == "FILE" then "" else undefined
        }, list

    e.preventDefault()
    false

  # onListItemClicked: handler to list the list item when clicked
  #
  # * `e ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  onListItemClicked: ( e ) =>
    listItem = if not $(e.target).is('li') then $(e.target).closest('li') else $(e.target)
    @selectListItemView( listItem )

  # viewForItem: Generate the DOM based on the given item
  #
  # * `item ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  viewForItem: ( item ) ->
    sContent = item.content or ""

    $$ ->
      @li 'data-type':item.type, 'data-name': item.name, =>
        @span class:'icon icon-chevron-right dropdown-icon' if item.type == "GROUP" || item.type == "FOLDER"
        @div class:'editable-label inline-block', =>
          @span item.name, class:'item-title inline-block'
          @tag 'atom-text-editor', class:'item-title-editor inline-block', style:'display: none; width: 100%;', mini:true
        @div class:'pull-right action-buttons', =>
          if item.type == "GROUP" || item.type == "FOLDER"
            @span class:'icon icon-database text-highlight', 'data-type':'GROUP' if item.type == "GROUP" || item.type == "FOLDER"
            @span class:'icon icon-file-directory text-highlight', 'data-type':'FOLDER' if item.type == "GROUP" || item.type == "FOLDER"
            @span class:'icon icon-file-code text-highlight', 'data-type':'FILE' if item.type == "GROUP" || item.type == "FOLDER"
          @span class:'icon icon-remove-close text-highlight'
        @ol class:'list-group', style:'display: none;' if item.type == "GROUP" || item.type == "FOLDER"


  # addItem: This creates the DOM element and appends it to the list
  #
  # * `item ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  addItem: ( item, parent ) ->
    itemView = $(@viewForItem(item))
    itemView.data('item-list-data', item)

    if parent?
      parent.append itemView
    else
      @list.append itemView

    itemView

  # removeItem: Remove the selected item from the list
  #
  # * `item` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  removeItem: (item) ->
    # If the item to be remvoed is selected the change the selection
    if item.hasClass('selected')
      @selectNextOrPrev( item )

    item.remove()

  # selectNextOrPrev: Check if the prev or next item can be selected, and if yes then select it
  #
  # * `currSel ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  selectNextOrPrev: ( currSel ) ->
    next = currSel.next()
    prev = currSel.prev()

    if next.length > 0
      @selectListItemView next
    else if prev.length > 0
      @selectListItemView prev
    else
      @selectListItemView null

  # selectListItemView: Select the given Item
  #
  # * `view ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  selectListItemView: ( view ) ->
    unless view?
      # Emitt Selection changed event
      @trigger 'selection-changed', null
    else
      unless view.hasClass('selected')
        @list.find('.selected').removeClass('selected')
        view.addClass('selected')
        @trigger 'selection-changed', view

  # populateItems: Populate the list with the items
  #
  # * `items ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  populateItems: ( json ) ->
    self = @
    @list.empty()
    iterateOver = ( obj, parent ) ->
      for key of obj
        val = obj[key]
        if (typeof val) == 'object'
          li = self.addItem {
            'name': key
            'type': val.type
            'content': val.content if val.content?
          }, parent
          iterateOver val, ($(li).children('ol.list-group'))

    iterateOver json, @list

  # deSerializeList: Deserialize the list to a JSON object
  #
  # * `json ` The [description] as {[type]}.
  #
  # Returns the [Description] as `undefined`.
  deSerializeList: ( json ) ->
    if json.length > 0
      self = @
      @list.empty()
      parseNodes = ( nodes, parent ) ->
        for i in [0..(nodes.length-1)]
          node = nodes[i]
          li = self.addItem(node, parent)
          if node.items != undefined and node.items.length > 0
            parseNodes(node.items, li.children('ol.list-group') )

      parseNodes( json, @list)

  # serializeList: Serialize the json object into list
  #
  # Returns the [Description] as `undefined`.
  serializeList: ->
    serializeObject = {}

    processListItem = ( node, parent ) ->
      type = node.attr('data-type')
      sContent = node.data('item-list-data').content
      sName = node.find('.editable-label span.item-title').html()
      parent[sName] = { }
      parent[sName].type = type

      if sContent != ""
        parent[sName].content = sContent

      $(node).find( '> ol.list-group > li').each ( ) ->
        processListItem($(@), parent[sName] )

    @list.children('li').each ( ) ->
      processListItem($(@), serializeObject)

    serializeObject
