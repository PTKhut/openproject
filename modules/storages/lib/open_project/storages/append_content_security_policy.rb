#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2022 the OpenProject GmbH
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
class ::OpenProject::Storages::AppendContentSecurityPolicy < OpenProject::Hook::Listener
  # OpenProject's front-end needs to allow the browser to connect to external file servers for direct file uploads.
  # Therefore it needs to extend its content security policy (CSP) `connect-src` by the hostnames of all servers that
  # the current user is allowed to upload files. That is the case for all storages that activated in at least one active
  # project in which the user is member and has the permission to `manage_file_links`.
  # The allowed values can be different for every user and can change every time a store gets activated, removed, a role
  # changes, or even project memberships. Caching it, without accessing the DB seems to be pretty impossible. So we
  # decided to not do it for now.
  # We extend the CSP for all HTML requests as work packages can pop in many places of OpenProject, and we want to be
  # able to upload in all those places (work packages module, BCF module, notification center, boards, ...).
  def application_controller_before_action(context)
    projects_of_user = Project.allowed_to(User.current, :manage_file_links).select(:id)
    projects_with_permission = ::Storages::ProjectStorage.where(project_id: projects_of_user)
                                                         .select(:storage_id)
    hosts = ::Storages::Storage.where(id: projects_with_permission)
                               .pluck(:host)

    # secure_headers gem provides this helper method to append to the current content security policy
    controller = context[:controller]
    controller.append_content_security_policy_directives({ connect_src: hosts })
  end
end
