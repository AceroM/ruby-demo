# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/src", under: "src", to: "src"
pin "imask", to: "https://ga.jspm.io/npm:imask@7.3.0/esm/index.js"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.9/src/index.js"
pin "@floating-ui/dom", to: "https://ga.jspm.io/npm:@floating-ui/dom@1.5.3/dist/floating-ui.dom.mjs"
pin "@floating-ui/core", to: "https://ga.jspm.io/npm:@floating-ui/core@1.5.0/dist/floating-ui.core.mjs"
pin "@floating-ui/utils", to: "https://ga.jspm.io/npm:@floating-ui/utils@0.1.4/dist/floating-ui.utils.mjs"
pin "@floating-ui/utils/dom", to: "https://ga.jspm.io/npm:@floating-ui/utils@0.1.4/dom/dist/floating-ui.utils.dom.mjs"
