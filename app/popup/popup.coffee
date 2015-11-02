require "angular"
require "angular-resource"
_ = require "lodash"

storage = chrome.storage.local
angular.module "Popup", ["ngResource"]

.config ["$httpProvider", ($httpProvider) ->
  $httpProvider.defaults.useXDomain = on
  delete $httpProvider.defaults.headers.common['X-Requested-With']
]

.controller "Popup", ["$scope", "$resource", ($scope, $resource) ->
  $ = $scope
  _.extend $,
    parsed: []
    patterns: {}

    parse: ->
      chrome.tabs.query active: on, currentWindow: on, (tabs) ->
        chrome.tabs.sendMessage tabs[0].id, JSON.parse($.parse_config), (res) ->
          $.$apply -> $.parsed = res

    save_pattern: ->
      return alert "Не указано имя!" unless $.pattern_name
      index = _.findIndex $.patterns, (item) -> item.name is $.pattern_name
      if -1 < index
        $.patterns[index].value = $.parse_config
      else
        $.patterns.push
          name: $.pattern_name
          value: $.parse_config

      do save_patterns

    set_pattern: ->
      $.parse_config = $.all_patterns.value
      $.pattern_name = $.all_patterns.name

    remove_pattern: ->
      return unless confirm "Удалить запись?"
      index = _.indexOf $.patterns, $.all_patterns
      return unless -1 < index
      $.patterns.splice index, 1
      do save_patterns

    remove: (i) -> $.parsed.splice i, 1

    load: ->
      save_storage "host", $.host
      return alert "Не укзан каталог" unless ($.catalog and $.catalog.id)
      return alert "Введите пароль" unless $.password
      save_storage "password", $.password

      _.each $.parsed, (item) ->
        (new Product _.extend {}, item, {parent: $.catalog.id, password: $.password})
        .$save().then ->
          $.parsed.splice (_.indexOf item), 1

  save_storage = (k, v) -> storage.set "#{k}": v
  save_patterns = -> save_storage "patterns", $.patterns

  Catalog = Product = null
  storage.get "patterns", (items) -> $.$apply -> $.patterns = items.patterns or []
  storage.get "password", (v) -> $.$apply -> $.password = v.password
  storage.get "host", (v) -> $.$apply ->
    $.host = v.host
    Catalog = $resource "#{$.host}/api/catalog/catalog/:id", null, null, stripTrailingSlashes: off
    Product = $resource "#{$.host}/api/catalog/product/", null, null, stripTrailingSlashes: off
    $.catalogs = Catalog.query()

]

.filter "save", ["$sce", ($sce) -> (v) -> $sce.trustAsHtml v]

.filter "catalog_tree", -> _.memoize (catalogs) ->
  tree = []
  add_tree = (cats, l = 0) ->
    return unless cats.length
    _.each cats, (cat) ->
      cat.title = "#{_.repeat "-", l} #{cat.title}".trim()
      tree.push cat
      add_tree (_.where catalogs, parent: cat.id), l + 1

  add_tree _.where catalogs, parent: null
  tree
