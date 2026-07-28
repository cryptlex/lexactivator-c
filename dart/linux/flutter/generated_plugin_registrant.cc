//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <lexactivator/lexactivator_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) lexactivator_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "LexactivatorPlugin");
  lexactivator_plugin_register_with_registrar(lexactivator_registrar);
}
