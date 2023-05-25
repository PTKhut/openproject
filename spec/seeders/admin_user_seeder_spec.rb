# frozen_string_literal: true

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

require 'spec_helper'

RSpec.describe AdminUserSeeder do
  subject(:seeder) { described_class.new(seed_data) }

  let(:seed_data) { Source::SeedData.new({}) }

  it 'creates an admin user' do
    expect { seeder.seed! }.to change { User.admin.count }.by(1)
  end

  it 'references the admin user as :openproject_admin in the seed_data' do
    seeder.seed!
    expect(seed_data.find_reference(:openproject_admin)).to eq(User.admin.first)
  end

  context 'when a builtin admin user already exists' do
    before do
      User.system
    end

    it 'creates a non-builtin admin user' do
      expect(User.admin.count).to eq(1)
      expect { seeder.seed! }.to change { User.user.admin.count }.by(1)
    end
  end

  context 'when some admin users already exist' do
    before do
      User.system
      create(:admin, firstname: 'First existing admin')
      create(:admin, firstname: 'Second existing admin')
    end

    it 'does not create another admin user' do
      expect { seeder.seed! }.not_to change { User.admin.count }
    end

    it 'references the first non-builtin admin user as :openproject_admin in the seed_data' do
      seeder.seed!
      expect(seed_data.find_reference(:openproject_admin)).to eq(User.user.admin.first)
    end
  end
end