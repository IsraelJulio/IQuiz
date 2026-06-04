import { application } from "controllers/application"

import ThemeController    from "controllers/theme_controller"
import CardController     from "controllers/card_controller"
import ConfettiController from "controllers/confetti_controller"
import FlashController    from "controllers/flash_controller"

application.register("theme",    ThemeController)
application.register("card",     CardController)
application.register("confetti", ConfettiController)
application.register("flash",    FlashController)
