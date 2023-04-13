#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2023 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

# Purpose: Defines the row model for the table of Storage objects
# Used by: Storages table in table_component.rb
module Storages::Admin
  class RowComponent < ::RowComponent
    include ::IconsHelper # Global helper for icons, defines op_icon and icon_wrapper?
    include ::AvatarHelper # Global helper for avatar (image of a user)
    include ::Redmine::I18n # Internationalization support (defines I18n.t(...) translation)
    include ::ApplicationHelper # For `accesskey` method

    def storage
      row
    end

    delegate :created_at, to: :storage

    def name
      link_to storage.name, admin_settings_storage_path(storage)
    end

    # Delegate delegates the execution of certain methods to :storage.
    # https://www.rubydoc.info/gems/activesupport/Module:delegate
    delegate :host, to: :storage
    delegate :provider_type, to: :storage

    def creator
      icon = avatar storage.creator, size: :mini
      icon + storage.creator.name
    end

    def button_links
      [edit_link, delete_link]
    end

    def delete_link
      link_to '',
              admin_settings_storage_path(storage),
              class: 'icon icon-delete',
              data: { confirm: I18n.t('storages.delete_warning.storage') },
              title: I18n.t(:button_delete),
              method: :delete
    end

    def edit_link
      link_to '',
              edit_admin_settings_storage_path(storage),
              class: 'icon icon-edit',
              accesskey: accesskey(:edit),
              title: I18n.t(:button_edit)
    end
  end
end