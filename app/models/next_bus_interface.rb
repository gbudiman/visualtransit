class NextBusInterface
  NB_ROUTE_LIST = 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeList'

  attr_reader :data, :agency_name

  def initialize name:, fast_debug: false
    @agency_name = name
    @data = Hash.new
    @fast_debug = fast_debug
    @nb = {
      route_list: 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeList&a=' + name,
      route_config: "http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=#{name}&r="
    }

    parse_routes
    parse_route_config

    #ap @data if fast_debug
  end

  def persist route_tag:
    puts "Persisting route [#{@agency_name} - #{route_tag}]..."
    d = @data[route_tag]

    #ap d
    ActiveRecord::Base.transaction do
      agency = Agency.find_or_initialize_by name: @agency_name
      agency.save

      route = Route.find_or_initialize_by name: d[:title], 
                                          tag: route_tag,
                                          agency_id: agency.id
      route.save

      d[:stops].each do |stop_tag, stop_data|
        stop = Stop.find_or_initialize_by tag: stop_tag,
                                          name: stop_data[:title],
                                          coord: stop_data[:coord].join(',')
        stop.save
      end

      d[:directions].each do |dir_id, dir_data|
        direction = Direction.find_or_initialize_by route_id: route.id,
                                                    title: dir_data[:title],
                                                    name: dir_data[:name]
        direction.save

        dir_data[:stops].each do |stop_tag|
          stop = Stop.find_by tag: stop_tag
          dir_stop = DirectionStop.find_or_initialize_by direction_id: direction.id,
                                                         stop_id: stop.id

          dir_stop.save
        end
      end

      Path.where(route_id: route.id).destroy_all
      d[:paths].each do |paths|
        path_concat = Array.new
        paths.each do |path|
          path_concat.push(path.join(','))
        end

        path = Path.new route_id: route.id,
                        coord: path_concat.join('|')
        path.save
      end
    end

    return NextBusInterface::db_status
  end

  def self.db_status
    return {
      agency: Agency.count,
      route: Route.count,
      direction: Direction.count,
      path: Path.count,
      stop: Stop.count,
      direction_stop: DirectionStop.count
    }
  end

private
  def parse_routes
    x = Nokogiri::XML(open @nb[:route_list])
    x.css('route').each do |route|
      route_tag = route[:tag]
      route_title = route[:title]

      @data[route_tag] = {
        title: route_title,
        directions: Hash.new,
        stops: Hash.new,
        paths: Array.new
      }
    end
  end

  def parse_route_config
    configs = @fast_debug ? @data.first(1) : @data

    configs.each do |route_tag, _d|
      route_config = @nb[:route_config] + route_tag
      x = Nokogiri::XML(open route_config)

      parse_route_config_stops route_tag, x
      parse_route_config_directions route_tag, x
      parse_route_config_paths route_tag, x

      ap (persist route_tag: route_tag)
    end
  end

  def parse_route_config_stops r, x
    x.css('route > stop').each do |stop|
      stop_tag = stop[:tag]
      stop_title = stop[:title]
      stop_coord = [stop[:lat], stop[:lon]]

      @data[r][:stops][stop_tag] ||= {
        title: stop_title,
        coord: stop_coord
      }
    end
  end

  def parse_route_config_directions r, x
    x.css('route > direction').each do |d|
      @data[r][:directions][d[:tag]] = {
        title: d[:title],
        name: d[:name],
        stops: Array.new
      }

      stops = @data[r][:directions][d[:tag]][:stops]

      d.css('stop').each do |stop|
        stops.push stop[:tag]
      end
    end
  end

  def parse_route_config_paths r, x
    x.css('route > path').each do |path|
      path_t = Array.new
      path.css('point').each do |point|
        path_t.push([point[:lat], point[:lon]])
      end

      @data[r][:paths].push path_t
    end
  end
end
