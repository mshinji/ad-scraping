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

import "bootstrap";
import "../stylesheets/application.scss";
import "moment/locale/ja";
import Clipboard from "clipboard";
import "jquery-ui";
import Rails from "@rails/ujs";

Rails.start();
require("channels");

$(window).on("load", function () {
  // クリアボタン機能
  $(".btn-clear").on("click", function (e) {
    e.preventDefault();
    $(this)
      .parents("form")
      .find(
        'input[type="search"], input[type="text"], input[type="radio"], input[type="checkbox"], input[type="number"], select'
      )
      .val("")
      .removeAttr("checked")
      .removeAttr("selected");
  });

  // チェックボックス一括選択、解除
  $("#bulk-check").on("change", function () {
    $(".checkbox-input").prop("checked", $(this).prop("checked"));
  });

  // スクレイピングボタン押下後、disabled
  // 画面をローディング中の画面に切り替え
  $(".scraping-button").on("click", function () {
    $(this).addClass("disabled loading");
    let ele =
      '<div class="alert alert-success scraping-alert-top">【 ' +
      $(this).data("name") +
      "】のスクレイピングを開始しました。</div>";
    $("body").prepend(ele);
    $(".scraping-alert-top").slideDown();
    setTimeout(() => {
      $(".scraping-alert-top").slideUp();
    }, 2000);
  });

  // セレクトボックスのメニュー表示・選択
  $(".dropdown").on("click", function () {
    var self = this;
    $(".menu").toggleClass("showMenu");
    $(".menu > li").on("click", function () {
      $(".dropdown > p").html($(this).html());
      $(".menu").removeClass("showMenu");
      var id = this.dataset.id;
      self.getElementsByClassName("bl_category_id")[0].value = id;
    });
  });

  $(document).on("click", function (e) {
    if (
      !$(e.target).closest(".dropdown").length &&
      $(".menu").hasClass("showMenu")
    ) {
      $(".menu").removeClass("showMenu");
    }
  });

  // 権限を跨がるブラウザバックの制御
  var referrerPath = document.referrer
    .replace(/^[^:]+:\/\/[^/]+/, "")
    .replace(/#.*/, "");
  var currentPath = document.location.pathname;

  if (
    ~referrerPath.indexOf("admin/company/index") &&
    currentPath.indexOf("/admin") == -1
  ) {
    history.pushState(null, null, null);
    $(window).on("popstate", function () {
      history.pushState(null, null, null);
      return alert("【管理者アカウント】よりお戻りください。");
    });
  }

  if (
    ~currentPath.indexOf("admin/company/index") &&
    referrerPath.indexOf("/admin") == -1
  ) {
    history.pushState(null, null, null);
    $(window).on("popstate", function () {
      history.pushState(null, null, null);
      return alert("別の権限のユーザに戻ることはできません。");
    });
  }

  // details_editの追加ボタンの制御
  $("#company_distributor_add_button").on("click", function () {
    var newForm = $("<input>", {
      type: "text",
      name: "company[distributor_ids][]",
      id: "company_distributor_ids_",
      class: $("#company_distributor_ids_").attr("class"),
    });

    $("#company_distributor_add_button").before(newForm);
    $("#company_distributor_add_button").before("\n");
  });

  // sortable-tableの制御
  // 横幅が勝手に縮小されるバグの修正
  var fixPlaceHolderWidth = function (event, ui) {
    // adjust placeholder td width to original td width
    ui.children().each(function () {
      $(this).width($(this).width());
    });
    return ui;
  };

  var saveSort = function (sort_data) {
    $.ajax({
      type: "GET",
      url: "/products/sort",
      data: sort_data,
      async: true,
    });
  };

  // sortableイベントの設定
  $("#sortable-table").sortable({
    placeholder: "ui-state-highlight",
    start: function (event, ui) {
      ui.placeholder.height(ui.helper.outerHeight());
    },
    update: function (event, ui) {
      saveSort($(this).sortable("serialize"));
    },
    helper: fixPlaceHolderWidth,
  });
});
