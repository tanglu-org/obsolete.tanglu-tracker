require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_multiprojects_issue/hooks'
  require_dependency 'redmine_multiprojects_issue/issue_patch'
  require_dependency 'redmine_multiprojects_issue/issues_helper_patch'
  require_dependency 'redmine_multiprojects_issue/issues_controller_patch'
  require_dependency 'redmine_multiprojects_issue/query_patch'
end

Redmine::Plugin.register :redmine_multiprojects_issue do
  name 'Redmine Multiple Projects per Issue plugin'
  author 'Vincent ROBERT'
  description 'This plugin for Redmine allows more than one project per issue.'
  version '0.1'
  url 'https://github.com/nanego/redmine_multiprojects_issue'
  author_url 'mailto:contact@vincent-robert.com'
  requires_redmine_plugin :redmine_base_select2, :version_or_higher => '0.0.1'
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
  settings :default => { 'custom_fields' => []},
           :partial => 'settings/redmine_plugin_multiprojects_issue_settings'
end
