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
#
module Storages::Common
  module ConfigurationChecks
    extend ActiveSupport::Concern

    included do
      scope :configured, -> do
        where.associated(:oauth_client, :oauth_application)
             .where("storages.host IS NOT NULL AND storages.name IS NOT NULL")
      end
    end

    def configured?
      configuration_checks.values.all?
    end

    def configuration_checks
      { storage_oauth_client_configured: oauth_client.present? }.tap do |configuration_checks|
        if provider_type_nextcloud?
          configuration_checks.merge!({ openproject_oauth_application_configured: oauth_application.present?,
                                        host_name_configured: (host.present? && name.present?) })
        end
      end
    end
  end
end