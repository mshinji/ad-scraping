/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import 'bootstrap'
import '../src/application.scss'
import 'moment/locale/ja'
import 'tempusdominus-bootstrap-4'
import Clipboard from 'clipboard'
import 'jquery-ui'
import Rails from '@rails/ujs'

Rails.start()
require('channels')

$(window).on('load', function () {
  // 固有名詞置換ボタン機能
  $('.replace-btn').click(function () {
    var word

    if ($(this).hasClass('replace-user')) {
      word = '{@company_name}'
    } else if ($(this).hasClass('replace-user-product-name')) {
      word = '{@product_name}'
    } else if ($(this).hasClass('replace-user-product-asin')) {
      word = '{@product_asin}'
    } else if ($(this).hasClass('replace-reseller-name')) {
      word = '{@reseller_name}'
    } else if ($(this).hasClass('replace-deadline')) {
      word = '{@deadline}'
    } else if ($(this).hasClass('replace-quantity')) {
      word = '{@quantity}'
    } else if ($(this).hasClass('replace-sum')) {
      word = '{@sum}'
    } else if ($(this).hasClass('replace-date')) {
      var date = new Date()
      var year = date.getFullYear()
      var month = date.getMonth() + 1
      month = ('0' + month).slice(-2)
      var day = date.getDate()
      day = ('0' + day).slice(-2)
      word = year + '/' + month + '/' + day
    } else if ($(this).hasClass('replace-current-company')) {
      word = this.dataset.name
    }

    var id = this.dataset.textarea
    var textarea = document.getElementById(id)

    var sentence = textarea.value
    var len = sentence.length
    var pos = textarea.selectionStart
    var focusPos = pos + word.length

    var before = sentence.substr(0, pos)
    var after = sentence.substr(pos, len)

    sentence = before + word + after

    textarea.value = sentence
    textarea.focus()
    textarea.setSelectionRange(focusPos, focusPos)

    return false
  })

  // datetimepicker
  var format = 'YYYY/MM/DD'
  var picker = $('#deadline-datepicker')
  var date = moment(picker.val(), format).toDate()
  picker.datetimepicker({ format: format, date: null })
  picker.datetimepicker('date', date)

  // クリアボタン機能
  $('.btn-clear').on('click', function (e) {
    e.preventDefault()
    $(this)
      .parents('form')
      .find(
        'input[type="search"], input[type="text"], input[type="radio"], input[type="checkbox"], input[type="number"], select'
      )
      .val('')
      .removeAttr('checked')
      .removeAttr('selected')
  })

  // csv export datepicker
  var from = $('#fromcsv-datepicker')
  var to = $('#tocsv-datepicker')
  var fromDate = moment(from.val(), format).toDate()
  var toDate = moment(to.val(), format).toDate()
  to.datetimepicker({ format: format, date: null })
  to.datetimepicker('date', date)
  from.datetimepicker({ format: format, date: null })
  from.datetimepicker('date', date)

  $('#csv-export-button').click(function (e) {
    e.preventDefault

    var from = $('#fromcsv-datepicker')
    var to = $('#tocsv-datepicker')
    href =
      $(this).attr('href') + '?from_date=' + from.val() + '&to_date=' + to.val()
    $(this).attr('href', href)
    $(this)[0].click()
  })

  // クリップボード機能
  ;(function () {
    var clipboard = new Clipboard('.clipboard-btn')

    $('.clipboard-btn').tooltip({
      trigger: 'click',
      placement: 'top',
    })

    function setTooltip(btn, message) {
      $(btn)
        .tooltip('hide')
        .attr('data-original-title', message)
        .tooltip('show')
    }

    function hideTooltip(btn) {
      setTimeout(function () {
        $(btn).tooltip('hide')
      }, 1000)
    }

    clipboard.on('success', function (e) {
      setTooltip(e.trigger, 'Copied!')
      hideTooltip(e.trigger)
      $('#mail-template').blur()
    })

    clipboard.on('error', function (e) {
      setTooltip(e.trigger, 'Failed!')
      hideTooltip(e.trigger)
      $('#mail-template').blur()
    })
  })()

  // チェックボックス一括選択、解除
  $('#bulk-check').on('change', function () {
    $('.checkbox-input').prop('checked', $(this).prop('checked'))
  })

  // seller_idをparamsとして渡す
  $('#sellerId').change(function () {
    sellerId = this.value
    href = document.getElementById('resellerSearch').getAttribute('href')
    pos = href.indexOf('=')
    baseHref = href.substring(0, pos + 1)
    document.getElementById('resellerSearch').href = baseHref + sellerId
  })

  // スクレイピングボタン押下後、disabled
  // 画面をローディング中の画面に切り替え
  $('#scraping-button').on('click', function () {
    this.classList.add('disabled', 'loading')
  })

  // ブラックリストの背景色をプレビュー
  $('#bgColor').on('input', function () {
    var color = $(this).val()
    $('#previewReseller').css('background-color', color)
  })

  // セレクトボックスのメニュー表示・選択
  $('.dropdown').on('click', function () {
    var self = this
    $('.menu').toggleClass('showMenu')
    $('.menu > li').on('click', function () {
      $('.dropdown > p').html($(this).html())
      $('.menu').removeClass('showMenu')
      var id = this.dataset.id
      self.getElementsByClassName('bl_category_id')[0].value = id
    })
  })

  $(document).on('click', function (e) {
    if (
      !$(e.target).closest('.dropdown').length &&
      $('.menu').hasClass('showMenu')
    ) {
      $('.menu').removeClass('showMenu')
    }
  })

  if ($('#bl_category_id').val() != '') {
    var id = '#blCategory' + $('#bl_category_id').val()
    $('.dropdown > p').html($(id).html())
  }

  if (document.getElementsByClassName('bl_category_id').length > 0) {
    $('.modal-black-list .dropholder').each(function (i, ele) {
      var num = ele.getElementsByClassName('bl_category_id')[0].value
      if (num != '') {
        var className = '.blCategory' + num
        ele.getElementsByClassName('selectMenu')[0].innerHTML = $(
          className
        ).html()
      }
    })
  }

  // 権限を跨がるブラウザバックの制御
  var referrerPath = document.referrer
    .replace(/^[^:]+:\/\/[^/]+/, '')
    .replace(/#.*/, '')
  var currentPath = document.location.pathname

  if (
    ~referrerPath.indexOf('admin/company/index') &&
    currentPath.indexOf('/admin') == -1
  ) {
    history.pushState(null, null, null)
    $(window).on('popstate', function () {
      history.pushState(null, null, null)
      return alert('【管理者アカウント】よりお戻りください。')
    })
  }

  if (
    ~currentPath.indexOf('admin/company/index') &&
    referrerPath.indexOf('/admin') == -1
  ) {
    history.pushState(null, null, null)
    $(window).on('popstate', function () {
      history.pushState(null, null, null)
      return alert('別の権限のユーザに戻ることはできません。')
    })
  }

  // details_editの追加ボタンの制御
  $('#company_distributor_add_button').on('click', function () {
    var newForm = $('<input>', {
      type: 'text',
      name: 'company[distributor_ids][]',
      id: 'company_distributor_ids_',
      class: $('#company_distributor_ids_').attr('class'),
    })

    $('#company_distributor_add_button').before(newForm)
    $('#company_distributor_add_button').before('\n')
  })

  // sortable-tableの制御
  // 横幅が勝手に縮小されるバグの修正
  var fixPlaceHolderWidth = function (event, ui) {
    // adjust placeholder td width to original td width
    ui.children().each(function () {
      $(this).width($(this).width())
    })
    return ui
  }

  var saveSort = function (sort_data) {
    $.ajax({
      type: 'GET',
      url: '/products/sort',
      data: sort_data,
      async: true,
    })
  }

  // sortableイベントの設定
  $('#sortable-table').sortable({
    placeholder: 'ui-state-highlight',
    start: function (event, ui) {
      ui.placeholder.height(ui.helper.outerHeight())
    },
    update: function (event, ui) {
      saveSort($(this).sortable('serialize'))
    },
    helper: fixPlaceHolderWidth,
  })
})
