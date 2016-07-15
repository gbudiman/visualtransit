require 'rails_helper'

RSpec.describe NextBusInterface, type: :model do
  it 'should be able to list routes' do
    nb = NextBusInterface.new name: 'lametro', fast_debug: true

    Query.new agency: nb.agency_name, route_tag: nb.data.keys.first
  end
end
