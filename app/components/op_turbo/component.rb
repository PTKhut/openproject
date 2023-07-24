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

module OpTurbo
  class Component < ApplicationComponent
    def self.wrapper_key
      self.name.underscore.gsub("/", "-").gsub("_", "-")
    end

    def render_as_turbo_stream(view_context:, action: :update)
      OpTurbo::StreamWrapperComponent.new(
        action: action, 
        target: self.wrapper_key, 
        template: action == :remove ? nil : self.render_in(view_context)
      ).render_in(view_context)
    end

    def insert_as_turbo_stream(component:, view_context:, action: :append)
      OpTurbo::StreamWrapperComponent.new(
        action: action, 
        target: insert_target_modified? ? insert_target_modifier_id : self.wrapper_key, 
        template: component.render_in(view_context)
      ).render_in(view_context)
    end

    def component_wrapper(tag: "div", class: nil, data: nil, style: nil, &block)
      content_tag(tag, id: wrapper_key, class:, data:, style:, &block)
    end

    def wrapper_key
      if wrapper_uniq_by.nil?
        self.class.wrapper_key
      else
        "#{self.class.wrapper_key}-#{wrapper_uniq_by}"
      end
    end

    def wrapper_uniq_by
      # optionally implemented in subclass in order to make the wrapper key unique
    end

    def insert_target_modified?
      # optionally overriden (returning true) in subclass in order to indicate thate the insert target
      # is modified and should not be the root inner html element
      # insert_target_container needs to be present on component's erb template then
      false
    end

    def insert_target_container(tag: "div", class: nil, data: nil, style: nil, &block)
      unless insert_target_modified?
        raise "`insert_target_modified?` needs to be implemented and return true if `insert_target_container` is used in this component"
      end
      
      content_tag(tag, id: insert_target_modifier_id, class:, data:, style:, &block)
    end

    def insert_target_modifier_id
      "#{wrapper_key}-insert-target-modifier"
    end
  end
end