((factory) ->
  if typeof define === 'function' and define.amd
    define(['jquery', 'moment']), factory)
  else
    if !jQuery
      throw 'bootstrap-datetimepicker requires jQuery to be loaded first'
    else if !moment
      throw 'bootstra-pdatetimepicker requires moment.js to be loaded first'
    else
      factor(jQuery, moment)
)(($, moment) ->
  if typeof moment === 'undefined'
    alert 'moment.js is required'
    throw new Error 'moment.js is required'

  pickerId = 0
  
  class DateTimePicker
    defaults:
      pickDate: true,
      pickTime: true,
      use24hours: false,
      startDate: new Moment { y: 1970 }
      endDate: (new Moment).add(50, 'y')
      collapse: true
      language: 'en'
      defaultDate: ''
      disabledDates: []
      enabledDates: false
      icons: {}
      useStrict: false

    icons:
      time: 'glyphicon glyphicon-time'
      date: 'glyphicon glyphicon-calendar'
      up: 'glyphicon glyphicon-chevron-up'
      down: 'glyphicon glyphicon-chevron-down'

    constructor: (element, options) ->
      @options = $.extend({}, @defaults, options)
      @options.icons = $.extend({}, @icons, @options.icons)

      if !picker.options.pickTime and !picker.options.pickDate
        throw new Error 'Must choose at least one picker.'

      @id = pickerId++
      Moment.lang(@options.language)
      @date = Moment()
      @element = $(element)
      @unset = false
      @isInput = @element.is('input')
      @component = false

      initFormat()
      initComponent()
      initViewMode()
      initDateBounds()

      @startViewMode = @viewMode
      setStartDate(@options.startDate || @element.data('data-startdate'))
      setEndDate(@options.endDate || @element.data('data-enddate'))
      fillDow()
      fillMonths()
      fillHours()
      fillMinutes()
      update()
      showMode()
      attachDatePickerEvents()
      if @options.defaultDate !== ''
        setValue(@options.defaultDate)

    initFormat: ->
      @format = @options.format
      longDateFormat = Moment()._lang._longDateFormat
      if !@format
        if @isInput
          @format = @element.data('format')
        else
          @format = @element.find('input').data('format')

        if !@format
          @format = if @options.pickDate then longDateFormat.L else ''
          if @options.pickDate and @options.pickTime
            @format += ' '
          @format += (if @options.pickTime then longDateFormat.LT else '')

      ampmIndex = @format.toLowerCase().indexOf('a')
      if @options.use24hours and ampmIndex >= 1
        @format = @format.substring(0, ampmIndex) + @format.substring(ampmIndex + 1, @format.length)

      @use24hours = @format.toLowerCase().indexOf('a') < 1

    initComponent: ->
      if @element.hasClass('input-group')
        if @element.find('.datepickerbutton').size() == 0
          @component = @element.find("[class^='input-group-']")
        else
          @component = @element.find('.datepickerbutton')

      icon = null
      if @component {
        icon = @component.find('span')

      if @options.pickTime
        if icon

