import { application } from "controllers/application"

import ImportTabController     from "controllers/import_tab_controller"
import ReadingStatusController from "controllers/reading_status_controller"
import ModelSelectorController from "controllers/model_selector_controller"
import SummaryStatusController from "controllers/summary_status_controller"
import LatexEditorController   from "controllers/latex_editor_controller"
import TagDotController        from "controllers/tag_dot_controller"
import DetailPanelController   from "controllers/detail_panel_controller"
import MobileNavController      from "controllers/mobile_nav_controller"
import SettingsToggleController from "controllers/settings_toggle_controller"
import DoiLookupController      from "controllers/doi_lookup_controller"
import PdfViewerController      from "controllers/pdf_viewer_controller"

application.register("import-tab",     ImportTabController)
application.register("reading-status", ReadingStatusController)
application.register("model-selector", ModelSelectorController)
application.register("summary-status", SummaryStatusController)
application.register("latex-editor",   LatexEditorController)
application.register("tag-dot",        TagDotController)
application.register("detail-panel",   DetailPanelController)
application.register("mobile-nav",      MobileNavController)
application.register("settings-toggle", SettingsToggleController)
application.register("doi-lookup",      DoiLookupController)
application.register("pdf-viewer",      PdfViewerController)
