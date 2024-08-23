// app/javascript/application.js
import { Application } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js";
import { SelectOptionController } from "./controllers/select_option_controller.js";
import { CheckboxOptionController } from "./controllers/checkbox_option_controller.js";

const application = Application.start();
application.register("select-option", SelectOptionController);
application.register("checkbox-option", CheckboxOptionController);
