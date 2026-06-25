#!/usr/bin/env ruby
# Adiciona o target de Widget Extension "GameNetWidget" ao projeto GameNet.
# Idempotente: se o target já existir, não duplica.

require "xcodeproj"

PROJECT_PATH = File.expand_path(File.join(__dir__, "..", "GameNet.xcodeproj"))
WIDGET_NAME = "GameNetWidget"
APP_TARGET_NAME = "GameNet"
BUNDLE_ID = "com.alliston.GameNetApp.Widget"
TEAM = "56JG4Q8S7U"
DEPLOYMENT_TARGET = "26.0"

project = Xcodeproj::Project.open(PROJECT_PATH)

app_target = project.targets.find { |t| t.name == APP_TARGET_NAME }
raise "App target '#{APP_TARGET_NAME}' não encontrado" unless app_target

if project.targets.any? { |t| t.name == WIDGET_NAME }
  puts "Target '#{WIDGET_NAME}' já existe. Nada a fazer."
  exit 0
end

widget_target = project.new_target(
  :app_extension,
  WIDGET_NAME,
  :ios,
  DEPLOYMENT_TARGET,
  nil,
  :swift
)

# Grupo do widget no navegador
widget_group = project.main_group.find_subpath(WIDGET_NAME, true)
widget_group.set_path(WIDGET_NAME)

widget_sources = %w[
  PlayGameWidget.swift
  PlayGameProvider.swift
  ToggleGameplayIntent.swift
  WidgetGameClient.swift
]

widget_sources.each do |file|
  ref = widget_group.new_file(file)
  widget_target.add_file_references([ref])
end

# Arquivo compartilhado: pertence ao app E ao widget
shared_store_path = "GameNet/Shared/Widget/WidgetSharedStore.swift"
shared_app_path = "GameNet/Shared/Widget/WidgetSharedStore+App.swift"

shared_group = project.main_group.find_subpath("GameNet/Shared/Widget", true)

shared_store_ref = project.files.find { |f| f.real_path.to_s.end_with?(shared_store_path) }
shared_store_ref ||= shared_group.new_file(File.expand_path(File.join(__dir__, "..", shared_store_path)))

shared_app_ref = project.files.find { |f| f.real_path.to_s.end_with?(shared_app_path) }
shared_app_ref ||= shared_group.new_file(File.expand_path(File.join(__dir__, "..", shared_app_path)))

# Shared store -> ambos os targets
widget_target.add_file_references([shared_store_ref])
unless app_target.source_build_phase.files_references.include?(shared_store_ref)
  app_target.add_file_references([shared_store_ref])
end
# Bridge -> apenas app
unless app_target.source_build_phase.files_references.include?(shared_app_ref)
  app_target.add_file_references([shared_app_ref])
end

# Build settings do widget
widget_target.build_configurations.each do |config|
  settings = config.build_settings
  settings["PRODUCT_BUNDLE_IDENTIFIER"] = BUNDLE_ID
  settings["PRODUCT_NAME"] = "$(TARGET_NAME)"
  settings["INFOPLIST_FILE"] = "#{WIDGET_NAME}/Info.plist"
  settings["GENERATE_INFOPLIST_FILE"] = "NO"
  settings["CODE_SIGN_ENTITLEMENTS"] = "#{WIDGET_NAME}/#{WIDGET_NAME}.entitlements"
  settings["CODE_SIGN_STYLE"] = "Automatic"
  settings["DEVELOPMENT_TEAM"] = TEAM
  settings["IPHONEOS_DEPLOYMENT_TARGET"] = DEPLOYMENT_TARGET
  settings["SWIFT_VERSION"] = "5.0"
  settings["SWIFT_EMIT_LOC_STRINGS"] = "YES"
  settings["ENABLE_PREVIEWS"] = "YES"
  settings["TARGETED_DEVICE_FAMILY"] = "1,2"
  settings["MARKETING_VERSION"] = "1.0"
  settings["CURRENT_PROJECT_VERSION"] = "1"
  settings["SKIP_INSTALL"] = "YES"
  settings["LD_RUNPATH_SEARCH_PATHS"] = [
    "$(inherited)",
    "@executable_path/Frameworks",
    "@executable_path/../../Frameworks"
  ]
  settings["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = config.name == "Debug" ? "DEBUG" : ""
end

# Dependência + embed no app
app_target.add_dependency(widget_target)

embed_phase = app_target.copy_files_build_phases.find do |phase|
  phase.symbol_dst_subfolder_spec == :plug_ins
end

embed_phase ||= begin
  phase = app_target.new_copy_files_build_phase("Embed Foundation Extensions")
  phase.symbol_dst_subfolder_spec = :plug_ins
  phase
end

unless embed_phase.files_references.include?(widget_target.product_reference)
  build_file = embed_phase.add_file_reference(widget_target.product_reference)
  build_file.settings = { "ATTRIBUTES" => ["RemoveHeadersOnCopy"] }
end

# Provisioning automático
attributes = project.root_object.attributes["TargetAttributes"] ||= {}
attributes[widget_target.uuid] = {
  "CreatedOnToolsVersion" => "26.0",
  "ProvisioningStyle" => "Automatic"
}

project.save
puts "Target '#{WIDGET_NAME}' adicionado com sucesso."
