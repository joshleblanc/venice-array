// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import Clipboard from '@stimulus-components/clipboard'

eagerLoadControllersFrom("controllers", application)
application.register('clipboard', Clipboard)

